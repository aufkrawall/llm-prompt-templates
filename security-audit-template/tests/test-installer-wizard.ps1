[CmdletBinding()]
param(
  [string]$InstallerPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "install-security-audit-tools.ps1")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedInstallerPath = (Resolve-Path -LiteralPath $InstallerPath).Path
$content = Get-Content -LiteralPath $resolvedInstallerPath -Raw

$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
  $resolvedInstallerPath,
  [ref]$tokens,
  [ref]$parseErrors
)
if ($parseErrors -and $parseErrors.Count -gt 0) {
  $messages = $parseErrors | ForEach-Object { $_.Message }
  throw "Installer parse failed: $($messages -join '; ')"
}

foreach ($required in @(
  "function Invoke-InstallerWizard",
  "Full install (default; all supported tools including large packages)",
  "Proceed with the FULL installation?",
  '[switch]$IncludeWindowsSdkDebuggers',
  '[switch]$IncludeVisualStudioBuildTools',
  "OptionId.WindowsDesktopDebuggers",
  "Microsoft.VisualStudio.Workload.VCTools",
  "https://aka.ms/vs/stable/vs_buildtools.exe",
  "function Write-CompletionSummary",
  "Get-FinalUnavailableResults"
)) {
  if (-not $content.Contains($required)) {
    throw "Installer wizard/full-install behavior is missing required marker: $required"
  }
}

$fullBlock = [regex]::Match(
  $content,
  'if \(\$Full\) \{(?<body>.*?)\n\}',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if (-not $fullBlock.Success) {
  throw "Could not find Full-mode normalization block."
}

foreach ($requiredFullSetting in @(
  '$IncludeWindowsSdkDebuggers = $true',
  '$IncludeVisualStudioBuildTools = $true',
  '$IncludeWinDbg = $true',
  '$IncludeLLVMViaWinget = $true',
  '$IncludeFFmpeg = $true',
  '$IncludeCodeQL = $true',
  '$IncludePythonSast = $true'
)) {
  if (-not $fullBlock.Groups["body"].Value.Contains($requiredFullSetting)) {
    throw "Full mode does not enable expected install setting: $requiredFullSetting"
  }
}

foreach ($forbiddenFullSetting in @(
  '$SkipSysinternals = $false',
  '$SkipVSWhere = $false',
  '$SkipSastInstall = $false',
  '$SkipSecretsInstall = $false',
  '$SkipDependencyScannerInstall = $false'
)) {
  if ($fullBlock.Groups["body"].Value.Contains($forbiddenFullSetting)) {
    throw "Full mode overrides an explicit CLI skip switch: $forbiddenFullSetting"
  }
}

if (-not $content.Contains('if ($Wizard -or $PSBoundParameters.Count -eq 0)')) {
  throw "No-argument execution does not automatically enter the wizard."
}

if (-not $content.Contains('0 { Set-FullInstallSelection }')) {
  throw "Default wizard mode should select Full without extra configuration prompts before the final confirmation."
}

Write-Host "Security installer wizard/full-install regression checks passed."
