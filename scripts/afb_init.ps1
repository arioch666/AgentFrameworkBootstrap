#!/usr/bin/env pwsh
#requires -Version 5.1
<#
.SYNOPSIS
  Bootstrap AgentFrameworkBootstrap assets into a downstream project (afb_init).

.DESCRIPTION
  - Merges/copies `.agents/`, `.agents/.skills/`, and `agents.yml` (additive merge).
  - Ensures Spec Kit scaffolding under `.specify/` when missing (skips full scaffold when `.specify` already exists).
  - Ensures canonical project memory at `ai/memory/memory.md` and optional per-agent delegated stubs.
  - Optionally copies Cursor rules/skills and root `AGENTS.md`.

.PARAMETER Target
  Destination project root (default: current directory).

.PARAMETER SourceRepo
  Path to a checkout of AgentFrameworkBootstrap (default: parent of this `scripts/` folder).

.PARAMETER PackSource
  Additional repo roots (e.g. checkouts of `python` / `kotlin` pack branches) merged after the trunk.

.PARAMETER DryRun
  Print actions without writing files.

.PARAMETER SkipSpecKit
  Do not copy or validate `.specify/` scaffolding.

.PARAMETER SkipCursor
  Do not copy `.cursor/` rules and skills.

.PARAMETER SkipAgentsMd
  Do not copy root `AGENTS.md` when missing.

.PARAMETER NoCanonicalMemory
  Do not create `ai/memory/memory.md` or rewrite per-agent `.memory/memory.md` stubs.

.PARAMETER ValidateOnly
  Run validation checks and exit (non-zero if issues found).

.EXAMPLE
  ./afb_init.ps1 -Target D:\myapp

.EXAMPLE
  ./afb_init.ps1 -Target D:\myapp -PackSource D:\packs\AgentFrameworkBootstrap-python -DryRun
#>
[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [string]$SourceRepo = '',
    [string[]]$PackSource = @(),
    [switch]$DryRun,
    [switch]$SkipSpecKit,
    [switch]$SkipCursor,
    [switch]$SkipAgentsMd,
    [switch]$NoCanonicalMemory,
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Lib = Join-Path $PSScriptRoot 'lib\afb_merge_agents.ps1'
if (-not (Test-Path -LiteralPath $Lib)) {
    throw "Missing merge library: $Lib"
}
. $Lib

if (-not $SourceRepo) {
    $SourceRepo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
}

if (-not (Test-Path -LiteralPath $SourceRepo)) {
    throw "SourceRepo not found: $SourceRepo"
}

function Resolve-AfbPath {
    param([string]$PathLike)
    if ([string]::IsNullOrWhiteSpace($PathLike)) { return $PathLike }
    return (Resolve-Path -LiteralPath $PathLike).Path
}

function Write-AfbInfo { param([string]$Message) Write-Host "afb_init: $Message" }
function Write-AfbWarn { param([string]$Message) Write-Warning "afb_init: $Message" }

function Copy-AfbDirectoryMerge {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [switch]$DryRun
    )
    if (-not (Test-Path -LiteralPath $SourceDir)) {
        throw "Source directory not found: $SourceDir"
    }
    if ($DryRun) {
        Write-AfbInfo "[dry-run] Merge-copy folder: $SourceDir -> $DestDir"
        return
    }
    if (-not (Test-Path -LiteralPath $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Get-ChildItem -LiteralPath $SourceDir -Force | ForEach-Object {
        $destPath = Join-Path $DestDir $_.Name
        Copy-Item -LiteralPath $_.FullName -Destination $destPath -Recurse -Force
    }
}

function Initialize-AfbSpecKitScaffold {
    param(
        [string]$FrameworkRoot,
        [string]$DestRoot,
        [switch]$DryRun
    )
    $specDst = Join-Path $DestRoot '.specify'
    if (Test-Path -LiteralPath $specDst) {
        Write-AfbInfo 'Spec Kit: `.specify` already exists — skipping scaffold (validate or update manually).'
        $need = @(
            (Join-Path $specDst 'integration.json'),
            (Join-Path $specDst 'templates\agent-file-template.md'),
            (Join-Path $specDst 'templates\commands\onboarding.md'),
            (Join-Path $specDst 'scripts\powershell\common.ps1')
        )
        foreach ($p in $need) {
            if (-not (Test-Path -LiteralPath $p)) {
                Write-AfbWarn "Spec Kit validation: expected file missing: $p"
            }
        }
        return
    }

    $specSrc = Join-Path $FrameworkRoot '.specify'
    if (-not (Test-Path -LiteralPath $specSrc)) {
        throw "Framework `.specify` not found under: $FrameworkRoot"
    }

    $subdirs = @('templates', 'scripts', 'workflows', 'integrations')
    foreach ($d in $subdirs) {
        $s = Join-Path $specSrc $d
        if (Test-Path -LiteralPath $s) {
            $dd = Join-Path $specDst $d
            if ($DryRun) {
                Write-AfbInfo "[dry-run] Would copy $s -> $dd"
            }
            else {
                Copy-Item -LiteralPath $s -Destination $dd -Recurse -Force
            }
        }
    }

    foreach ($f in @('integration.json', 'init-options.json')) {
        $sf = Join-Path $specSrc $f
        if (Test-Path -LiteralPath $sf) {
            $df = Join-Path $specDst $f
            if ($DryRun) {
                Write-AfbInfo "[dry-run] Would copy $sf -> $df"
            }
            else {
                $parent = Split-Path -Parent $df
                if (-not (Test-Path -LiteralPath $parent)) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }
                Copy-Item -LiteralPath $sf -Destination $df -Force
            }
        }
    }

    $memSrc = Join-Path $specSrc 'memory\constitution.md'
    if (Test-Path -LiteralPath $memSrc) {
        $memDstDir = Join-Path $specDst 'memory'
        $memDst = Join-Path $memDstDir 'constitution.md'
        if ($DryRun) {
            Write-AfbInfo "[dry-run] Would copy $memSrc -> $memDst"
        }
        else {
            if (-not (Test-Path -LiteralPath $memDstDir)) {
                New-Item -ItemType Directory -Path $memDstDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $memSrc -Destination $memDst -Force
        }
    }

    $specsReadme = Join-Path $specDst 'specs\README.md'
    if (-not (Test-Path -LiteralPath $specsReadme) -and -not $DryRun) {
        $specsDir = Split-Path -Parent $specsReadme
        if (-not (Test-Path -LiteralPath $specsDir)) {
            New-Item -ItemType Directory -Path $specsDir -Force | Out-Null
        }
        @'
# Spec Kit specs

Create initiative folders under `.specify/specs/<FeatureId>/` per `docs/conventions.md` (or your local copy of that contract).

FeatureId format: `NNN-kebab-case-short-name`.
'@ | Set-Content -LiteralPath $specsReadme -Encoding utf8
    }
    elseif (-not (Test-Path -LiteralPath $specsReadme) -and $DryRun) {
        Write-AfbInfo "[dry-run] Would create $specsReadme"
    }

    Write-AfbInfo 'Spec Kit: scaffold copied (initiatives under `.specify/specs/` are not copied).'
}

function Ensure-AfbCanonicalMemoryFile {
    param(
        [string]$FrameworkRoot,
        [string]$DestRoot,
        [switch]$DryRun
    )
    $dest = Join-Path $DestRoot 'ai\memory\memory.md'
    if (Test-Path -LiteralPath $dest) {
        return
    }
    $template = Join-Path $FrameworkRoot 'ai\memory\memory.md'
    if ($DryRun) {
        Write-AfbInfo "[dry-run] Would create $dest"
        return
    }
    $parent = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path -LiteralPath $template) {
        Copy-Item -LiteralPath $template -Destination $dest -Force
    }
    else {
        @'
# Project memory (canonical)

**Single source of truth** for durable facts, decisions, and continuity across assistants.
Keep content safe to commit—no secrets.

## Log

- YYYY-MM-DD — Initialized via `afb_init`.
'@ | Set-Content -LiteralPath $dest -Encoding utf8
    }
}

function Set-AfbDelegatedAgentMemories {
    param(
        [string]$DestRoot,
        [switch]$DryRun
    )
    $agentsDir = Join-Path $DestRoot '.agents'
    if (-not (Test-Path -LiteralPath $agentsDir)) { return }

    $stub = @'
# Delegated memory

Long-lived project memory lives in the repository at **[`ai/memory/memory.md`](../../../ai/memory/memory.md)** (path relative from this file).

Do not rely on device-local vendor memory for facts that belong in git.

## Scratch (optional)


'@

    Get-ChildItem -LiteralPath $agentsDir -Directory -Force |
        Where-Object { $_.Name -cne '.skills' } |
        ForEach-Object {
            $memFile = Join-Path $_.FullName '.memory\memory.md'
            if ($DryRun) {
                Write-AfbInfo "[dry-run] Would write delegated memory stub: $memFile"
            }
            else {
                $memDir = Split-Path -Parent $memFile
                if (-not (Test-Path -LiteralPath $memDir)) {
                    New-Item -ItemType Directory -Path $memDir -Force | Out-Null
                }
                Set-Content -LiteralPath $memFile -Value $stub -Encoding utf8
            }
        }
}

function Test-AfbProject {
    param([string]$Root)
    $issues = [System.Collections.Generic.List[string]]::new()

    $ymlPath = Join-Path $Root 'agents.yml'
    if (-not (Test-Path -LiteralPath $ymlPath)) {
        [void]$issues.Add('Missing agents.yml at repo root.')
        return $issues
    }

    $yml = Get-Content -LiteralPath $ymlPath -Raw -Encoding utf8

    $idMatches = [regex]::Matches($yml, '(?m)^\s{2}-\s+id:\s+(\S+)\s*$')
    $ids = @($idMatches | ForEach-Object { $_.Groups[1].Value })
    $dup = @($ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    foreach ($d in $dup) {
        [void]$issues.Add("Duplicate agents.yml entry for id: $d")
    }

    $agentsRoot = Join-Path $Root '.agents'
    if (Test-Path -LiteralPath $agentsRoot) {
        Get-ChildItem -LiteralPath $agentsRoot -Directory -Force |
            Where-Object { $_.Name -cne '.skills' } |
            ForEach-Object {
                $name = $_.Name
                $escaped = [regex]::Escape($name)
                $patUnix = "(?m)path:\s*\.agents/$escaped\s*$"
                $patWin = "(?m)path:\s*\.agents\\$escaped\s*$"
                if ($yml -notmatch $patUnix -and $yml -notmatch $patWin) {
                    [void]$issues.Add("Orphan `.agents/$name` folder (no matching `path: .agents/$name` in agents.yml).")
                }
            }
    }

    $canon = 'ai/memory/memory.md'
    $watch = @(
        (Join-Path $Root 'CLAUDE.md'),
        (Join-Path $Root 'GEMINI.md'),
        (Join-Path $Root (Join-Path '.cursor' (Join-Path 'rules' 'specify-rules.mdc'))),
        (Join-Path $Root (Join-Path '.cursor' (Join-Path 'rules' 'spec-kit-workflow.md')))
    )
    foreach ($f in $watch) {
        if (Test-Path -LiteralPath $f) {
            $raw = Get-Content -LiteralPath $f -Raw -Encoding utf8
            if ($raw -notmatch 'ai/memory/memory\.md') {
                [void]$issues.Add("AI context file should reference canonical memory ($canon): $f")
            }
        }
    }

    if (-not (Test-Path -LiteralPath (Join-Path $Root $canon))) {
        [void]$issues.Add("Missing canonical memory file: $canon")
    }

    return $issues
}

if ($ValidateOnly) {
    if (-not (Test-Path -LiteralPath $Target)) {
        throw "ValidateOnly: Target not found: $Target"
    }
    $vRoot = (Resolve-Path -LiteralPath $Target).Path
    $issues = Test-AfbProject -Root $vRoot
    if (@($issues).Count -eq 0) {
        Write-Host "afb_init: Validation OK for $vRoot"
        exit 0
    }
    foreach ($i in @($issues)) { Write-Warning "afb_init: $i" }
    exit 2
}

$TargetRoot = $Target
if (-not (Test-Path -LiteralPath $TargetRoot)) {
    if ($DryRun) {
        Write-AfbInfo "[dry-run] Target does not exist yet (would create): $TargetRoot"
    }
    else {
        New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
    }
}
$TargetRoot = Resolve-AfbPath $TargetRoot

Write-AfbInfo "Source framework: $SourceRepo"
Write-AfbInfo "Target project:  $TargetRoot"

# --- Trunk assets ---
$srcAgents = Join-Path $SourceRepo '.agents'
if (-not (Test-Path -LiteralPath $srcAgents)) {
    throw "No `.agents` folder under framework root: $SourceRepo"
}

Copy-AfbDirectoryMerge -SourceDir $srcAgents -DestDir (Join-Path $TargetRoot '.agents') -DryRun:$DryRun

$targetYml = Join-Path $TargetRoot 'agents.yml'
$sourceYml = Join-Path $SourceRepo 'agents.yml'
Merge-AfbAgentsYamlFile -SourcePath $sourceYml -TargetPath $targetYml -DryRun:$DryRun

if (-not $SkipAgentsMd) {
    $dstAg = Join-Path $TargetRoot 'AGENTS.md'
    $srcAg = Join-Path $SourceRepo 'AGENTS.md'
    if ((-not (Test-Path -LiteralPath $dstAg)) -and (Test-Path -LiteralPath $srcAg)) {
        if ($DryRun) {
            Write-AfbInfo "[dry-run] Would copy $srcAg -> $dstAg"
        }
        else {
            Copy-Item -LiteralPath $srcAg -Destination $dstAg -Force
        }
    }
}

if (-not $SkipCursor) {
    $cSrc = Join-Path $SourceRepo '.cursor'
    if (Test-Path -LiteralPath $cSrc) {
        Copy-AfbDirectoryMerge -SourceDir $cSrc -DestDir (Join-Path $TargetRoot '.cursor') -DryRun:$DryRun
    }
}

if (-not $SkipSpecKit) {
    Initialize-AfbSpecKitScaffold -FrameworkRoot $SourceRepo -DestRoot $TargetRoot -DryRun:$DryRun
}

if (-not $NoCanonicalMemory) {
    Ensure-AfbCanonicalMemoryFile -FrameworkRoot $SourceRepo -DestRoot $TargetRoot -DryRun:$DryRun
    Set-AfbDelegatedAgentMemories -DestRoot $TargetRoot -DryRun:$DryRun
}

foreach ($pack in $PackSource) {
    if ([string]::IsNullOrWhiteSpace($pack)) { continue }
    if (-not (Test-Path -LiteralPath $pack)) {
        throw "PackSource not found: $pack"
    }
    $packRoot = Resolve-AfbPath $pack
    Write-AfbInfo "Merging pack: $packRoot"
    $pAgents = Join-Path $packRoot '.agents'
    if (Test-Path -LiteralPath $pAgents) {
        Copy-AfbDirectoryMerge -SourceDir $pAgents -DestDir (Join-Path $TargetRoot '.agents') -DryRun:$DryRun
    }
    $pYml = Join-Path $packRoot 'agents.yml'
    if (Test-Path -LiteralPath $pYml) {
        Merge-AfbAgentsYamlFile -SourcePath $pYml -TargetPath $targetYml -DryRun:$DryRun
    }
}

if ($DryRun) {
    Write-AfbInfo 'Skipping post-run validation in -DryRun (no files written yet).'
}
else {
    Write-AfbInfo 'Running validation...'
    $postIssues = Test-AfbProject -Root $TargetRoot
    foreach ($i in @($postIssues)) {
        Write-AfbWarn $i
    }

    if (@($postIssues).Count -gt 0) {
        Write-AfbWarn 'Validation reported issues (see above). Exit code 2.'
        exit 2
    }
}

Write-AfbInfo 'Done.'
exit 0
