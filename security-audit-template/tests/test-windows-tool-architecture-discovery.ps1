[CmdletBinding()]
param(
  [string]$InstallerPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "install-security-audit-tools.ps1")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-SequenceEqual {
  param(
    [string]$Label,
    [object[]]$Actual,
    [object[]]$Expected
  )

  $actualText = @($Actual) -join "|"
  $expectedText = @($Expected) -join "|"
  if ($actualText -ne $expectedText) {
    throw "$Label mismatch. Expected '$expectedText', got '$actualText'."
  }
}

function Get-FunctionFromInstaller {
  param(
    [System.Management.Automation.Language.ScriptBlockAst]$Ast,
    [string]$Name
  )

  $functionAst = $Ast.Find(
    {
      param($node)
      $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq $Name
    },
    $true
  )

  if (-not $functionAst) {
    throw "Required function '$Name' was not found in $InstallerPath."
  }

  Invoke-Expression $functionAst.Extent.Text
}

$tokens = $null
$parseErrors = $null
$resolvedInstallerPath = (Resolve-Path -LiteralPath $InstallerPath).Path
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
  $resolvedInstallerPath,
  [ref]$tokens,
  [ref]$parseErrors
)

if ($parseErrors.Count -gt 0) {
  $messages = $parseErrors | ForEach-Object { $_.Message }
  throw "Installer parse failed: $($messages -join '; ')"
}

foreach ($functionName in @(
  "Get-WindowsSdkDebuggerArchitectures",
  "Get-WindowsSdkDebuggerCandidatePaths",
  "Get-MsvcBinaryToolArchitecturePreferences",
  "Select-PreferredMsvcToolMatch"
)) {
  Get-FunctionFromInstaller -Ast $ast -Name $functionName
}

$originalProgramFiles = [Environment]::GetEnvironmentVariable("ProgramFiles", "Process")
$originalProgramFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)", "Process")
$originalProcessorArchitecture = [Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "Process")

try {
  $rootA = Join-Path ([IO.Path]::GetTempPath()) "llm-template-test-pf"
  $rootB = Join-Path ([IO.Path]::GetTempPath()) "llm-template-test-pfx86"
  [Environment]::SetEnvironmentVariable("ProgramFiles", $rootA, "Process")
  [Environment]::SetEnvironmentVariable("ProgramFiles(x86)", $rootB, "Process")

  $env:PROCESSOR_ARCHITECTURE = "AMD64"
  $paths = @(Get-WindowsSdkDebuggerCandidatePaths -ToolName "cdb.exe")
  $architectures = @(
    $paths | ForEach-Object {
      Split-Path -Leaf (Split-Path -Parent $_)
    }
  )
  Assert-SequenceEqual -Label "AMD64 debugger path preference" -Actual $architectures -Expected @(
    "x64", "x64", "x86", "x86", "arm64", "arm64"
  )
  if (($paths | Where-Object { (Split-Path -Leaf $_) -ne "cdb.exe" }).Count -ne 0) {
    throw "Debugger path generation changed the requested tool name."
  }

  $env:PROCESSOR_ARCHITECTURE = "ARM64"
  $paths = @(Get-WindowsSdkDebuggerCandidatePaths -ToolName "windbg.exe")
  $architectures = @(
    $paths | ForEach-Object {
      Split-Path -Leaf (Split-Path -Parent $_)
    }
  )
  Assert-SequenceEqual -Label "ARM64 debugger path preference" -Actual $architectures -Expected @(
    "arm64", "arm64", "x64", "x64", "x86", "x86"
  )

  $env:PROCESSOR_ARCHITECTURE = "AMD64"
  $msvcMatches = @(
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx86\x86\dumpbin.exe" },
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx64\x86\dumpbin.exe" },
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx64\x64\dumpbin.exe" }
  )
  $preferred = Select-PreferredMsvcToolMatch -Matches $msvcMatches
  if ($preferred.FullName -notlike "*\Hostx64\x64\dumpbin.exe") {
    throw "AMD64 MSVC tool preference did not select Hostx64\x64."
  }

  $env:PROCESSOR_ARCHITECTURE = "ARM64"
  $msvcMatches = @(
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx64\x64\dumpbin.exe" },
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostarm64\arm64\dumpbin.exe" }
  )
  $preferred = Select-PreferredMsvcToolMatch -Matches $msvcMatches
  if ($preferred.FullName -notlike "*\Hostarm64\arm64\dumpbin.exe") {
    throw "ARM64 MSVC tool preference did not select Hostarm64\arm64."
  }
} finally {
  [Environment]::SetEnvironmentVariable("ProgramFiles", $originalProgramFiles, "Process")
  [Environment]::SetEnvironmentVariable("ProgramFiles(x86)", $originalProgramFilesX86, "Process")
  [Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", $originalProcessorArchitecture, "Process")
}

Write-Host "Windows tool architecture discovery regression checks passed."
