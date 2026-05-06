#!/usr/bin/env pwsh
#requires -Version 5.1
<#
.SYNOPSIS
  Download pinned GitHub release archives (framework and optional packs), then run afb_init.

.DESCRIPTION
  One-time flow for downstream projects: downloads
  https://github.com/<org>/<repo>/archive/refs/tags/<tag>.zip for the framework tag
  (and each optional pack tag), unpacks under a temp directory, then invokes
  scripts/afb_init.ps1 from the unpacked framework tree.

  Requires network access. Requires PowerShell 5.1+ (or pwsh). Uses Expand-Archive.

.PARAMETER FrameworkTag
  Git tag for trunk assets (example: framework-v0.1.1).

.PARAMETER PackTag
  Zero or more pack tags (example: pack-kotlin-v0.1.1, pack-python-v0.1.1).

.PARAMETER Target
  Destination project directory (default: current directory).

.PARAMETER GitHubOrg
  GitHub organization or user (default: arioch666).

.PARAMETER GitHubRepo
  Repository name (default: AgentFrameworkBootstrap).

.PARAMETER DryRun
  Print URLs and the planned afb_init invocation; do not download or modify the target.

.PARAMETER SkipCleanup
  Leave the temp download directory on disk (for debugging).

.PARAMETER AllowDirtyGit
  If the target is a git repo with a dirty working tree, proceed anyway (default: abort).

.PARAMETER SkipSpecKit, SkipCursor, SkipAgentsMd, NoCanonicalMemory
  Passed through to afb_init.ps1.

.EXAMPLE
  ./afb_bootstrap.ps1 -FrameworkTag framework-v0.1.1 -Target D:\work\my-app

.EXAMPLE
  ./afb_bootstrap.ps1 -FrameworkTag framework-v0.1.1 -PackTag pack-kotlin-v0.1.1 -Target .
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FrameworkTag,

    [string[]]$PackTag = @(),

    [string]$Target = (Get-Location).Path,

    [string]$GitHubOrg = 'arioch666',

    [string]$GitHubRepo = 'AgentFrameworkBootstrap',

    [switch]$DryRun,

    [switch]$SkipCleanup,

    [switch]$AllowDirtyGit,

    [switch]$SkipSpecKit,
    [switch]$SkipCursor,
    [switch]$SkipAgentsMd,
    [switch]$NoCanonicalMemory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-BootstrapInfo([string]$Message) { Write-Host "afb_bootstrap: $Message" }

function Assert-CleanGitTree {
    param([string]$PathRoot)
    $gitDir = Join-Path $PathRoot '.git'
    if (-not (Test-Path -LiteralPath $gitDir)) { return }
    if ($AllowDirtyGit) {
        Write-BootstrapInfo 'AllowDirtyGit: skipping git cleanliness check.'
        return
    }
    Push-Location $PathRoot
    try {
        $porcelain = git status --porcelain 2>$null
        if ($LASTEXITCODE -ne 0) { return }
        if ($porcelain) {
            throw "Target git repo has uncommitted changes. Commit or stash, or pass -AllowDirtyGit.`n$(($porcelain | Select-Object -First 20) -join "`n")"
        }
    }
    finally {
        Pop-Location
    }
}

function Get-GitHubZipUrl {
    param(
        [string]$Org,
        [string]$Repo,
        [string]$Tag
    )
    return "https://github.com/$Org/$Repo/archive/refs/tags/$Tag.zip"
}

function Expand-GitHubReleaseZip {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$WorkDir,
        [Parameter(Mandatory)][string]$Label
    )
    $zipPath = Join-Path $WorkDir ("$Label.zip")
    Write-BootstrapInfo "Downloading $Url"
    Invoke-WebRequest -Uri $Url -OutFile $zipPath -UseBasicParsing
    $extractInto = Join-Path $WorkDir $Label
    New-Item -ItemType Directory -Path $extractInto -Force | Out-Null
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractInto -Force
    Remove-Item -LiteralPath $zipPath -Force
    $dirs = @(Get-ChildItem -LiteralPath $extractInto -Directory -Force)
    if ($dirs.Count -ne 1) {
        throw "Expected exactly one top-level folder under $extractInto after unzip; found $($dirs.Count)."
    }
    return $dirs[0].FullName
}

$targetPath = if (Test-Path -LiteralPath $Target) {
    (Resolve-Path -LiteralPath $Target).Path
}
else {
    if ($DryRun) {
        Write-BootstrapInfo "[dry-run] Target does not exist yet: $Target (afb_init may create it)"
        $Target
    }
    else {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
        (Resolve-Path -LiteralPath $Target).Path
    }
}

Assert-CleanGitTree -PathRoot $targetPath

$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ('afb-bootstrap-' + [guid]::NewGuid().ToString('n'))
if ($DryRun) {
    Write-BootstrapInfo "[dry-run] Would use temp work dir: $workDir"
}
else {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
}

try {
    $fwUrl = Get-GitHubZipUrl -Org $GitHubOrg -Repo $GitHubRepo -Tag $FrameworkTag
    if ($DryRun) {
        Write-BootstrapInfo "[dry-run] Framework URL: $fwUrl"
        $frameworkRoot = '<unpacked-framework-root>'
    }
    else {
        $frameworkRoot = Expand-GitHubReleaseZip -Url $fwUrl -WorkDir $workDir -Label 'framework'
    }

    $packRoots = [System.Collections.Generic.List[string]]::new()
    $i = 0
    foreach ($tag in $PackTag) {
        if ([string]::IsNullOrWhiteSpace($tag)) { continue }
        $i++
        $url = Get-GitHubZipUrl -Org $GitHubOrg -Repo $GitHubRepo -Tag $tag
        if ($DryRun) {
            Write-BootstrapInfo "[dry-run] Pack URL ($tag): $url"
            [void]$packRoots.Add("<unpacked-pack-$i>")
        }
        else {
            $label = "pack-$i"
            $root = Expand-GitHubReleaseZip -Url $url -WorkDir $workDir -Label $label
            [void]$packRoots.Add($root)
        }
    }

    if ($DryRun) {
        Write-BootstrapInfo '[dry-run] Would run afb_init.ps1 with:'
        Write-Host "  Target:      $targetPath"
        Write-Host "  SourceRepo:  $frameworkRoot"
        foreach ($p in $packRoots) { Write-Host "  PackSource:  $p" }
        return
    }

    $initScript = Join-Path $frameworkRoot 'scripts\afb_init.ps1'
    if (-not (Test-Path -LiteralPath $initScript)) {
        throw "Unpacked framework missing scripts/afb_init.ps1 under: $frameworkRoot"
    }

    $argList = [System.Collections.Generic.List[string]]::new()
    $argList.AddRange(@(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $initScript,
            '-Target', $targetPath,
            '-SourceRepo', $frameworkRoot
        ))
    foreach ($p in $packRoots) {
        $argList.Add('-PackSource')
        $argList.Add($p)
    }
    if ($SkipSpecKit) { $argList.Add('-SkipSpecKit') }
    if ($SkipCursor) { $argList.Add('-SkipCursor') }
    if ($SkipAgentsMd) { $argList.Add('-SkipAgentsMd') }
    if ($NoCanonicalMemory) { $argList.Add('-NoCanonicalMemory') }

    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        Write-BootstrapInfo 'Invoking afb_init via pwsh...'
        & pwsh @argList
    }
    else {
        Write-BootstrapInfo 'pwsh not found; invoking afb_init via Windows PowerShell...'
        & powershell.exe @argList
    }
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    if (-not $DryRun -and -not $SkipCleanup -and (Test-Path -LiteralPath $workDir)) {
        Write-BootstrapInfo "Removing temp dir: $workDir"
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    elseif ($SkipCleanup -and (Test-Path -LiteralPath $workDir)) {
        Write-BootstrapInfo "SkipCleanup: temp dir left at: $workDir"
    }
}

Write-BootstrapInfo 'Done. Commit vendored files in your project when satisfied.'
