<#
.SYNOPSIS
  安裝「粵語小詞庫」的四個小狼毫方案與兩個語言模型。
.DESCRIPTION
  方案：jyut_small（詞級模型）、jyut_small_char（字級模型）、
        jyut_small_simp（詞級模型・簡體）、jyut_small_char_simp（字級模型・簡體）。
  模型：jyut.gram、jyut_char.gram（四個方案共用同兩份模型與同兩份詞庫）。
  只寫入 Rime 用戶目錄，不改動其他方案。
  安裝前會把將被覆蓋的同名檔案備份到本資料夾的 backup\<時間戳>\。
  支援 -DryRun（只顯示動作，不寫入）與 -RimeDir（指定目標，主要供測試用）。
.EXAMPLE
  .\install.ps1 -DryRun
  .\install.ps1
  .\install.ps1 -RimeDir C:\Temp\RimeTest
#>
param(
    [switch]$DryRun,
    [string]$RimeDir
)

$ErrorActionPreference = 'Stop'

$PkgRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SchSrc    = Join-Path $PkgRoot 'schema'
$ModelSrc  = Join-Path $PkgRoot 'model'

$SchemaFiles = @(
    'jyut_small.schema.yaml',
    'jyut_small_char.schema.yaml',
    'jyut_small_simp.schema.yaml',
    'jyut_small_char_simp.schema.yaml',
    'jyut_small.dict.yaml',
    'jyut_small_char.dict.yaml',
    'jyut_small_chars.dict.yaml',
    'jyut_small_basic.dict.yaml',
    'jyut_small_association.dict.yaml',
    'jyut_small_mispronounced.dict.yaml',
    'jyut_small_placenames.dict.yaml',
    'jyut_small_written.dict.yaml',
    'jyut_small_collocation.dict.yaml',
    'jyut_small_local.dict.yaml',
    'jyut_small_longtail.dict.yaml',
    'symbols_cantonese.yaml'
)
$ModelFiles = @('jyut.gram', 'jyut_char.gram')
$WantSchemas = @('jyut_small', 'jyut_small_char', 'jyut_small_simp', 'jyut_small_char_simp')

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

$target = Find-RimeDir
if (-not $target) {
    Write-Host '找不到 Rime 用戶目錄。請先執行一次小狼毫，或手動指定：.\install.ps1 -RimeDir <路徑>' -ForegroundColor Red
    exit 1
}
Write-Step "目標 Rime 用戶目錄：$target"
if (-not (Test-Path $target -PathType Container)) {
    if ($DryRun) {
        Write-Host "（DryRun）目標不存在，實際安裝時會建立：$target"
    } else {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
    }
}

foreach ($name in $SchemaFiles) {
    if (-not (Test-Path (Join-Path $SchSrc $name) -PathType Leaf)) {
        Write-Host "缺少來源檔：schema\$name" -ForegroundColor Red
        exit 1
    }
}
foreach ($name in $ModelFiles) {
    if (-not (Test-Path (Join-Path $ModelSrc $name) -PathType Leaf)) {
        Write-Host "缺少模型檔：model\$name" -ForegroundColor Red
        exit 1
    }
}

$defaultCustom = Join-Path $target 'default.custom.yaml'
$hasDefault = Test-Path $defaultCustom -PathType Leaf

# 列出將被覆蓋的同名檔案
$existing = @()
foreach ($name in ($SchemaFiles + $ModelFiles)) {
    if (Test-Path (Join-Path $target $name) -PathType Leaf) { $existing += $name }
}
Write-Step "將備份 $($existing.Count) 個同名檔案（若為 0 表示全新安裝）"

# 計算 schema_list 需要新增的條目
$addSchemas = @()
if ($hasDefault) {
    $content = Get-Content -LiteralPath $defaultCustom -Raw -Encoding UTF8
    foreach ($s in $WantSchemas) {
        if ($content -notmatch "schema:\s*$s\s*\}") { $addSchemas += $s }
    }
    if ($addSchemas.Count -gt 0) {
        Write-Step "default.custom.yaml 將加入：$($addSchemas -join '、')"
    } else {
        Write-Step 'schema_list 已含四個方案，略過。'
    }
} else {
    Write-Host "提醒：找不到 $defaultCustom。安裝後請手動在 schema_list 加入：" -ForegroundColor Yellow
    $WantSchemas | ForEach-Object { Write-Host "    - {schema: $_}" }
}

if ($DryRun) {
    foreach ($name in $SchemaFiles) { Write-Step "複製 schema\$name" }
    foreach ($name in $ModelFiles) {
        $src = Join-Path $ModelSrc $name
        $dst = Join-Path $target $name
        $skip = (Test-Path $dst -PathType Leaf) -and ((Get-Item $dst).Length -eq (Get-Item $src).Length)
        if ($skip) { Write-Step "model\$name 已存在且大小相同，略過複製" }
        else { Write-Step "複製 model\$name（$([math]::Round((Get-Item $src).Length/1MB,1)) MB）" }
    }
    Write-Host ''
    Write-Host 'DryRun 完成：未寫入任何檔案。'
    exit 0
}

# 備份：優先放在套件資料夾，不可寫時退回 %TEMP%
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $PkgRoot 'backup'
try {
    New-Item -ItemType Directory -Path (Join-Path $backupRoot $stamp) -Force | Out-Null
} catch {
    $backupRoot = Join-Path $env:TEMP 'jyut_small_backup'
    New-Item -ItemType Directory -Path (Join-Path $backupRoot $stamp) -Force | Out-Null
}
$backupDir = Join-Path $backupRoot $stamp
Write-Step "備份目錄：$backupDir"

foreach ($name in $existing) {
    Copy-Item (Join-Path $target $name) (Join-Path $backupDir $name) -Force
}
if ($hasDefault) {
    Copy-Item $defaultCustom (Join-Path $backupDir 'default.custom.yaml') -Force
    $existing += 'default.custom.yaml'
}
$existing | Set-Content -LiteralPath (Join-Path $backupDir '_replaced.txt') -Encoding UTF8
($SchemaFiles + $ModelFiles) | Set-Content -LiteralPath (Join-Path $backupDir '_installed.txt') -Encoding UTF8

foreach ($name in $SchemaFiles) {
    Write-Step "複製 $name"
    Copy-Item (Join-Path $SchSrc $name) (Join-Path $target $name) -Force
}

foreach ($name in $ModelFiles) {
    $src = Join-Path $ModelSrc $name
    $dst = Join-Path $target $name
    if ((Test-Path $dst -PathType Leaf) -and ((Get-Item $dst).Length -eq (Get-Item $src).Length)) {
        Write-Step "$name 已存在且大小相同，略過複製。"
    } else {
        Write-Step "複製 $name（$([math]::Round((Get-Item $src).Length/1MB,1)) MB）"
        Copy-Item $src $dst -Force
    }
}

if ($addSchemas.Count -gt 0) {
    $lines = @(Get-Content -LiteralPath $defaultCustom -Encoding UTF8)
    # 插到 schema_list 最後一條之後（避免追加到檔尾而破壞後面的其他設定）
    $idx = -1
    $indent = '    '
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '^(\s*)-\s*\{?\s*schema:\s*\S+') {
            $idx = $i
            $indent = $Matches[1]
            break
        }
    }
    $newLines = @($addSchemas | ForEach-Object { "$indent- {schema: $_}" })
    if ($idx -ge 0) {
        $out = @($lines[0..$idx]) + $newLines
        if ($idx -lt $lines.Count - 1) { $out += $lines[($idx + 1)..($lines.Count - 1)] }
    } else {
        Write-Host '  找不到 schema_list 條目，改為追加到檔尾；請自行確認 YAML 結構。' -ForegroundColor Yellow
        $out = $lines + $newLines
    }
    [System.IO.File]::WriteAllText($defaultCustom, (($out -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ''
Write-Host '安裝完成。下一步：部署（WeaselDeployer.exe /deploy，或右鍵選單「重新部署」），'
Write-Host '然後在輸入法選單切到「粵語小詞庫（詞級模型）」「粵語小詞庫（字級模型）」'
Write-Host '或對應的簡體版本「粵語小詞庫（詞級模型）(簡體)」「粵語小詞庫（字級模型）(簡體)」。'
