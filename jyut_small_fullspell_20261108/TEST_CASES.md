# 部署後驗證清單

方案：`jyut_small`（詞級模型，`jyut.gram`）、`jyut_small_char`（字級模型，`jyut_char.gram`）、
`jyut_small_simp`／`jyut_small_char_simp`（同上，簡體輸出）。
四者詞庫相同，繁體與簡體只差預設用字。

## 測試方法

1. 重新部署後，切到「粵語小詞庫（詞級模型）」，確認可正常出字。
2. 以下輸入碼為**無聲調粵拼**，音節以空格分隔，直接照抄輸入即可。
   無調輸入會產生同音競爭，正是本清單要驗證重點；也可加聲調對照。
3. 每句先看「不選字、直接按空白上屏」的首選結果，再觀察候選排序。
4. 同一句切到「粵語小詞庫（字級模型）」再打一次，記錄差異。

> 若要做「無模型」對照：把 `schema 檔案` 的 `grammar:` 整段註解，另存為新方案後重新部署。
> 本包不提供預先做好的無模型方案，以免與正式方案混淆。

## 簡體方案（`jyut_small_simp`／`jyut_small_char_simp`）

1. 切到簡體方案，確認候選與上屏為簡體：例 `do ze` 繁體為「多謝」、簡體為「多谢」。
2. 同一句在繁體與簡體方案各打一次，除字形轉換外排序應一致；若排序明顯不同，先確認是否切錯方案。
3. 在任一方案按 `Ctrl+q` 可即時切換「漢字／汉字」，不需重新部署。

## 日常口語（5 句）

| # | 句子 | 輸入（無聲調） |
|---|---|---|
| 1 | 我哋今日下晝去尖沙咀睇戲好唔好？ | `ngo dei gam jat haa zau heoi zim saa zeoi tai hei hou m hou` |
| 2 | 你聽日返工之前記得同我講一聲。 | `nei teng jat faan gung zi cin gei dak tung ngo gong jat seng` |
| 3 | 呢啲嘢唔係咁樣做嘅，要慢慢嚟。 | `nei di je m hai gam joeng zou ge jiu maan maan lai` |
| 4 | 佢琴日喺街市買咗兩斤菜心返屋企煮。 | `keoi kam jat hai gaai si maai zo loeng gan coi sam faan uk kei zyu` |
| 5 | 你食咗飯未呀？使唔使我幫你買埋？ | `nei sik zo faan mei aa sai m sai ngo bong nei maai maai` |

## 書面語（5 句）

| # | 句子 | 輸入（無聲調） |
|---|---|---|
| 6 | 香港天文台預測明日有驟雨，市民外出請帶備雨具。 | `hoeng gong tin man toi jyu caak ming jat jau zaau jyu si man ngoi ceot cing daai bei jyu geoi` |
| 7 | 政府將於下月起調整公共交通費用補貼計劃的申請資格。 | `zing fu zoeng jyu haa jyut hei tiu zing gung gung gaau tung fai jung bou tip gai waak dik san cing zi gaak` |
| 8 | 這項研究顯示，定期運動能有效降低心血管疾病的風險。 | `ze hong jin gau hin si ding kei wan dung nang jau haau gong dai sam hyut gun zat beng dik fung him` |
| 9 | 會議決定把項目延期兩個月，以便完成環境影響評估。 | `wui ji kyut ding baa hong muk jin kei loeng go jyut ji bin jyun sing waan ging jing hoeng ping gu` |
| 10 | 圖書館由本週五起延長開放時間，方便學生準備考試。 | `tou syu gun jau bun zau ng hei jin coeng hoi fong si gaan fong bin hok saang zeon bei haau si` |

## 無調輸入對照

| 輸入（無調） | 期望首選 |
|---|---|
| `cing` | 請 |
| `daai bei` | 帶備 |
| `zaau jyu` | 驟雨 |
| `jyu geoi` | 雨具 |
| `jau` | 有 |

注意：`驟雨` 的粵拼是 `zaau6 jyu5`，不是 `zau jyu`；`zau jyu` 會對應「咒語／周瑜」。

## 短碼回歸（兩個方案都應一致）

| 輸入 | 期望前五 |
|---|---|
| `ht` | 系統／開通／好睇／夏天／氣體 |
| `co` | 坐／錯／初／楚／搓 |
| `couu` | 嘈屋／嘈／草／徂／粗 |
| `hoeng` | 向／響／鄉／嚮／香 |

短碼由單字與詞庫權重主導，模型影響很小；兩個方案結果通常相同。
`htha` 的結果會受使用者學習庫（userdb）影響，不宜作為模型驗證項。

## 模型差異觀察句

| 句子 | 輸入 | 詞級常見結果 | 字級常見結果 |
|---|---|---|---|
| 我想要一杯凍奶茶唔該 | `ngo soeng jiu jat bui dung naai caa m goi` | …凍奶茶**唔改** | …凍奶茶**唔該** |
| 我哋今日下晝去尖沙咀睇戲好唔好 | 見第 1 句 | …尖沙咀**提起** | …尖沙**嘴睇起** |
| 佢哋聽日朝早坐車去香港 | `keoi dei teng jat ziu zou co ce heoi hoeng gong` | **距地**聽日… | 佢哋聽日… |

上表為冷啟動實測，實際結果會受版本與使用者學習紀錄影響；重點是兩個方案應有可觀察差異。

## 重要：userdb 會記住整句

Rime 會把上屏的整句寫入 `%RIME%\jyut_small.userdb`（字級為 `jyut_small_char.userdb`，
簡體方案各有一份）。若之前曾上屏錯誤句子，該整句會成為
最高權重候選，**新增任何詞庫都無法覆蓋**。實機若仍出現舊錯句，處理方式：

1. 退出小狼毫（`WeaselServer.exe /q`）。
2. 把 `jyut_small.userdb` 整個資料夾移到備份位置。
3. 重新部署；下次輸入時 Rime 會重建空白 userdb。

## 觀察重點

- 長句首選是否「一句讀得通」，而非逐字湊合。
- 常見搭配（例如「下晝…睇戲」「公共交通…補貼」「環境影響…評估」）是否往前排。
- 是否出現明顯不合理的同音字（模型不應把罕見字排到首位）。
- 改選中間某字後，後續候選是否跟著變順。
- 兩個方案的差異是否與預期一致；若完全一樣，先檢查模型是否載入。

## 模型是否真的載入

- 詞級：日誌應出現 `use grammar: jyut`、`found double array image of size 19324928`。
- 字級：日誌應出現 `use grammar: jyut_char`、`found double array image of size 18191872`。
- 若出現 `failed to load grammar database` 或 `invalid metadata`，回報即可，不要刪檔。

## 回報格式

請記下：句子編號、方案（詞級／字級）、首選結果、與另一方案的差異（較順／相同／較差）。
有問題時附上輸入碼與實際輸出。
