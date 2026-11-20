<#
.SYNOPSIS
  只把「粵語小詞庫」的兩個語言模型複製到 Rime 用戶目錄，並印出需要手動加入的設定。
.DESCRIPTION
  模型：jyut.gram（詞級）、jyut_char.gram（字級）。
  grammar.language 必須與檔名一致：jyut → jyut.gram；jyut_char → jyut_char.gram。
  刻意不改你的任何 schema／dict 檔——你的方案結構未知，硬改只會弄壞。
  支援 -DryRun（只顯示動作）與 -RimeDir（指定目標）。
.EXAMPLE
  .\install_model_only.ps1 -DryRun
  .\install_model_only.ps1
  .\install_model_only.ps1 -RimeDir "<Rime 使用者目錄>"
#>
param(
    [switch]$DryRun,
    [string]$RimeDir
)

$ErrorActionPreference = 'Stop'

$KitRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Models  = @('jyut.gram', 'jyut_char.gram')

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

foreach ($name in $Models) {
    if (-not (Test-Path (Join-Path $KitRoot $name) -PathType Leaf)) {
        Write-Host "找不到模型檔：$name" -ForegroundColor Red
        exit 1
    }
}

$target = Find-RimeDir
if (-not $target) {
    Write-Host '找不到 Rime 用戶目錄。請先執行一次小狼毫，或用 -RimeDir 指定。' -ForegroundColor Red
    exit 1
}
Write-Step "Rime 用戶目錄：$target"

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($name in $Models) {
    $src = Join-Path $KitRoot $name
    $dst = Join-Path $target $name
    $needCopy = $true
    if (Test-Path $dst -PathType Leaf) {
        if ((Get-Item $dst).Length -eq (Get-Item $src).Length) {
            $needCopy = $false
            Write-Step "$name 已存在且大小相同，略過複製。"
        } else {
            Write-Step "備份既有 $name → $name.bak-$stamp"
            if (-not $DryRun) { Copy-Item $dst "$dst.bak-$stamp" -Force }
        }
    }
    if ($needCopy) {
        Write-Step "複製 $name（$([math]::Round((Get-Item $src).Length/1MB,1)) MB）"
        if (-not $DryRun) { Copy-Item $src $dst -Force }
    }
}

Write-Host ''
Write-Host '──────────────────────────────────────────────'
Write-Host '接下來請「手動」選一種模型寫進你的方案 schema（或 *.custom.yaml）：'
Write-Host ''
Write-Host '# 詞級模型（jyut.gram）'
Write-Host 'grammar:'
Write-Host '  language: jyut'
Write-Host '  collocation_max_length: 5'
Write-Host '  collocation_min_length: 2'
Write-Host '  collocation_penalty: -15'
Write-Host '  non_collocation_penalty: -5'
Write-Host '  weak_collocation_penalty: -100'
Write-Host '  rear_penalty: -18'
Write-Host ''
Write-Host '# 字級模型（jyut_char.gram）：其餘參數相同，只改 language'
Write-Host '# language: jyut_char'
Write-Host ''
Write-Host '並確認你的 translator 有：'
Write-Host '  enable_sentence: true'
Write-Host ''
Write-Host '（grammar.language: jyut ⇔ jyut.gram；language: jyut_char ⇔ jyut_char.gram）'
Write-Host '──────────────────────────────────────────────'
Write-Host ''
if ($DryRun) {
    Write-Host 'DryRun 完成：未寫入任何檔案。'
} else {
    Write-Host '完成。請重新部署，然後照 INTEGRATE.md §5 驗證模型是否載入。'
}
