# SPDX-License-Identifier: MIT
# Copyright (c) 2026 aufkrawall

<# 
.SYNOPSIS
  Installs or detects Windows security-audit/debugging tools referenced by debug-tools-security-audit.md.

.DESCRIPTION
  Conservative by default:
  - Downloads small portable tools from official/safe sources where practical.
  - Verifies Authenticode signatures for Microsoft/Sysinternals downloads.
  - Does NOT install large packages such as Visual Studio Build Tools, Windows SDK, or LLVM by default.
  - Detects large/existing toolchains and prints warnings when tools are unavailable.
  - Generates a manifest and warnings file for audit-report evidence.

  Intended repo location:
    llm-wiki/install-security-audit-tools.ps1

.PARAMETER InstallRoot
  Directory where portable tools and manifest files are placed.

.PARAMETER DebugToolsMdPath
  Path to debug-tools-security-audit.md or debug-tools.md. Used for evidence/logging.
  The script does not execute arbitrary commands from this file.

.PARAMETER SkipSysinternals
  Skip downloading small portable Microsoft Sysinternals CLI tools.

.PARAMETER IncludeGuiSysinternals
  Also download GUI Sysinternals tools such as Procmon and Process Explorer.

.PARAMETER IncludeWinDbg
  Install WinDbg Preview using winget package Microsoft.WinDbg.
  This is official Microsoft tooling, but it is not portable.

.PARAMETER IncludeFFmpeg
  Download and extract ffmpeg-release-essentials.zip from gyan.dev.
  FFmpeg upstream provides source only and links to third-party Windows builds; this is opt-in.

.PARAMETER IncludeLLVMViaWinget
  Install LLVM using winget package LLVM.LLVM.
  This is larger and not portable, so it is opt-in.

.PARAMETER SkipVSWhere
  Skip downloading portable vswhere.exe from the official microsoft/vswhere GitHub release.

.PARAMETER AddToUserPath
  Add installed portable tool directories to the current user's PATH.

.PARAMETER WhatIfOnly
  Print planned actions and detection results without downloading or installing.

.EXAMPLE
  .\install-security-audit-tools.ps1

.EXAMPLE
  .\install-security-audit-tools.ps1 -IncludeGuiSysinternals -IncludeWinDbg -AddToUserPath

.EXAMPLE
  .\install-security-audit-tools.ps1 -IncludeFFmpeg -IncludeLLVMViaWinget

.NOTES
  Safe-source policy:
  - Microsoft Sysinternals tools: https://live.sysinternals.com/
  - WinDbg Preview: winget package Microsoft.WinDbg
  - vswhere: official microsoft/vswhere GitHub release
  - FFmpeg Windows build: gyan.dev, opt-in third-party build linked from FFmpeg download resources
  - LLVM: winget package LLVM.LLVM, opt-in because it is relatively large

  This script intentionally does not install Windows SDK Debugging Tools, Visual Studio Build Tools,
  or MSVC by default because they are large. It detects them and reports missing coverage.
#>

[CmdletBinding()]
param(
  [string]$InstallRoot = "$env:LOCALAPPDATA\SecurityAuditTools",
  [string]$DebugToolsMdPath = ".\llm-wiki\debug-tools-security-audit.md",
  [switch]$SkipSysinternals,
  [switch]$IncludeGuiSysinternals,
  [switch]$IncludeWinDbg,
  [switch]$IncludeFFmpeg,
  [switch]$IncludeLLVMViaWinget,
  [switch]$SkipVSWhere,
  [switch]$AddToUserPath,
  [switch]$WhatIfOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
} catch {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$InstallRoot = [IO.Path]::GetFullPath($InstallRoot)
$BinRoot = Join-Path $InstallRoot "bin"
$SysinternalsDir = Join-Path $BinRoot "sysinternals"
$VSWhereDir = Join-Path $BinRoot "vswhere"
$FFmpegDir = Join-Path $BinRoot "ffmpeg"
$LogDir = Join-Path $InstallRoot "logs"
$ManifestPath = Join-Path $InstallRoot "security-audit-tool-manifest.json"
$WarningsPath = Join-Path $InstallRoot "security-audit-tool-warnings.txt"
$MarkdownPath = Join-Path $InstallRoot "security-audit-tool-availability.md"

$script:Results = New-Object System.Collections.Generic.List[object]
$script:Warnings = New-Object System.Collections.Generic.List[string]

function Add-WarningMessage {
  param([string]$Message)
  $script:Warnings.Add($Message) | Out-Null
  Write-Warning $Message
}

function Add-Result {
  param(
    [string]$Name,
    [string]$Category,
    [string]$Status,
    [string]$Path = "",
    [string]$Source = "",
    [string]$SignatureStatus = "",
    [string]$Notes = ""
  )
  $script:Results.Add([pscustomobject]@{
    name = $Name
    category = $Category
    status = $Status
    path = $Path
    source = $Source
    signature_status = $SignatureStatus
    notes = $Notes
  }) | Out-Null
}

function Ensure-Dir {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    if ($WhatIfOnly) {
      Write-Host "Would create directory: $Path"
    } else {
      New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
  }
}

function Test-CommandPath {
  param([string]$Command)
  $cmd = Get-Command $Command -ErrorAction SilentlyContinue
  if ($null -ne $cmd) { return $cmd.Source }
  return $null
}

function Get-FileSignatureSummary {
  param(
    [string]$Path,
    [string]$ExpectedPublisherRegex = ""
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return "Missing"
  }

  try {
    $sig = Get-AuthenticodeSignature -FilePath $Path
    $subject = ""
    if ($sig.SignerCertificate) { $subject = $sig.SignerCertificate.Subject }

    if ($sig.Status -ne "Valid") {
      return "Invalid:$($sig.Status); Subject=$subject"
    }

    if ($ExpectedPublisherRegex -and ($subject -notmatch $ExpectedPublisherRegex)) {
      return "ValidSignatureUnexpectedPublisher; Subject=$subject"
    }

    return "Valid; Subject=$subject"
  } catch {
    return "SignatureCheckFailed:$($_.Exception.Message)"
  }
}

function Invoke-SafeDownload {
  param(
    [string]$Name,
    [string]$Uri,
    [string]$OutFile,
    [string]$ExpectedPublisherRegex = "",
    [switch]$RequireValidSignature
  )

  $parent = Split-Path -Parent $OutFile
  Ensure-Dir $parent

  if (Test-Path -LiteralPath $OutFile) {
    Write-Host "Already present: $OutFile"
  } elseif ($WhatIfOnly) {
    Write-Host "Would download $Name from $Uri to $OutFile"
    Add-Result -Name $Name -Category "download" -Status "planned" -Path $OutFile -Source $Uri -Notes "WhatIfOnly"
    return
  } else {
    Write-Host "Downloading $Name from $Uri"
    Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
  }

  if (Test-Path -LiteralPath $OutFile) {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $OutFile).Hash
    $sigSummary = Get-FileSignatureSummary -Path $OutFile -ExpectedPublisherRegex $ExpectedPublisherRegex

    if ($RequireValidSignature -and ($sigSummary -notlike "Valid;*")) {
      Add-WarningMessage "$Name was downloaded but did not have the expected valid Authenticode signature. Signature: $sigSummary"
      Add-Result -Name $Name -Category "download" -Status "signature-warning" -Path $OutFile -Source $Uri -SignatureStatus $sigSummary -Notes "SHA256=$hash"
    } else {
      Add-Result -Name $Name -Category "download" -Status "available" -Path $OutFile -Source $Uri -SignatureStatus $sigSummary -Notes "SHA256=$hash"
    }
  }
}

function Add-UserPathEntry {
  param([string]$PathToAdd)
  if (-not (Test-Path -LiteralPath $PathToAdd)) { return }

  $current = [Environment]::GetEnvironmentVariable("Path", "User")
  $parts = @()
  if ($current) { $parts = $current -split ";" | Where-Object { $_ -ne "" } }

  if ($parts -contains $PathToAdd) {
    Write-Host "User PATH already contains: $PathToAdd"
    return
  }

  if ($WhatIfOnly) {
    Write-Host "Would add to user PATH: $PathToAdd"
    return
  }

  $newPath = (($parts + $PathToAdd) -join ";")
  [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
  Write-Host "Added to user PATH: $PathToAdd"
}

function Test-KnownPath {
  param(
    [string]$Name,
    [string]$Category,
    [string[]]$Paths,
    [string]$WarningIfMissing = ""
  )

  foreach ($p in $Paths) {
    $expanded = [Environment]::ExpandEnvironmentVariables($p)
    if (Test-Path -LiteralPath $expanded) {
      Add-Result -Name $Name -Category $Category -Status "available" -Path $expanded
      return $expanded
    }
  }

  $cmdPath = Test-CommandPath $Name
  if ($cmdPath) {
    Add-Result -Name $Name -Category $Category -Status "available-in-path" -Path $cmdPath
    return $cmdPath
  }

  Add-Result -Name $Name -Category $Category -Status "missing" -Notes $WarningIfMissing
  if ($WarningIfMissing) { Add-WarningMessage $WarningIfMissing }
  return $null
}

function Install-WithWinget {
  param(
    [string]$Name,
    [string]$PackageId,
    [string]$Reason
  )

  $winget = Test-CommandPath "winget.exe"
  if (-not $winget) {
    Add-WarningMessage "winget.exe is unavailable; cannot install $Name ($PackageId). $Reason"
    Add-Result -Name $Name -Category "winget" -Status "missing-winget" -Notes $Reason
    return
  }

  if ($WhatIfOnly) {
    Write-Host "Would install $Name via winget package $PackageId"
    Add-Result -Name $Name -Category "winget" -Status "planned" -Source "winget:$PackageId" -Notes $Reason
    return
  }

  Write-Host "Installing $Name via winget package $PackageId"
  & $winget install --id $PackageId -e --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    Add-WarningMessage "winget install failed for $Name ($PackageId), exit code $LASTEXITCODE"
    Add-Result -Name $Name -Category "winget" -Status "install-failed" -Source "winget:$PackageId" -Notes "ExitCode=$LASTEXITCODE; $Reason"
  } else {
    Add-Result -Name $Name -Category "winget" -Status "installed-or-present" -Source "winget:$PackageId" -Notes $Reason
  }
}

function Find-VSTools {
  param([string]$VSWherePath)

  $vsInstall = $null
  if ($VSWherePath -and (Test-Path -LiteralPath $VSWherePath)) {
    try {
      $vsInstall = & $VSWherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    } catch {
      Add-WarningMessage "vswhere failed while locating MSVC tools: $($_.Exception.Message)"
    }
  }

  $roots = @()
  if ($vsInstall) { $roots += $vsInstall }
  $roots += @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools"
  )

  $toolNames = @("dumpbin.exe", "link.exe", "lib.exe", "editbin.exe", "undname.exe")
  foreach ($tool in $toolNames) {
    $found = $null
    foreach ($root in $roots | Select-Object -Unique) {
      if (-not $root -or -not (Test-Path -LiteralPath $root)) { continue }
      $matches = Get-ChildItem -LiteralPath $root -Recurse -Filter $tool -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\VC\\Tools\\MSVC\\.*\\bin\\Hostx64\\x64\\" } |
        Sort-Object FullName -Descending |
        Select-Object -First 1
      if ($matches) {
        $found = $matches.FullName
        break
      }
    }

    if ($found) {
      Add-Result -Name $tool -Category "MSVC binary tools" -Status "available" -Path $found
    } else {
      Add-WarningMessage "$tool was not found. MSVC PE/COFF inspection or mutation-capable tooling may be unavailable. Visual Studio Build Tools are intentionally not installed by this script."
      Add-Result -Name $tool -Category "MSVC binary tools" -Status "missing" -Notes "Large dependency intentionally not installed"
    }
  }
}

Ensure-Dir $InstallRoot
Ensure-Dir $BinRoot
Ensure-Dir $LogDir

Write-Host "Security audit tool installer/detector"
Write-Host "InstallRoot: $InstallRoot"
Write-Host "WhatIfOnly: $WhatIfOnly"

# Locate local docs.
$debugDocCandidates = @(
  $DebugToolsMdPath,
  ".\llm-wiki\debug-tools-security-audit.md",
  ".\llm-wiki\debug-tools.md",
  ".\debug-tools-security-audit.md",
  ".\debug-tools.md"
) | Select-Object -Unique

$debugDocFound = $null
foreach ($doc in $debugDocCandidates) {
  $expanded = [IO.Path]::GetFullPath($doc)
  if (Test-Path -LiteralPath $expanded) {
    $debugDocFound = $expanded
    break
  }
}

if ($debugDocFound) {
  Add-Result -Name "debug-tools local doc" -Category "local guidance" -Status "available" -Path $debugDocFound
} else {
  Add-WarningMessage "No debug-tools-security-audit.md or debug-tools.md file was found in the expected locations. Local project-specific tool guidance is unavailable."
  Add-Result -Name "debug-tools local doc" -Category "local guidance" -Status "missing"
}

# Download small portable Sysinternals tools by default.
if (-not $SkipSysinternals) {
  $sysinternalsBase = "https://live.sysinternals.com"
  $coreTools = @(
    "procdump.exe",
    "sigcheck.exe",
    "strings.exe",
    "handle.exe",
    "listdlls.exe",
    "vmmap.exe"
  )

  if ($IncludeGuiSysinternals) {
    $coreTools += @("Procmon.exe", "procexp.exe")
  } else {
    Add-WarningMessage "GUI Sysinternals tools procmon.exe and procexp.exe were not downloaded by default. Use -IncludeGuiSysinternals if runtime tracing/process inspection is needed."
  }

  foreach ($tool in $coreTools | Select-Object -Unique) {
    $url = "$sysinternalsBase/$tool"
    $out = Join-Path $SysinternalsDir $tool
    Invoke-SafeDownload -Name $tool -Uri $url -OutFile $out -ExpectedPublisherRegex "Microsoft" -RequireValidSignature
  }
} else {
  Add-WarningMessage "Sysinternals downloads were skipped. Crash capture, signatures, strings, handles, DLL listing, and runtime inspection coverage may be reduced."
}

# Download portable vswhere by default for Visual Studio detection.
$vswherePath = $null
if (-not $SkipVSWhere) {
  $vswherePath = Join-Path $VSWhereDir "vswhere.exe"
  Invoke-SafeDownload `
    -Name "vswhere.exe" `
    -Uri "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe" `
    -OutFile $vswherePath `
    -ExpectedPublisherRegex "Microsoft" `
    -RequireValidSignature
} else {
  Add-WarningMessage "vswhere download was skipped. MSVC tool discovery may be less reliable."
}

if (-not $vswherePath -or -not (Test-Path -LiteralPath $vswherePath)) {
  $vswherePath = Test-CommandPath "vswhere.exe"
}

# Optional WinDbg Preview.
if ($IncludeWinDbg) {
  Install-WithWinget -Name "WinDbg Preview" -PackageId "Microsoft.WinDbg" -Reason "Official Microsoft debugger; not portable"
} else {
  Add-WarningMessage "WinDbg Preview was not installed by default. Use -IncludeWinDbg if crash dump debugging is needed and Windows SDK Debugging Tools are unavailable."
}

# Optional LLVM.
if ($IncludeLLVMViaWinget) {
  Install-WithWinget -Name "LLVM" -PackageId "LLVM.LLVM" -Reason "Provides llvm-strings/llvm-objdump; larger non-portable package"
} else {
  Add-WarningMessage "LLVM was not installed by default. Use -IncludeLLVMViaWinget if llvm-strings or llvm-objdump is needed."
}

# Optional FFmpeg build.
if ($IncludeFFmpeg) {
  $zipPath = Join-Path $FFmpegDir "ffmpeg-release-essentials.zip"
  Invoke-SafeDownload `
    -Name "ffmpeg-release-essentials.zip" `
    -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" `
    -OutFile $zipPath

  if ((Test-Path -LiteralPath $zipPath) -and -not $WhatIfOnly) {
    $extractRoot = Join-Path $FFmpegDir "extract"
    Ensure-Dir $extractRoot
    Write-Host "Extracting FFmpeg archive to $extractRoot"
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force
    $ffmpegExe = Get-ChildItem -LiteralPath $extractRoot -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    $ffprobeExe = Get-ChildItem -LiteralPath $extractRoot -Recurse -Filter "ffprobe.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ffmpegExe) { Add-Result -Name "ffmpeg.exe" -Category "media/capture" -Status "available" -Path $ffmpegExe.FullName -Source "gyan.dev" }
    if ($ffprobeExe) { Add-Result -Name "ffprobe.exe" -Category "media/capture" -Status "available" -Path $ffprobeExe.FullName -Source "gyan.dev" }
    if (-not $ffmpegExe -or -not $ffprobeExe) {
      Add-WarningMessage "FFmpeg archive extracted but ffmpeg.exe or ffprobe.exe was not found."
    }
  }

  Add-WarningMessage "FFmpeg Windows binary was downloaded from an opt-in third-party build source. Record hash and source in audit evidence."
} else {
  Add-WarningMessage "FFmpeg/ffprobe were not installed by default. Use -IncludeFFmpeg only when capture/media inspection is needed."
}

# Detect Windows SDK Debugging Tools.
$sdkDebuggerPaths = @{
  "cdb.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\cdb.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\cdb.exe"
  )
  "windbg.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\windbg.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\windbg.exe"
  )
  "dumpchk.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\dumpchk.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\dumpchk.exe"
  )
  "symchk.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\symchk.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\symchk.exe"
  )
  "dbh.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\dbh.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\dbh.exe"
  )
  "pdbcopy.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\pdbcopy.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\pdbcopy.exe"
  )
  "symstore.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\symstore.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\symstore.exe"
  )
  "gflags.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\gflags.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\gflags.exe"
  )
  "umdh.exe" = @(
    "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64\umdh.exe",
    "${env:ProgramFiles}\Windows Kits\10\Debuggers\x64\umdh.exe"
  )
}

foreach ($name in $sdkDebuggerPaths.Keys) {
  Test-KnownPath -Name $name -Category "Windows SDK Debugging Tools" -Paths $sdkDebuggerPaths[$name] -WarningIfMissing "$name was not found. Windows SDK Debugging Tools are intentionally not installed by this script because they are large; dump/symbol/debug coverage may be reduced." | Out-Null
}

# Detect WinDbg Preview alias.
Test-KnownPath -Name "WinDbgX.exe" -Category "WinDbg Preview" -Paths @(
  "%LOCALAPPDATA%\Microsoft\WindowsApps\WinDbgX.exe"
) -WarningIfMissing "WinDbgX.exe was not found. Use -IncludeWinDbg to install WinDbg Preview through winget." | Out-Null

# Detect Visual Studio PE/COFF tools.
Find-VSTools -VSWherePath $vswherePath

# Detect LLVM tools.
foreach ($tool in @("llvm-strings.exe", "llvm-objdump.exe")) {
  $pathFound = Test-CommandPath $tool
  if ($pathFound) {
    Add-Result -Name $tool -Category "LLVM tools" -Status "available-in-path" -Path $pathFound
  } else {
    Add-Result -Name $tool -Category "LLVM tools" -Status "missing" -Notes "Use -IncludeLLVMViaWinget if needed"
    Add-WarningMessage "$tool was not found. LLVM-specific binary inspection coverage may be reduced."
  }
}

# Detect FFmpeg if not installed here.
foreach ($tool in @("ffmpeg.exe", "ffprobe.exe")) {
  $pathFound = Test-CommandPath $tool
  if ($pathFound) {
    Add-Result -Name $tool -Category "media/capture" -Status "available-in-path" -Path $pathFound
  } else {
    $installed = Get-ChildItem -LiteralPath $FFmpegDir -Recurse -Filter $tool -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($installed) {
      Add-Result -Name $tool -Category "media/capture" -Status "available" -Path $installed.FullName
    } else {
      Add-Result -Name $tool -Category "media/capture" -Status "missing" -Notes "Use -IncludeFFmpeg if needed"
    }
  }
}

# Add portable dirs to PATH if requested.
if ($AddToUserPath) {
  Add-UserPathEntry $SysinternalsDir
  Add-UserPathEntry $VSWhereDir

  $ffmpegBin = Get-ChildItem -LiteralPath $FFmpegDir -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "\\bin$" } |
    Select-Object -First 1
  if ($ffmpegBin) { Add-UserPathEntry $ffmpegBin.FullName }
}

# Write outputs.
$manifest = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  install_root = $InstallRoot
  debug_tools_doc = $debugDocFound
  host = [pscustomobject]@{
    computer_name = $env:COMPUTERNAME
    user = $env:USERNAME
    os = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Caption)
    os_architecture = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OSArchitecture)
    processor_architecture = $env:PROCESSOR_ARCHITECTURE
    powershell_version = $PSVersionTable.PSVersion.ToString()
  }
  results = $script:Results
  warnings = $script:Warnings
}

if ($WhatIfOnly) {
  Write-Host "WhatIfOnly enabled; manifest files will not be written."
} else {
  $manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
  $script:Warnings | Set-Content -LiteralPath $WarningsPath -Encoding UTF8

  $md = New-Object System.Collections.Generic.List[string]
  $md.Add("# Security Audit Tool Availability")
  $md.Add("")
  $md.Add("- Generated: $($manifest.generated_at)")
  $md.Add("- Install root: `$InstallRoot`")
  $md.Add("- Debug tools doc: `$debugDocFound`")
  $md.Add("")
  $md.Add("## Warnings")
  $md.Add("")
  if ($script:Warnings.Count -eq 0) {
    $md.Add("- None")
  } else {
    foreach ($w in $script:Warnings) { $md.Add("- WARNING: $w") }
  }
  $md.Add("")
  $md.Add("## Tool results")
  $md.Add("")
  $md.Add("| Tool | Category | Status | Path | Signature | Notes |")
  $md.Add("|---|---|---|---|---|---|")
  foreach ($r in $script:Results) {
    $md.Add("| $($r.name) | $($r.category) | $($r.status) | `$($r.path)` | $($r.signature_status) | $($r.notes) |")
  }
  $md | Set-Content -LiteralPath $MarkdownPath -Encoding UTF8

  Write-Host "Wrote manifest: $ManifestPath"
  Write-Host "Wrote warnings: $WarningsPath"
  Write-Host "Wrote Markdown evidence: $MarkdownPath"
}

if ($script:Warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "Completed with warnings. These should be reflected in audit confidence/scoring." -ForegroundColor Yellow
  exit 2
}

Write-Host "Completed without warnings." -ForegroundColor Green
exit 0
