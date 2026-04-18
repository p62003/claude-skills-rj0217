# pre-launch-audit — 作業進度紀錄

每次 skill 的迭代、修正、新增都記錄於此。時間由新到舊。

---

## 2026-04-18 — v0.1 初版建立

### 動機
2026-04-17 setupbro 的完整資安審計（54 分鐘，14 commit，實機 13 項攻擊向量驗證）做完後，rj0217 觀察到兩件事：
1. 流程本身有抽取成 skill 的價值 — 以後每個上線前產品都需要
2. 沒有現成 skill 涵蓋這種「full site pre-launch audit」場景（官方 `/security-review` 只審 pending changes）

### 設計哲學決策
rj0217 主張「Skill = SOP + Scripts，不是命令清單」：
- 重複性、確定性工作 → scripts/
- 判斷、白箱審計、payload 構造 → AI
- SKILL.md 是**框架**，不是死稿

詳見 `meta/preferences/skill_is_sop_not_command.md`。

### 架構決策
- **Dev**：`~/.claude/skills/pre-launch-audit/`（claude code 讀得到、可直接測試）
- **Publish**：`/mnt/d/SKILL/pre-launch-audit/`（git repo 對外發表，多一個 `docs/` 目錄）
- **同步方式**：dev 穩定後 `cp -r` 到 publish
- 類比 setupbro 的 `~/setupbro/`（code）vs `/mnt/d/setupbro/`（docs）

### 三個前置決定（CAA 選項）
- **C**：Web 產品通用，取中性名 `pre-launch-audit`（未來桌面/CLI 需求另開新 skill）
- **A**：單一 skill 含授權檢查（Phase 4 前 AI 必須問用戶授權，避免拆多個 skill 流程斷掉）
- **A**：現在就初始化 `/mnt/d/SKILL/` 為 git repo（開發過程就能 commit 當里程碑）

### 實作內容

#### SKILL.md（SOP 主檔）
- 使用時機 / 前置確認
- 五階段流程（Context Loading → Passive Recon → White-Box Audit → Active Testing → Fix+Verify+Report）
- **Phase 4 前硬性要求 AI 取得用戶授權**
- 「常見 AI 失誤模式」段：narrative-filling / audit vs design 姿態 / 漏掉依賴層 / 未授權亂打
- 明確寫「不要把 SKILL.md 當死稿跑」

#### scripts/（4 個）
- `passive_recon.sh` — headers / TLS / 公開發現檔 / 敏感路徑 / security headers 覆蓋度 + info-leak 偵測
- `bundle_scan.sh` — 下載 JS chunks + 16 種秘密 pattern + 長字串數量統計
- `http_method_fuzz.sh` — 8 個 HTTP 方法列舉 + 狀態碼語意標記
- `dep_cve_scan.sh` — `npm audit` + Python 解 JSON 摘要 + actionable fixes 提示

#### references/（3 個）
- `attack_vectors.md` — 13 項標準向量（XSS / SQLi / Type confusion / Null byte / 超長 / Path traversal / HTTP method / Admin bypass / Open redirect / CSRF / Rate limit / Bundle leak / CVE）+ 每項的 payload / 預期反應 / 判讀指引。末段列未涵蓋的（ReDoS / XXE / SSRF / Prototype pollution / Race conditions）
- `severity_matrix.md` — HIGH/MEDIUM/LOW/GOOD（🔵）判準 + 判級常見陷阱
- `report_template.md` — 完整報告 markdown 範本（含 meta 學習段 + 對外話術範本）

#### publish 端 docs/（只在 `/mnt/d/SKILL/` 側）
- `index.md` — 本 skill 的事實來源
- `work_progress.md` — 本檔

#### Repo root
- `/mnt/d/SKILL/README.md` — skill 索引 + 發佈規則

### Session 大事紀
- **官方內建 skill 查核**：確認 `/security-review` 是 Claude Code CLI bundled binary 內定義（無法讀原始碼），作用域只涵蓋 current branch pending changes，與本 skill **互補不取代**
- **交叉驗證原則寫進 attack_vectors.md**：source 是 2026-04-17 session 的實戰觀察（Opus 4.6 + Claude 都漏了 CSP report-uri / CSRF cookie / robots.txt，單 AI 審會有集體盲區）

### 待驗證（下次實戰校準）
- 各 script 在 WSL 之外環境（macOS / Linux 桌面）執行是否正常
- `bundle_scan.sh` 對非 Next.js 站（Nuxt / SvelteKit / Astro）的適配度
- SKILL.md 的「五階段」在實戰是否節奏合理、會不會有 phase 被自然跳過
- Phase 4 授權確認的 prompt 會不會被 AI 省略

### 相關 commits
（待 git init 後補）
