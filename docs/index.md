# claude-skills-rj0217 — 事實來源

> 建立：2026-04-18
> 維護者：rj0217
> Repo：https://github.com/p62003/claude-skills-rj0217
> 狀態：**✅ 已上線**（2 skills 收錄；1 skill 開發中 — `extract-tokens-claude-design`）

本檔是本 repo 的**事實源**。repo 架構、發佈規則、維護紀律的決策記錄於此；各 skill 的內部事實源在 `skills/<name>/docs/index.md`。

Session 詳細工作紀錄採 Aletheia 慣例：`docs/SESSION_SUMMARY_YYYYMMDD_HH.md`（新到舊索引見本檔 § 10）。`docs/work_progress.md` 保留高階迭代索引。

---

## 1. 是什麼

SOP 導向的 Claude Code skills 集合。**集合 repo，不限定單一領域**。

### 已發佈到 main
- `pre-launch-audit` v0.1.1 — Web 產品上線前的完整資安審計 SOP
- `ai-crawl-audit` v0.1.0 — 從 AI 爬蟲視角診斷網站可爬取性（純 SOP，無 scripts — AI 用 WebFetch 抓取 + 判斷）

### 開發中（dev 位址完成、pending cp -r + docs + README + commit）

- `extract-tokens-claude-design` v2 — Claude Design handoff bundle → DTCG 2025.10 tokens JSON
  - **Scope 刻意 narrow**：只處理 Claude Design 特有 handoff 結構（JSX object literal + EDITMODE block），保留 semantic intent（語義名、$description、可調參數）— 這是 live-site scraper 撈不到的層
  - **下游**：產出的 DTCG JSON 可餵 [Manavarya09/design-extract](https://github.com/Manavarya09/design-extract)（HTML preview / CSS vars / Tailwind / Figma Vars / shadcn / React theme / 19-section markdown 等 8 格式全覆蓋）或 [Style Dictionary](https://styledictionary.com)。本 skill 不重複做這些

### 尚待啟動（backlog）

- `design-session-boot` — 設計紀律 ignition skill（純 markdown，蒸餾自公開 Claude Design 行為）
- `extract-tokens-codebase` — 既有 codebase（`:root{}` CSS vars / Tailwind config / SCSS）→ DTCG JSON（低 ROI）

### 曾考慮但砍除（2026-04-21）

以下曾在 dev 位址建立但發現與 `Manavarya09/design-extract` (`npx skills add`) 功能重複**80%** 以上，已刪除避免重複造輪：
- ~~`generate-brand-preview`~~ — Manavarya09 產 HTML preview + 19-section markdown，更完整
- ~~`apply-tokens-to-codebase`~~ — Manavarya09 產 CSS vars / Tailwind config / Figma Vars / shadcn / React theme，更完整

詳見 `SESSION_SUMMARY_20260420_19.md` Addendum 段。

### 未來可能擴充
documentation workflow / code review / memory management / 其他 AI 協作情境。

---

## 2. 核心設計哲學（跨所有 skill）

詳見 `meta/preferences/skill_is_sop_not_command.md`（ISST memory）。摘要：

| 層 | 內容 | 誰做 |
|---|---|---|
| **SKILL.md** | SOP 框架、判斷指引、失誤模式 | AI 讀 + 判斷 |
| **scripts/** | 確定性、重複性工作 | AI 呼叫 bash |
| **references/** | checklist、判準、範本 | AI 按需讀 |
| **docs/** | 事實源 + 迭代歷史 | 維護者寫 |

**Skill ≠ 命令清單**。Skill 是給 AI 讀的 SOP + 給 AI 用的工具箱。

---

## 3. 架構決策

### 3.1 Dev / Publish 雙位址
```
Dev：    ~/.claude/skills/<name>/       ← WSL ext4，Claude Code 直接讀
Publish：/mnt/d/SKILL/skills/<name>/    ← 本 repo，git 追蹤
```

**為什麼雙位址**：
- Dev 位址是 Claude Code 的約定讀取位置，不可改
- Publish 位址是 NTFS，方便 git + 跨 WSL 分享 + docs 存放
- 兩邊**不自動同步**，避免 dev 測試中的半成品外洩；`cp -r` 手動觸發才升級

### 3.2 Dev 扁平 / Publish 有 skills/ 子目錄
- Dev：`~/.claude/skills/pre-launch-audit/`（扁平，Claude Code 直接載入）
- Publish：`/mnt/d/SKILL/skills/pre-launch-audit/`（遵循 Claude Plugin 慣例）

**為什麼不一致**：Claude Code 的 plugin 安裝機制會把 `skills/<name>/` 下的內容**解包到** `~/.claude/skills/<name>/`。所以兩邊結構差一層是 by design，不是 bug。

### 3.3 docs/ 只在 publish 側，不同步到 dev
- dev 側不需要 docs（開發者在腦中，不用寫給自己看）
- publish 側的 docs 是給**未來自己 + 外部貢獻者**看

### 3.4 Plugin format（非 Marketplace）
選擇 Path A：單一 plugin 包多個 skills，而非 marketplace 分散到多 repo。
- 維護成本低（一個 repo 統一管）
- 向後兼容：未來若升級 marketplace，本 repo 保留為 plugin，既有 install 路徑不失效

---

## 4. 安裝方式（給用戶）

### Option A · Claude Code Plugin
```
/plugin install https://github.com/p62003/claude-skills-rj0217
```

### Option B · 手動（相容 Claude Desktop）
```bash
git clone https://github.com/p62003/claude-skills-rj0217.git
cp -r claude-skills-rj0217/skills/* ~/.claude/skills/
```

---

## 5. 發佈規則

### 新建 skill
1. `~/.claude/skills/<new>/` 開發 + 測試穩定
2. `cp -r` 到 `/mnt/d/SKILL/skills/<new>/`
3. 在該 skill 建 `docs/index.md` + `docs/work_progress.md`
4. 更新 `README.md` 和 `README_zh.md` 的「Included Skills」表
5. 更新本 repo 的 `docs/work_progress.md`（本層 log）
6. commit + push

### 既有 skill 迭代
1. dev 改 + 測試
2. `cp -r` 同步（**跳過 docs/**，只在 publish 側）
3. 在該 skill 的 `docs/work_progress.md` 頂部加迭代紀錄
4. 若涉及 repo 層改動（新 topic / README 大改 / 架構變更），也更新本 repo 的 `docs/work_progress.md`
5. commit + push

### 版號規則
- `v0.x` = 實戰驗證中（`status: unverified`）
- `v1.0+` = 實戰跑過 3 次以上、沒發現 SOP 缺口才升版

---

## 6. 向後兼容承諾

- **加新 skill** = 只新增 `skills/<new>/` 目錄，不動 plugin.json / 既有 skill 結構
- **skill 版本升級** = 不破壞既有 `SKILL.md` 的觸發條件（description 語意連續）
- **未來升級 marketplace**（若集合規模變大）= 本 repo 保留為 plugin 可 install，同時可接 marketplace.json；既有用戶**不需要**遷移

---

## 7. SEO 策略

雙層 SEO：
- **Repo 層**：通用品牌（claude-code / skill / plugin / sop / ai-agent）
- **Skill 層**：各 skill 自己的領域 tag（`pre-launch-audit` 帶 security-audit / pentest / owasp 等）

加新 skill 時**追加該領域 topic**，不刪既有；長期形成「多領域 skills 集合」的 SEO 面向。

目前 topics（15 個）見 repo Settings。

---

## 8. 贊助渠道

完整資料見 `meta/tacit/rj0217_donation_channels.md`（ISST memory）。本 repo 兩版 README 的贊助段引用：
- ☕ Ko-fi（主推）：`https://ko-fi.com/rj0217`
- 🪙 BEP20 USDT/USDC：`0x55c439b27807415e80452f59ba00fee3441a802d`
- 🏦 台灣銀行（僅繁中版）：CTBC 822 / 7505-4015-7378

---

## 9. 相關記憶

- `meta/preferences/skill_is_sop_not_command.md` — 本 repo 所有 skill 的設計原則源頭
- `meta/tacit/paid_incumbent_headache_test.md` — 進場判準，決定哪些 skill 值得做
- `meta/tacit/rj0217_donation_channels.md` — 贊助資料來源
- `meta/feedback/dont_fill_uncertainty_with_narrative.md` — SKILL.md 「常見 AI 失誤模式」段的依據

---

## 10. Session Summary 索引（新到舊）

| Session | 主題 | 產出 |
|---|---|---|
| 2026-04-23 | AI 爬取診斷 skill 結晶 | `ai-crawl-audit` v0.1.0 — 從 COVIA Session 11 的 AI 爬取修復流程中萃取成 SOP。純判斷型 skill（無 scripts），4 階段流程 + 框架陷阱資料庫 + llms.txt 建立指引 |
| [2026-04-20 19:00](SESSION_SUMMARY_20260420_19.md) | Design Toolkit v1（初版 5 skills 計畫 → 審計後縮為 1 skill） | `extract-tokens-claude-design` v2（narrow unique，已在 COVIA 實戰驗證）。`generate-brand-preview` / `apply-tokens-to-codebase` 建立後發現與 Manavarya09/design-extract 重複 80%，已砍除 |
| 2026-04-18 | Repo 建立 + `pre-launch-audit` v0.1.1 + 公開發佈 | 見 `work_progress.md`（當時尚未採 SESSION_SUMMARY 慣例） |

---

*狀態：unverified — 待其他人開始 clone / install / 回饋後升級*
