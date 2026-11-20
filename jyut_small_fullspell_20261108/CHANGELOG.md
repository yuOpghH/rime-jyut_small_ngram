# CHANGELOG／本包的來歷

## 1.2（2026-11-20）

- 新增兩個簡體方案：`jyut_small_simp`（詞級）、`jyut_small_char_simp`（字級）。
  四個方案共用同兩份詞庫與同兩份模型，只以 `schema_id`、顯示名與預設用字區分。
- 同步 Rime 端最新 `jyut_small.schema.yaml`（5,590 B）、`jyut_small_char.schema.yaml`（5,606 B）：
  `options` 新增 `reset: 1`，預設用字改為香港傳統漢字。
- `jyut_small_mispronounced.dict.yaml` 換為 Rime 端新版（38,167 B）：鍵值 2,759 → 2,774，
  1,528 條權重下調為 1、刪除 5 條舊音、新增 18 條新音。
- 安裝腳本移除套件完整性校驗流程與相關參數，只保留原有的備份與複製行為；
  套件內不再附帶校驗清單檔。
- `schema\` 由 14 個 yaml 增至 16 個；`install.ps1`／`uninstall.ps1` 清單同步。

## 版本

- 版本：`1.2`（2026-11-20）
- 適用：小狼毫 Weasel 0.17.4／librime 1.13.1（應相容 0.15 以上）
- 方案 ID：`jyut_small`、`jyut_small_char`、`jyut_small_simp`、`jyut_small_char_simp`
- 與 1.1（2026-11-08）的差別：新增兩個簡體方案；同步 schema 與錯音詞庫；
  安裝腳本移除套件完整性校驗流程。
- 與 1.0（2026-11-07）的差別：由單一方案擴充為兩個方案、兩個模型；詞庫加入本地層；
  移除無模型對照方案 `jyut_small_nolm`（需要對照時，把 `grammar:` 整段註解即可）。

## 四個方案

| 方案 | `schema_id` | 顯示名 | `dictionary` | `grammar.language` |
|---|---|---|---|---|
| 詞級 | `jyut_small` | 粵語小詞庫（詞級模型） | `jyut_small` | `jyut` |
| 字級 | `jyut_small_char` | 粵語小詞庫（字級模型） | `jyut_small_char` | `jyut_char` |
| 詞級・簡 | `jyut_small_simp` | 粵語小詞庫（詞級模型）(簡體) | `jyut_small` | `jyut` |
| 字級・簡 | `jyut_small_char_simp` | 粵語小詞庫（字級模型）(簡體) | `jyut_small_char` | `jyut_char` |

詞級與字級之間只差 `schema_id`、`name`、`translator.dictionary`、`grammar.language`；
繁體與簡體之間只差 `schema_id`、`name`、`options` 的 `reset`（1／3）、
`simplification` 的 `reset`（0／1）。其餘內容相同。

詞級兩個方案共用 `build\jyut_small.*`，字級兩個方案共用 `build\jyut_small_char.*`；
方案數增加不會增加部署時編譯的詞表數量。

## 詞庫（`schema\*.dict.yaml`）

碼為**帶調粵拼（jyut6ping3 格式）**：音節以空格分隔，聲調用 1–6 數字，例 `ngo5 dei6`。
每行格式為 `文字 <TAB> 碼 <TAB> 權重`。

| 層 | 檔名 | 條目 | 權重範圍 | 內容 |
|---|---|---:|---|---|
| 單字 | `jyut_small_chars` | 14,358 | 9,951–1,542,682 | 常用漢字與粵拼 |
| 核心詞 | `jyut_small_basic` | 29,972 | 1–1,421,979 | 兩字以上常用詞 |
| 聯想 | `jyut_small_association` | 3,001 | 368,740–1,000,000 | 高頻搭配／聯想詞 |
| 錯音 | `jyut_small_mispronounced` | 2,774 | 1–1,222,514 | 常見誤讀變體 |
| 地名 | `jyut_small_placenames` | 5,460 | 50,460–842,543 | 香港街道、地名、機構 |
| 書面詞 | `jyut_small_written` | 15,847 | 181,570–1,000,000 | 維基／新聞書面語 |
| 搭配詞 | `jyut_small_collocation` | 400 | 646,737–850,000 | 跨詞邊界 3–5 字串 |
| 本地層 | `jyut_small_local` | 3 | 700,000–950,000 | 本次新增條目（呢@ni、呢@ne、我仲係） |
| 長尾（預設不掛） | `jyut_small_longtail` | 49,998 | 159,732–431,930 | 低頻詞，需手動打開 |

預設掛載合計 **71,815 條**（不含長尾）。長尾層檔案隨包附上但不列入 `import_tables`；
需要時在 `jyut_small.dict.yaml` 取消註解並重新部署。

### 權重怎麼來

- 基礎：粵典（words.hk）詞頻取對數映射，尺度為 `ln(頻率)×10000`。
  權重只在同一讀音內做相對排序，不同層的數值範圍不刻意對齊。
- 書面詞層：`zhwiki_sample`、`zh_wiki_yue_long`、`raptorkwok` 等語料，
  2–4 字、出現 ≥5 次、跨 ≥2 來源、有粵拼；排除口語語氣詞、粗口、既有聯想詞。
- 搭配詞層：同句相鄰 token 串接，3–5 字，跨 ≥2 個書面來源且 ≥2 次，或單一來源 ≥20 次。
- 本地層：只放本次新增條目，既有詞的權重改動留在原層就地調整。

## 語言模型（`model\*.gram`）

| 項目 | `jyut.gram`（詞級） | `jyut_char.gram`（字級） |
|---|---|---|
| 大小 | 77,299,756 bytes（73.7 MB） | 72,767,532 bytes（69.4 MB） |
| 格式 | `Rime::Grammar/1.0` ＋ Darts 雙陣列 | 同左 |
| 階數 | 4-gram | 4-gram |
| 切詞 | 以詞為單位 | 以單字為單位 |
| 訓練語料 | `data\seg\lm_corpus.txt`，123.2 MB／1,336,005 行 | `data\seg\lm_corpus_char.txt`，135.1 MB／1,336,005 行 |
| ARPA n-gram 數 | 1:637,909／2:1,896,085／3:2,428,523／4:1,943,253 | 1:112,292／2:1,103,614／3:3,446,211／4:3,963,275 |
| Darts 陣列 | 19,324,928 units | 18,191,872 units |

兩者訓練參數同為 `lmplz -o 4 --prune 0 1 1 1`，語料來源與權重相同；
字級模型只是把每句再切成單字（ASCII 字母／數字連續串保持完整，標點自成邊界）。
ARPA 經 `scripts\14_build_grammar.py`（或字級版 `32_build_char_grammar.py`）轉成
`hex(key)\tfreq` 表，再由 `model\work\build_gram.exe` 建成 librime-octagram 可讀的 Darts 影像。

原 KenLM 訓練檔僅供留存，Rime 不載入，**不在本包內**。

## 已知限制

- **同音競爭**：無調輸入必然大量同音（`jyu geoi` → 語句／雨具），靠詞庫權重緩解，不可能全對。
- **模型偏好高頻搭配**：口語短句可能被過度糾正（例 `我好鍾意你` 被推向「呢」）。
- **書面語比例偏高**：語料以維基、新聞類為主，口語長句改善有限。
- **分詞敏感**：連打靠音節切分，切錯整句就錯；建議詞間留空格。
- **4-gram 模型**：超長句增益遞減；記憶體佔用約 200–300 MB、首次部署較慢。
- **字級句末語氣詞**：字級模型在句末「㗎嘛」仍可能輸出「加碼」，屬已知現狀。
- 詞庫以**香港粵語**為準，其他粵語區用詞可能缺漏。
- 長尾詞庫預設關閉（約 5 萬條，以體積與部署時間換取覆蓋率）。

## 不含什麼

- 不放雙拼版本（`jyut_sp`、`jyut_sp4` 系列）與任何實驗方案。
- 不放第三方 reorder 外掛及其 `.custom.yaml` 補丁；本包安裝後的行為不含 reorder。
- 不放粵典原始匯出檔、原始語料與訓練中間檔。
- 不安裝或修改任何使用者既有的學習庫（`*.userdb`）。
