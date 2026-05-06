# afb_merge_agents.ps1 — dot-sourced helpers for additive agents.yml merges (no YAML dependency).

function Get-AfbAgentBlocks {
    param([string]$Content)
    $lines = $Content -split "`r?`n"
    $agentsIdx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^agents:\s*$') {
            $agentsIdx = $i
            break
        }
    }
    if ($agentsIdx -lt 0) { return @() }

    $blocks = [System.Collections.Generic.List[object]]::new()
    $current = $null
    for ($j = $agentsIdx + 1; $j -lt $lines.Count; $j++) {
        $line = $lines[$j]
        if ($line -match '^\s{2}-\s+id:\s+(\S+)\s*$') {
            if ($null -ne $current) { $blocks.Add($current) }
            $current = [ordered]@{
                Id    = $Matches[1]
                Lines = [System.Collections.Generic.List[string]]::new()
            }
            [void]$current.Lines.Add($line)
        }
        elseif ($null -ne $current) {
            [void]$current.Lines.Add($line)
        }
    }
    if ($null -ne $current) { $blocks.Add($current) }
    return $blocks
}

function Get-AfbAgentIds {
    param([string]$Content)
    $ids = [System.Collections.Generic.List[string]]::new()
    foreach ($b in (Get-AfbAgentBlocks -Content $Content)) {
        [void]$ids.Add($b.Id)
    }
    return $ids
}

function Get-AfbCanDelegateTo {
    param([string]$Content)
    $lines = $Content -split "`r?`n"
    $inDelegationMatrix = $false
    $inOrchestration = $false
    $inList = $false
    $ids = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $lines) {
        if ($line -match '^delegation_matrix:\s*$') {
            $inDelegationMatrix = $true
            $inOrchestration = $false
            $inList = $false
            continue
        }
        if ($inDelegationMatrix -and $line -match '^[a-z_]+:\s*$') {
            # Left delegation_matrix (next top-level YAML key)
            break
        }
        if ($inDelegationMatrix -and $line -match '^\s{2}orchestration:\s*$') {
            $inOrchestration = $true
            $inList = $false
            continue
        }
        if ($inOrchestration -and $line -match '^\s{2}[a-z_]+:\s*$' -and $line -notmatch '^\s{2}orchestration:\s*$') {
            # Next key under delegation_matrix (e.g. planning:)
            break
        }
        if ($inOrchestration -and $line -match '^\s{4}can_delegate_to:\s*$') {
            $inList = $true
            continue
        }
        if ($inList) {
            if ($line -match '^\s{6}-\s+(\S+)\s*$') {
                [void]$ids.Add($Matches[1])
                continue
            }
            if ($line -match '^\s{4}[a-z_]+:\s*$') {
                break
            }
        }
    }
    return $ids
}

function Merge-AfbAgentsYamlContent {
    param(
        [Parameter(Mandatory)][string]$SourceContent,
        [Parameter(Mandatory)][string]$TargetContent
    )
    $srcBlocks = Get-AfbAgentBlocks -Content $SourceContent
    $tgtIds = [System.Collections.Generic.HashSet[string]]::new([string[]](Get-AfbAgentIds -Content $TargetContent))
    $toAppend = [System.Collections.Generic.List[object]]::new()
    foreach ($b in $srcBlocks) {
        if (-not $tgtIds.Contains($b.Id)) {
            $toAppend.Add($b)
            [void]$tgtIds.Add($b.Id)
        }
    }

    $out = $TargetContent.TrimEnd()
    if ($toAppend.Count -gt 0) {
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine($out)
        foreach ($b in $toAppend) {
            foreach ($ln in $b.Lines) {
                [void]$sb.AppendLine($ln)
            }
        }
        $out = $sb.ToString().TrimEnd()
    }

    $srcDel = [System.Collections.Generic.HashSet[string]]::new([string[]](Get-AfbCanDelegateTo -Content $SourceContent))
    $tgtDel = [System.Collections.Generic.HashSet[string]]::new([string[]](Get-AfbCanDelegateTo -Content $out))
    $addDel = [System.Collections.Generic.List[string]]::new()
    foreach ($x in $srcDel) {
        if (-not $tgtDel.Contains($x)) { [void]$addDel.Add($x) }
    }

    if ($addDel.Count -eq 0) { return $out }

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($ln in ($out -split "`r?`n")) { [void]$lines.Add($ln) }

    $insertBefore = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s{2}planning:\s*$') {
            $insertBefore = $i
            break
        }
    }
    if ($insertBefore -lt 0) {
        throw 'Merge-AfbAgentsYamlContent: could not find delegation_matrix.orchestration sibling key "planning:" to insert can_delegate_to entries.'
    }

    for ($k = $addDel.Count - 1; $k -ge 0; $k--) {
        $id = $addDel[$k]
        $lines.Insert($insertBefore, "      - $id")
    }

    return ($lines -join "`n")
}

function Merge-AfbAgentsYamlFile {
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [Parameter(Mandatory)][string]$TargetPath,
        [switch]$DryRun
    )
    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Source agents.yml not found: $SourcePath"
    }
    $src = Get-Content -LiteralPath $SourcePath -Raw -Encoding utf8
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        if ($DryRun) {
            Write-Host "[dry-run] Would create $TargetPath from $SourcePath"
            return
        }
        $parent = Split-Path -Parent $TargetPath
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Set-Content -LiteralPath $TargetPath -Value $src -Encoding utf8 -NoNewline
        return
    }
    $tgt = Get-Content -LiteralPath $TargetPath -Raw -Encoding utf8
    $merged = Merge-AfbAgentsYamlContent -SourceContent $src -TargetContent $tgt
    if ($DryRun) {
        if ($merged -ne $tgt) {
            Write-Host "[dry-run] Would update $TargetPath (agents / delegation merge from $SourcePath)"
        }
        return
    }
    Set-Content -LiteralPath $TargetPath -Value $merged -Encoding utf8 -NoNewline
}
