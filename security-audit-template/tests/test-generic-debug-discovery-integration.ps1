[CmdletBinding()]
param(
  [string]$InstallerPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "install-security-audit-tools.ps1")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$content = Get-Content -LiteralPath (Resolve-Path -LiteralPath $InstallerPath) -Raw

foreach ($forbidden in @(
  "function Get-WindowsSdkDebuggerArchitectures",
  "function Get-WindowsSdkDebuggerCandidatePaths",
  "function Get-MsvcBinaryToolArchitecturePreferences",
  "function Select-PreferredMsvcToolMatch",
  "function Find-VSTools"
)) {
  if ($content.Contains($forbidden)) {
    throw "Security installer still owns duplicated generic discovery logic: $forbidden"
  }
}

foreach ($required in @(
  "discover-debug-tools.ps1",
  "function Invoke-DebugToolDiscovery",
  "debug-tool-manifest.json",
  "Invoke-DebugToolDiscovery",
  "Test-RequiredToolGate"
)) {
  if (-not $content.Contains($required)) {
    throw "Security installer is missing generic discovery integration marker: $required"
  }
}

Write-Host "Security installer generic debug-discovery integration checks passed."
