<#
.SYNOPSIS
  卸載／回退「粵語小詞庫」的四個方案（繁體／簡體、詞級／字級）。
.DESCRIPTION
  預設還原最近一次 install.ps1 建立的備份；-List 列出所有備份；-Restore <資料夾> 指定備份；
  -RemoveScheme 額外刪除本方案寫入且備份中不存在的檔案，並從 schema_list 移除。
  支援 -DryRun 與 -RimeDir。
.EXAMPLE
  .\uninstall.ps1 -DryRun
  .\uninstall.ps1
  .\uninstall.ps1 -RemoveScheme
  .\uninstall.ps1 -List
#>
param(
    [switch]$DryRun,
    [switch]$RemoveScheme,
    [switch]$List,
    [string]$Restore,
    [string]$RimeDir
)

$ErrorActionPreference = 'Stop'

$PkgRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupRoots = @((Join-Path $PkgRoot 'backup'), (Join-Path $env:TEMP 'jyut_small_backup')) |
    Where-Object { Test-Path $_ -PathType Container }

function Write-Step([string]$Text) {
    Write-Host ("[{0}] {1}" -f $(if ($DryRun) { 'DryRun' } else { '執行' }), $Text)
}

function Find-RimeDir {
    if ($RimeDir) { return $RimeDir }
    foreach ($p in @('C:\你的輸入法\Rime', (Join-Path $env:APPDATA 'Rime'), (Join-Path $env:USERPROFILE 'AppData\Roaming\Rime'))) {
        if ($p -and (Test-Path $p -PathType Container)) { return $p }
    }
    return $null
}

$backups = @()
foreach ($root in $backupRoots) {
    $backups += Get-ChildItem $root -Directory | Sort-Object Name -Descending
}

if ($List) {
    if ($backups.Count -eq 0) { Write-Host '沒有找到任何備份。' }
    else { $backups | ForEach-Object { "{0}  {1}" -f $_.Name, $_.FullName } }
    exit 0
}

if ($backups.Count -eq 0) {
    if (-not $RemoveScheme) {
        Write-Host '沒有找到備份，無法還原。' -ForegroundColor Red
        Write-Host '若確定要直接移除本方案寫入的檔案，請加 -RemoveScheme。'
        exit 1
    }
    Write-Host '沒有備份：將只執行 -RemoveScheme（刪除本方案的檔案並更新 schema_list）。' -ForegroundColor Yellow
}

if ($backups.Count -gt 0) {
    if ($Restore) {
        $chosen = $backups | Where-Object { $_.Name -eq $Restore } | Select-Object -First 1
        if (-not $chosen -and (Test-Path $Restore)) {
            $fullPath = (Resolve-Path $Restore).Path
            $chosen = $backups | Where-Object { $_.FullName -eq $fullPath } | Select-Object -First 1
        }
    } else {
        $chosen = $backups[0]
    }
    if (-not $chosen) {
        Write-Host "找不到指定備份：$Restore" -ForegroundColor Red
        exit 1
    }
} else {
    $chosen = $null
}

$target = Find-RimeDir
if (-not $target) {
    Write-Host '找不到 Rime 用戶目錄，請用 -RimeDir 指定。' -ForegroundColor Red
    exit 1
}
if ($chosen) {
    Write-Step "備份：$($chosen.FullName)"
}
Write-Step "目標：$target"

$replaced = @()
if ($chosen) {
    $replacedFile = Join-Path $chosen.FullName '_replaced.txt'
    if (Test-Path $replacedFile -PathType Leaf) {
        Get-Content -LiteralPath $replacedFile -Encoding UTF8 | Where-Object { $_.Trim() } | ForEach-Object {
            $name = $_.Trim()
            $replaced += $name
            Write-Step "還原 $name"
            if (-not $DryRun) {
                Copy-Item (Join-Path $chosen.FullName $name) (Join-Path $target $name) -Force
            }
        }
    } else {
        Get-ChildItem $chosen.FullName -File | Where-Object { $_.Name -notlike '_*' } | ForEach-Object {
            $replaced += $_.Name
            Write-Step "還原 $($_.Name)"
            if (-not $DryRun) { Copy-Item $_.FullName (Join-Path $target $_.Name) -Force }
        }
    }
}

if ($RemoveScheme) {
    $installed = @()
    if ($chosen) {
        $installedFile = Join-Path $chosen.FullName '_installed.txt'
        if (Test-Path $installedFile -PathType Leaf) {
            $installed = Get-Content -LiteralPath $installedFile -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
    }
    if ($installed.Count -eq 0) {
        $installed = @('jyut_small.schema.yaml', 'jyut_small_char.schema.yaml',
                       'jyut_small_simp.schema.yaml', 'jyut_small_char_simp.schema.yaml',
                       'jyut_small.dict.yaml', 'jyut_small_char.dict.yaml', 'jyut_small_chars.dict.yaml', 'jyut_small_basic.dict.yaml',
                       'jyut_small_association.dict.yaml', 'jyut_small_mispronounced.dict.yaml',
                       'jyut_small_placenames.dict.yaml', 'jyut_small_written.dict.yaml',
                       'jyut_small_collocation.dict.yaml', 'jyut_small_local.dict.yaml',
                       'jyut_small_longtail.dict.yaml', 'symbols_cantonese.yaml',
                       'jyut.gram', 'jyut_char.gram')
    }
    foreach ($name in $installed) {
        if ($replaced -notcontains $name) {
            Write-Step "刪除 $name"
            if (-not $DryRun) { Remove-Item (Join-Path $target $name) -Force -ErrorAction SilentlyContinue }
        }
    }
    $defaultCustom = Join-Path $target 'default.custom.yaml'
    if (Test-Path $defaultCustom -PathType Leaf) {
        Write-Step '從 schema_list 移除 jyut_small／jyut_small_char／jyut_small_simp／jyut_small_char_simp'
        if (-not $DryRun) {
            $lines = Get-Content -LiteralPath $defaultCustom -Encoding UTF8 |
                Where-Object { $_ -notmatch '^\s*-\s*\{?\s*schema:\s*jyut_small(_char)?(_simp)?\s*\}?\s*$' }
            [System.IO.File]::WriteAllText($defaultCustom, ($lines -join "`n") + "`n", (New-Object System.Text.UTF8Encoding($false)))
        }
    }
}

if ($DryRun) {
    Write-Host ''
    Write-Host 'DryRun 完成：未寫入任何檔案。'
} else {
    Write-Host ''
    Write-Host '回退完成。請重新部署（WeaselDeployer.exe /deploy）後再切換方案。'
}
