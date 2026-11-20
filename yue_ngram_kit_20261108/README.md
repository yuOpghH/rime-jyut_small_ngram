# 粵語 n-gram 接入件（yue_ngram_kit）

給「**已經有自己的粵拼全拼方案**」的人使用：把粵語 4-gram 語言模型，加上（可選的）粵語詞庫層，
接到你現有的 Rime 方案。本包不綁定任何特定方案名稱，也不改你的方案檔。

```
yue_ngram_kit_20261108\
├─ jyut.gram                      詞級模型（77,299,756 bytes）
├─ jyut_char.gram                 字級模型（72,767,532 bytes）
├─ dicts\                         可 import 的詞庫層（碼為 jyut6ping3 帶調粵拼）
│  ├─ jyut_small_chars.dict.yaml          14,358 條
│  ├─ jyut_small_basic.dict.yaml          29,972 條
│  ├─ jyut_small_association.dict.yaml     3,001 條
│  ├─ jyut_small_mispronounced.dict.yaml   2,774 條
│  ├─ jyut_small_placenames.dict.yaml      5,460 條
│  ├─ jyut_small_written.dict.yaml        15,847 條（書面詞，CC BY-SA）
│  ├─ jyut_small_collocation.dict.yaml       400 條（跨詞搭配）
│  ├─ jyut_small_local.dict.yaml               3 條（本地新增）
│  ├─ jyut_small_longtail.dict.yaml       49,998 條（低頻，可選）
│  ├─ jyut_small.dict.yaml                     0 條（只做 import_tables 外殼）
│  └─ jyut_small_char.dict.yaml                0 條（字級方案外殼）
├─ example.schema.patch.yaml      範例：grammar 段＋附加 translator
├─ example.dict.patch.yaml        範例：import_tables 掛詞庫
├─ install_model_only.ps1         只複製兩個模型，不改你的方案
├─ INTEGRATE.md                   完整接入說明
├─ README.md / LICENSE.md
```

## 兩個模型怎麼選

| 模型 | `grammar.language` | 特點 |
|---|---|---|
| `jyut.gram` | `jyut` | 以詞為單位訓練；同音短句較保守 |
| `jyut_char.gram` | `jyut_char` | 以單字為單位訓練；長句、常用詞組略好 |

兩者用同一份語料訓練，參數同為 `lmplz -o 4 --prune 0 1 1 1`。
建議先接入 `jyut.gram`，再用自己的常用句與 `jyut_char.gram` 對照。

## 快速開始

```powershell
.\install_model_only.ps1 -DryRun     # 先看會做什麼
.\install_model_only.ps1             # 只複製兩個模型
.\install_model_only.ps1 -RimeDir "<Rime 使用者目錄>"
```

腳本不會修改你的任何 schema／dict，只會複製模型並印出需要手動加入的 `grammar` 段。
完整接入步驟、權重尺度陷阱與驗證方法見 **`INTEGRATE.md`**。

## 授權

詞庫與模型含粵典（words.hk）衍生內容，相關部分依 NCODL 1.0（僅限非商業）；
維基衍生部分依 CC BY-SA 4.0。詳見 `LICENSE.md`。
