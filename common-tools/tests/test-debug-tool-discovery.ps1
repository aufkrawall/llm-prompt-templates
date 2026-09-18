[CmdletBinding()]
param(
  [string]$DiscoveryScriptPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "discover-debug-tools.ps1")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-SequenceEqual {
  param([string]$Label, [object[]]$Actual, [object[]]$Expected)
  $actualText = @($Actual) -join "|"
  $expectedText = @($Expected) -join "|"
  if ($actualText -ne $expectedText) {
    throw "$Label mismatch. Expected '$expectedText', got '$actualText'."
  }
}

$tokens = $null
$parseErrors = $null
$resolvedScriptPath = (Resolve-Path -LiteralPath $DiscoveryScriptPath).Path
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
  $resolvedScriptPath,
  [ref]$tokens,
  [ref]$parseErrors
)
if ($parseErrors -and $parseErrors.Count -gt 0) {
  $messages = $parseErrors | ForEach-Object { $_.Message }
  throw "Discovery script parse failed: $($messages -join '; ')"
}

foreach ($functionName in @(
  "Resolve-ConfiguredPath",
  "Read-ToolPathOverrides",
  "Get-OverrideValue",
  "Get-WindowsSdkDebuggerArchitectures",
  "Get-WindowsSdkDebuggerCandidatePaths",
  "Get-MsvcBinaryToolArchitecturePreferences",
  "Get-MsvcOverrideKeys",
  "Select-PreferredMsvcToolMatch"
)) {
  $functionAst = $ast.Find(
    {
      param($node)
      $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq $functionName
    },
    $true
  )
  if (-not $functionAst) { throw "Required function '$functionName' was not found." }
  . ([scriptblock]::Create($functionAst.Extent.Text))
}

$originalProgramFiles = [Environment]::GetEnvironmentVariable("ProgramFiles", "Process")
$originalProgramFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)", "Process")
$originalProcessorArchitecture = [Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE", "Process")
$overrideFile = $null

try {
  $script:Warnings = [System.Collections.Generic.List[string]]::new()
  function Add-WarningMessage { param([string]$Message) $script:Warnings.Add($Message) | Out-Null }

  $ProjectRoot = [IO.Path]::GetTempPath()
  $rootA = Join-Path $ProjectRoot "llm-template-test-pf"
  $rootB = Join-Path $ProjectRoot "llm-template-test-pfx86"
  [Environment]::SetEnvironmentVariable("ProgramFiles", $rootA, "Process")
  [Environment]::SetEnvironmentVariable("ProgramFiles(x86)", $rootB, "Process")
  $env:PROCESSOR_ARCHITECTURE = "AMD64"

  $overrideRoot = Join-Path $ProjectRoot "sdk-x86-override"
  $overrideFile = Join-Path $ProjectRoot "llm-debug-tool-paths-test.env"
  @(
    "WINDOWS_SDK_DEBUGGERS_X86=$overrideRoot",
    "LLVM_ROOT=.\llvm-test",
    "MALFORMED_LINE"
  ) | Set-Content -LiteralPath $overrideFile -Encoding UTF8

  $script:Overrides = Read-ToolPathOverrides -Path $overrideFile
  if ((Get-OverrideValue -Name "WINDOWS_SDK_DEBUGGERS_X86") -ne $overrideRoot) {
    throw "tool-paths.env override was not loaded."
  }

  $expectedMalformedWarning = "Ignoring malformed tool-path override line in {0}: MALFORMED_LINE" -f ([IO.Path]::GetFullPath($overrideFile))
  if ($script:Warnings -notcontains $expectedMalformedWarning) {
    throw "Malformed override warning was not emitted with the resolved path."
  }

  $paths = @(Get-WindowsSdkDebuggerCandidatePaths -ToolName "cdb.exe")
  $expectedOverride = Join-Path $overrideRoot "cdb.exe"
  if ($paths -notcontains $expectedOverride) {
    throw "Configured x86 debugger root was not included in cdb.exe candidates."
  }

  $architectures = @(
    $paths |
      Where-Object { $_ -notlike "$overrideRoot*" } |
      ForEach-Object { Split-Path -Leaf (Split-Path -Parent $_) }
  )
  Assert-SequenceEqual -Label "AMD64 standard debugger path preference" -Actual $architectures -Expected @(
    "x64", "x64", "x86", "x86", "arm64", "arm64", "arm", "arm"
  )

  Assert-SequenceEqual -Label "AMD64 MSVC override preference" -Actual @(Get-MsvcOverrideKeys) -Expected @(
    "MSVC_TOOLS_X64", "MSVC_TOOLS_X86", "MSVC_TOOLS_ARM64"
  )

  $msvcMatches = @(
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx86\x86\dumpbin.exe" },
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx64\x86\dumpbin.exe" },
    [pscustomobject]@{ FullName = "C:\VS\VC\Tools\MSVC\14.0\bin\Hostx64\x64\dumpbin.exe" }
  )
  $preferred = Select-PreferredMsvcToolMatch -Candidates $msvcMatches
  if ($preferred.FullName -notlike "*\Hostx64\x64\dumpbin.exe") {
    throw "AMD64 MSVC preference did not select Hostx64\x64."
  }
} finally {
  [Environment]::SetEnvironmentVariable("ProgramFiles", $originalProgramFiles, "Process")
  [Environment]::SetEnvironmentVariable("ProgramFiles(x86)", $originalProgramFilesX86, "Process")
  [Environment]::SetEnvironmentVariable("PROCESSOR_ARCHITECTURE", $originalProcessorArchitecture, "Process")
  if ($overrideFile -and (Test-Path -LiteralPath $overrideFile)) {
    Remove-Item -LiteralPath $overrideFile -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "Generic debug-tool discovery regression checks passed."
