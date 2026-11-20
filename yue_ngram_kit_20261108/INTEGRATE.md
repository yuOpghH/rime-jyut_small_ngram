# 粵語 n-gram 接入說明

本包提供兩個語言模型與一組可選詞庫層，供其他**符合 jyut6ping3 編碼格式**的粵拼全拼方案接入。
不綁定方案名稱，也不假設你的方案結構。

---

## 0. 先確認這三件事

| # | 檢查 | 怎麼看 | 不符合會怎樣 |
|---|---|---|---|
| 1 | 你的詞庫碼是**粵拼（Jyutping）** | 打開你的 `.dict.yaml`，看碼是不是 `ngo5 dei6` 這種 | 不是粵拼，模型與詞庫都對不上，不能直接用 |
| 2 | 你的方案使用 Rime 內建 `script_translator` 或 `table_translator` | schema 的 `engine/translators` | 自訂外掛／非 Rime translator 不吃 `grammar` 段 |
| 3 | 你能接受「重新部署」與 200–300 MB 記憶體 | — | 模型是常駐檔，單個約 70 MB |

**聲調**：本包詞庫用**帶調**粵拼（`ngo5 dei6`）。若你的方案是**無調**（`ngo dei`），
詞庫不能直接 import，必須先去掉聲調數字並自行解決同音衝突。
模型本身與聲調無關，無調方案也能掛模型，只是效果略降。

**檔名對應**：`grammar.language` 必須與模型檔名一致。
`language: jyut` → 讀 `jyut.gram`；`language: jyut_char` → 讀 `jyut_char.gram`。
填錯不會報錯，只會靜默不加載。

---

## 1. 兩個模型的差異

| 項目 | `jyut.gram` | `jyut_char.gram` |
|---|---|---|
| 大小 | 77,299,756 bytes | 72,767,532 bytes |
| 訓練單位 | 詞 | 單字（ASCII 字母／數字連續串保持完整） |
| 語料 | `lm_corpus.txt`，123.2 MB／1,336,005 行 | `lm_corpus_char.txt`，135.1 MB／1,336,005 行 |
| 參數 | `lmplz -o 4 --prune 0 1 1 1` | 同左 |
| 適用 | 同音短句較保守；通用 | 長句、常用詞組略好；句末語氣詞可能過度糾正 |

兩者不能同時掛在同一個方案上（一個 `grammar` 段只能指定一個 `language`）。
若要對照，建議準備兩份 schema 或兩份 `.custom.yaml`，分別指向不同 `language`。

---

## 2. 接入方式

### A. 附加層（不動對方主詞庫）

**A-1 用 `import_tables` 掛詞庫**：在你的 prism 詞典（例 `my_scheme.dict.yaml`）的 YAML 標頭加入：

```yaml
import_tables:
  - my_scheme_chars
  - my_scheme_words
  - jyut_small_chars
  - jyut_small_basic
```

並把 `dicts\` 內的檔案放到 Rime 用戶目錄。這會把我們的詞條併進你的同一個詞表，權重直接比較。

**A-2 用第二個 translator**：不改詞庫，只在 `engine/translators` 加一個：

```yaml
engine:
  translators:
    - script_translator@yue_extra

yue_extra:
  tag: abc
  dictionary: jyut_small_basic
  enable_sentence: false
  enable_completion: false
  enable_encoder: false
  enable_user_dict: false
  initial_quality: -5
```

#### 附加層最大的坑：權重尺度

這是實測過的現象，不是理論風險：

- 我們曾掛上一份最高權重約 **142 萬**的附加詞表，而對方固定字序表的權重只有約 **9,000**。
- 相差 2–3 個數量級，附加層直接把固定字序的第 2、3、4 位壓掉，只有第 1 位仍在。
- `initial_quality: -5` 是固定偏移，不是比例縮放，救不回來。
- 衝突往往不是同名條目重複，而是不同字的權重尺度差異，因此「只去重同名條目」無效。

使用附加層時請務必：

1. 先量出現有詞庫／固定表的權重範圍（`min`／`max`）。
2. 把附加詞的權重壓到低於固定表的最小值，或至少讓前 2 碼不重疊。
3. 用最在意的高頻單字碼做前四位回歸測試，確認沒有被擠掉。

### B. 整包替換（用我們的詞庫當主）

把 `dicts\` 全部放到 Rime 用戶目錄，讓你的方案 `dictionary:` 指向 `jyut_small`，
或把 `jyut_small.dict.yaml` 的 `import_tables` 複製進你的 prism 詞典。

- 優點：權重體系一致，不會有尺度衝突。
- 代價：失去你原本的詞庫特色（自訂詞、行業詞、地名等），需要自行補回。
- 建議：只在你原本的詞庫也是「粵典＋維基」體系時才整包替換。

---

## 3. 掛模型

### 3-1 放模型

把 `jyut.gram` 或 `jyut_char.gram` 複製到 **Rime 用戶目錄**（與 `*.schema.yaml` 同一層）。
模型**不進 `build\`**，librime 直接唯讀載入，不需要也不應該編譯它。

或直接執行：

```powershell
.\install_model_only.ps1 -DryRun
.\install_model_only.ps1
.\install_model_only.ps1 -RimeDir "<Rime 使用者目錄>"
```

腳本**不會**修改任何 schema／dict，只會備份同名模型並複製兩個 `.gram`。

### 3-2 在 schema 加入 `grammar`

詞級：

```yaml
grammar:
  language: jyut
  collocation_max_length: 5
  collocation_min_length: 2
  collocation_penalty: -15
  non_collocation_penalty: -5
  weak_collocation_penalty: -100
  rear_penalty: -18
```

字級：參數完全相同，只把 `language` 改為 `jyut_char`。

參數說明：

| 參數 | 作用 | 調大的後果 |
|---|---|---|
| `collocation_max_length` / `min_length` | 模型看多長的搭配 | 範圍太大會變慢，且抓不到短搭配 |
| `collocation_penalty` | 已知搭配的加成（負值＝扣分較少） | 太負 → 模型幾乎不起作用 |
| `non_collocation_penalty` | 未知搭配的懲罰 | 太負 → 過度偏好模型見過的句子，容易出怪句 |
| `weak_collocation_penalty` | 弱搭配 | 同上 |
| `rear_penalty` | 句子尾端 | 影響結尾選字 |

**重要**：`grammar` 只在 `translator` 的 `enable_sentence: true` 時才有意義。
沒有造句，就沒有句子可以讓模型排序。

---

## 4. 相容性檢查清單

- [ ] 詞庫碼是粵拼，且與你的方案一致（帶調／不帶調要對齊）
- [ ] `grammar.language` 的值等於模型檔名（`jyut` → `jyut.gram`；`jyut_char` → `jyut_char.gram`）
- [ ] `translator.enable_sentence: true`
- [ ] `translator` 是 `script_translator` 或 `table_translator`
- [ ] 若使用 `fuzz`：`fuzz` 會把長碼截短，讓短輸入命中長詞，可能出現「比原句更長的怪句」；這是實測現象
- [ ] 已量過詞庫權重範圍，附加層沒有壓過你的固定字序（方式 A）
- [ ] 部署後日誌出現 `use grammar` 與 `found double array image`

註：`enable_completion: true` 會放大 `fuzz` 造成的過度匹配；但實測顯示，關閉
`enable_completion` 對長句首位多字怪句沒有實質幫助，真正的來源是 `fuzz` 截斷規則。

---

## 5. 怎麼驗證模型真的生效

1. 部署後開啟 `%TEMP%\rime.weasel\` 最新的 `*.INFO`，搜 `gram_db`。
   - 詞級應有 `use grammar: jyut`、`found double array image of size 19324928`。
   - 字級應有 `use grammar: jyut_char`、`found double array image of size 18191872`。
2. 對照法：把 `grammar:` 整段註解 → 重新部署 → 同一句再打一次。
   候選排序完全沒變，表示模型沒被載入，或 `enable_sentence` 沒開。
3. 用自己的常用長句做前後對照，記錄加模型前的首位，再加 `grammar` 重打一次。

## 6. 常見失敗

| 症狀 | 可能原因 |
|---|---|
| 部署報 `grammar` 相關錯誤 | librime 版本太舊（無 octagram 模組），升級到 0.15 以上 |
| 日誌找不到 `loaded grammar file` 或 `use grammar` | `language` 與檔名不一致，或模型不在用戶目錄 |
| 模型有載入但排序沒變 | `enable_sentence: false`，或輸入只有單一音節 |
| 加了詞庫後固定字序大亂 | 權重尺度差太多（見 §2 A 的說明） |
| 長句首位是多餘字的怪句 | `fuzz` 造成的過度匹配 |

---

## 7. 詞庫層內容

| 層 | 條目 | 權重範圍 | 說明 |
|---|---:|---|---|
| `jyut_small_chars` | 14,358 | 9,951–1,542,682 | 常用漢字與粵拼 |
| `jyut_small_basic` | 29,972 | 1–1,421,979 | 兩字以上常用詞 |
| `jyut_small_association` | 3,001 | 368,740–1,000,000 | 高頻搭配／聯想詞 |
| `jyut_small_mispronounced` | 2,774 | 1–1,222,514 | 常見誤讀變體 |
| `jyut_small_placenames` | 5,460 | 50,460–842,543 | 香港街道、地名、機構 |
| `jyut_small_written` | 15,847 | 181,570–1,000,000 | 書面語，改善無調同音競爭 |
| `jyut_small_collocation` | 400 | 646,737–850,000 | 跨詞邊界 3–5 字串 |
| `jyut_small_local` | 3 | 700,000–950,000 | 本地新增條目 |
| `jyut_small_longtail` | 49,998 | 159,732–431,930 | 低頻詞，預設不建議掛載 |

權重尺度為 `ln(頻率)×10000`，只在同一讀音內做相對排序；不同層的數值範圍不刻意對齊。
接入前請先量你自己的權重範圍，避免尺度衝突。
