# 授權與語料來源

- 核實日期：2026-11-08
- 本檔說明：這個包裡每一部分能否再散佈、需要附上什麼告示。

---

## 1. 粵典（words.hk）：《非商業開放資料授權協議 1.0》（NCODL）

版權持有人：**Hong Kong Lexicography Limited（香港辭書有限公司）**，2015–2025。
官方頁面 <https://words.hk/base/hoifong/>。

| 條款 | 內容 |
|---|---|
| 1(a) | 不得作商業用途（免費、非牟利散佈可以） |
| 1(b)(i) | 每次發佈都要附版權告示、免責聲明、Credits List（見第 4 節全文） |
| 1(b)(ii) | 標示來源網站 <https://words.hk> |
| 1(c) | 不得以授權人名義背書 |
| 1(d) | **不得再授權**（no sub-license），不可改掛 MIT／CC0 |

沒有 share-alike 條款；限制是「不可商用＋不可再授權＋必須署名」。

本包內由粵典衍生的**詞形與粵拼**隨包散佈，按 NCODL 1.0；粵典的原始匯出檔（字表／詞表／頻率檔）
**不在本包內**。

## 2. 其他來源

| 來源 | 授權 | 可否再散佈 | 相同方式分享 |
|---|---|---|---|
| raptorkwok/cantonese-chinese-parallel-corpus-base | CC0-1.0 | 可，可商用 | 否 |
| fcbond/hkcancor（HKCanCor） | CC BY 4.0 | 可，可商用 | 否（需署名） |
| izhx/yue-lihkg-topic | CC BY 4.0 | 可，可商用 | 否（需署名）；僅用於語言模型 |
| R5dwMg/zh-wiki-yue-long | CC BY-SA | 可，可商用 | **是** |
| zh_yuewiki／zhwiki（Wikimedia 快照） | CC BY-SA 3.0／4.0 ＋ GFDL | 可，可商用 | **是** |

## 3. 本包各部分的授權

| 部分 | 授權 |
|---|---|
| 方案檔、安裝／卸載腳本、文件 | 本專案自有著作，CC BY-SA 4.0 |
| `jyut_small_chars/basic/association/mispronounced/placenames.dict.yaml` | 含粵典衍生詞形與粵拼 → **NCODL 1.0（僅非商業）**，並含 CC BY 4.0／CC0 語料 |
| `jyut_small_written.dict.yaml`、`jyut_small_collocation.dict.yaml` | 由維基（CC BY-SA）與 CC0／CC BY 語料衍生 → **CC BY-SA 4.0** |
| `jyut_small_local.dict.yaml` | 本專案自訂條目 → CC BY-SA 4.0 |
| `jyut.gram`（詞級模型） | 訓練語料含 CC BY-SA 維基內容 → **CC BY-SA 4.0**；另含 CC BY 4.0 與 CC0 語料，需一併署名 |
| `jyut_char.gram`（字級模型） | 與詞級模型同語料、同授權 |
| `symbols_cantonese.yaml` | 作者 **亶父 <tanxpyox@gmail.com>**，為粵語輸入社群流通的 symbols 補丁；再散佈請保留檔頭署名 |

若要把整包（含粵典衍生部分）收費、掛廣告或作為增值服務販售，會違反 NCODL 1(a)；
把粵典部分改掛其他授權會違反 1(d)；把維基衍生的模型／詞層改掛 MIT／CC0 會違反
CC BY-SA 的相同方式分享要求。

## 4. NCODL 1(b)(i) 要求的英文告示（發佈時請原樣附上）

```
Portions of this work are derived from 《粵典 words.hk》 (https://words.hk).
Copyright (c) 2015-2025, Hong Kong Lexicography Limited. All rights reserved.
Licensed under the Non-Commercial Open Data License 1.0
(https://words.hk/base/hoifong/). You may not use these portions for
Commercial Purposes, and you may not sub-license them; any downstream use
must be licensed directly by the copyright owner.

Credits List: https://words.hk/base/about/

THIS WORK IS PROVIDED BY THE AUTHORS AND/OR COPYRIGHT OWNERS ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHORS AND/OR COPYRIGHT OWNERS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
WORK, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## 5. 其他署名

```
Cantonese-Chinese parallel corpus (raptorkwok) — CC0-1.0.
Hong Kong Cantonese Corpus (HKCanCor), K. K. Luke & May L. Y. Wong — CC BY 4.0,
  https://creativecommons.org/licenses/by/4.0/
yue-lihkg-topic (izhx) — CC BY 4.0（僅用於語言模型）
Chinese Wikipedia / Cantonese Wikipedia snapshots (Wikimedia) — CC BY-SA 4.0
  （模型衍生物以相同授權分享）, https://creativecommons.org/licenses/by-sa/4.0/
zh-wiki-yue-long (R5dwMg, derived from https://zh-yue.wikipedia.org) — CC BY-SA
  （資料集 README〈Licensing and Permissions〉明示；衍生詞層與模型以相同授權分享）
symbols_cantonese.yaml — 亶父 <tanxpyox@gmail.com>
```
