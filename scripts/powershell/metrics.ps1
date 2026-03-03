# ============================================================
# Owl Metrics — Spec vs Code line & character counts
# ============================================================

param(
    [switch]$Breakdown
)

$ErrorActionPreference = "Stop"

# --- File enumeration ---
function Get-FileList {
    $isGitRepo = $false
    try {
        git rev-parse --git-dir 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { $isGitRepo = $true }
    } catch {}

    if ($isGitRepo) {
        $files = git ls-files --cached --others --exclude-standard 2>$null
        if ($files) { return $files }
        return @()
    } else {
        return Get-ChildItem -Recurse -File |
            Where-Object { $_.FullName -notmatch '[/\\]\.git[/\\]' } |
            ForEach-Object {
                $_.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/'
            }
    }
}

# --- Helpers ---
function Test-BinaryFile {
    param([string]$Path)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $checkLen = [Math]::Min($bytes.Length, 8192)
        for ($i = 0; $i -lt $checkLen; $i++) {
            if ($bytes[$i] -eq 0) { return $true }
        }
        return $false
    } catch {
        return $true
    }
}

function Test-SpecPath {
    param([string]$Path)
    return ($Path -match '^specs/' -or $Path -match '^\.specify/')
}

function Get-LineCount {
    param([string]$Path)
    $content = [System.IO.File]::ReadAllText($Path)
    if ($content.Length -eq 0) { return 0 }
    $content = $content -replace "`r", ""
    $lines = ($content -split "`n").Count
    if ($content.EndsWith("`n")) { $lines-- }
    return $lines
}

function Get-NormalizedCharCount {
    param([string]$Path)
    $content = [System.IO.File]::ReadAllText($Path)
    $content = $content -replace "`r", ""
    return [System.Text.Encoding]::UTF8.GetByteCount($content)
}

function Format-Number {
    param([int]$Value)
    return $Value.ToString("N0")
}

function Get-Percentage {
    param([int]$Part, [int]$Total)
    if ($Total -eq 0) { return "N/A" }
    return [string][Math]::Round(($Part * 100.0) / $Total, 0) + "%"
}

# --- Accumulate metrics ---
$specLines = 0
$specChars = 0
$nonSpecLines = 0
$nonSpecChars = 0

$dirData = @{}

$files = Get-FileList
foreach ($file in $files) {
    if (-not $file -or $file.Trim() -eq "") { continue }
    if (-not (Test-Path $file -PathType Leaf)) { continue }
    $item = Get-Item $file -ErrorAction SilentlyContinue
    if ($null -eq $item) { continue }
    if ($item.LinkType -eq "SymbolicLink") { continue }
    if (Test-BinaryFile $file) { continue }

    $lines = Get-LineCount $file
    $chars = Get-NormalizedCharCount $file

    # Determine directory
    if ($file -match '/') {
        $dirName = ($file -split '/')[0] + "/"
    } else {
        $dirName = "."
    }

    $isSpec = Test-SpecPath $file

    if ($isSpec) {
        $specLines += $lines
        $specChars += $chars
        $category = "spec"
    } else {
        $nonSpecLines += $lines
        $nonSpecChars += $chars
        $category = "non-spec"
    }

    if (-not $dirData.ContainsKey($dirName)) {
        $dirData[$dirName] = @{
            Lines = 0
            Chars = 0
            Category = $category
        }
    }
    $dirData[$dirName].Lines += $lines
    $dirData[$dirName].Chars += $chars
}

# --- Compute totals ---
$totalLines = $specLines + $nonSpecLines
$totalChars = $specChars + $nonSpecChars
$linePct = Get-Percentage $specLines $totalLines
$charPct = Get-Percentage $specChars $totalChars

# --- Summary output ---
Write-Host "Spec vs Code Metrics"
Write-Host "===================="
Write-Host ""
Write-Host ("  Spec lines:    {0,10}" -f (Format-Number $specLines))
Write-Host ("  Spec chars:    {0,10}" -f (Format-Number $specChars))
Write-Host ("  Non-spec lines:{0,10}" -f (Format-Number $nonSpecLines))
Write-Host ("  Non-spec chars:{0,10}" -f (Format-Number $nonSpecChars))
Write-Host ""
Write-Host ("  Total lines:   {0,10}" -f (Format-Number $totalLines))
Write-Host ("  Total chars:   {0,10}" -f (Format-Number $totalChars))
Write-Host ""
Write-Host ("  Spec %:  Lines: {0}  |  Chars: {1}" -f $linePct, $charPct)

# --- Breakdown output ---
if ($Breakdown) {
    Write-Host ""
    Write-Host "Breakdown by Directory"
    Write-Host "======================"
    Write-Host ""
    Write-Host ("  {0,-20} {1,-12} {2,8} {3,10}" -f "Directory", "Category", "Lines", "Chars")
    Write-Host ("  {0,-20} {1,-12} {2,8} {3,10}" -f "---------", "--------", "-----", "-----")

    $specDirs = $dirData.GetEnumerator() |
        Where-Object { $_.Value.Category -eq "spec" } |
        Sort-Object { $_.Key }
    $nonSpecDirs = $dirData.GetEnumerator() |
        Where-Object { $_.Value.Category -eq "non-spec" } |
        Sort-Object { $_.Key }

    foreach ($d in $specDirs) {
        Write-Host ("  {0,-20} {1,-12} {2,8} {3,10}" -f $d.Key, $d.Value.Category, (Format-Number $d.Value.Lines), (Format-Number $d.Value.Chars))
    }
    foreach ($d in $nonSpecDirs) {
        Write-Host ("  {0,-20} {1,-12} {2,8} {3,10}" -f $d.Key, $d.Value.Category, (Format-Number $d.Value.Lines), (Format-Number $d.Value.Chars))
    }
}
