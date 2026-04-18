# claude-skills-rj0217 — 作業進度紀錄

Repo 層的迭代記錄。各 skill 自己的迭代歷史在 `skills/<name>/docs/work_progress.md`。
時間由新到舊。

---

## 2026-04-18 — Repo 建立 + pre-launch-audit v0.1 + 公開發佈

### 起因
2026-04-17 setupbro 的完整資安審計（54 分鐘，3 commits，實機 13 項攻擊向量驗證）做完後，rj0217 觀察到兩件事：
1. 流程本身有抽取成 skill 的價值 — 以後每個上線前產品都需要
2. 沒有現成 skill 涵蓋這種「full site pre-launch audit」場景（官方 `/security-review` 只審 pending changes）

決定建第一個 skill + 建一個 repo 收錄未來所有 rj0217 的 skills。

### 核心設計決策（rj0217 提出）
> **Skill 不是命令清單，是一套 SOP 概念**
> 重複性工作交給 scripts，判斷交給 AI

這個原則寫入 `meta/preferences/skill_is_sop_not_command.md`，成為本 repo 所有 skill 的設計約束。

### 架構決策（AI 提議 + rj0217 決定）
- **Path A**：單一 plugin 包多個 skills（不做 marketplace 多 repo），降低維護成本
- **Dev / Publish 雙位址**：`~/.claude/skills/<name>/`（dev）vs `/mnt/d/SKILL/skills/<name>/`（publish），手動 `cp -r` 升級
- **向後兼容承諾**：加新 skill 零結構變動；未來升級 marketplace 舊 install 路徑不失效

### 完成時間軸

#### 08:01-08:11 · pre-launch-audit v0.1 建立
- SKILL.md：5 階段 SOP 框架 + 常見 AI 失誤模式
- 4 個 scripts：`passive_recon.sh` / `bundle_scan.sh` / `http_method_fuzz.sh` / `dep_cve_scan.sh`
- 3 個 references：`attack_vectors.md`（13 項攻擊向量）/ `severity_matrix.md`（HIGH/MED/LOW/GOOD 判準）/ `report_template.md`（報告格式）
- Dev + Publish 雙位址建立，skill 已被 Claude Code 自動識別

#### 08:11-08:17 · Repo 結構遷移到 Claude Plugin 格式 (v0.1.1)
- `pre-launch-audit/` → `skills/pre-launch-audit/`（符合 Claude Plugin 慣例）
- 新增 `.claude-plugin/plugin.json` manifest
- README 改寫為含 Plugin 安裝方式

#### 08:23-08:27 · 公開發佈到 GitHub
- Repo 命名：`claude-skills-rj0217`
- rj0217 建 GitHub 空 repo
- AI push 首個 commit，正式上線
- 3 commits 上線（init / migrate to plugin / README 英文主繁中輔）

#### 08:31-08:35 · Positioning 修正（重要轉折）
rj0217 注意到：**repo 結構是通用集合，但 AI 給的 SEO copy 偏向單一技能**。決定 Path A：
- repo description 改為「SOP-driven Claude Code skills collection...currently includes pre-launch-audit...more skills coming」
- README 頂部 TL;DR 強調「collection」而非「security audit」
- Topics 分通用層（claude-code / skill / plugin / sop）+ 領域層（security-audit / pentest / owasp），未來加新 skill 時追加該領域 tag 不刪既有

#### 08:35-08:40 · README 雙語拆分 + 贊助段
- `README.md` 改為純英文，頂部連結繁中版
- `README_zh.md` 新增繁中獨立版
- 加贊助段（Ko-fi 主推、BEP20 USDT/USDC 次、台灣銀行僅繁中版）
- plugin.json description 改為英文主（全球可見）
- 贊助資料引用自 `meta/tacit/rj0217_donation_channels.md`

### Commits
```
0e277fa docs: 拆分 README 為 EN 主 / 繁中輔，加贊助段 (Ko-fi + BEP20)
d8305d7 docs: README 重寫為英文主、繁中輔（SEO 導向）
2031c1c refactor: 遷移至 Claude Plugin 格式 (v0.1.1)
8f2bf90 init: SKILL repo + pre-launch-audit v0.1
```

### 異動檔案統計
- **新增**（repo-level）：`README.md` / `README_zh.md` / `.claude-plugin/plugin.json` / `.gitignore` / `docs/index.md` / `docs/work_progress.md`
- **新增**（skill-level）：12 個檔（SKILL.md + 4 scripts + 3 refs + 2 docs + 目錄）
- **結構變動**：`pre-launch-audit/` → `skills/pre-launch-audit/`（r v0.1.1）

### Meta 觀察（值得記的）

1. **Positioning 自我糾正**：rj0217 第一輪沒糾結名字和 SEO 的矛盾，等看到 AI 給的 copy 偏向單一技能才觸發校正。這個**「先看產出再糾正方向」的工作節奏**比「先規劃到位才動手」快，適合 vibecoder 時代的迭代風格。

2. **記憶即時引用**：贊助資料直接從 `meta/tacit/rj0217_donation_channels.md` 取，不用再問一次。**這驗證了 ISST_continuity memory 對實際工作的 value** — 不是理論存放，是隨時可引用的決策資產。

3. **「進場判準」第一次被套用**：建 `pre-launch-audit` skill 之前，用「免費做到讓付費頭痛」判準測試過：對小型 pentest 公司會頭痛、對 Snyk 大廠不會（不同 category）。通過判準才動手。

### 相關記憶
- `meta/preferences/skill_is_sop_not_command.md` — 本 repo 所有 skill 的設計原則
- `meta/tacit/paid_incumbent_headache_test.md` — 進場判準（本 skill 通過）
- `meta/tacit/rj0217_donation_channels.md` — 贊助資料源
- `meta/feedback/dont_fill_uncertainty_with_narrative.md` — SKILL.md「常見 AI 失誤模式」段依據

### 待驗證（下次實戰校準）
- Scripts 在 WSL 之外環境（macOS / Linux 桌面）執行是否正常
- `bundle_scan.sh` 對非 Next.js 站（Nuxt / SvelteKit / Astro）的適配度
- SKILL.md 的「五階段」在實戰是否節奏合理、會不會有 phase 被自然跳過
- Phase 4 授權確認的 prompt 會不會被 AI 省略
- Plugin install 流程跑過沒有（目前只驗過手動 `cp -r`）
- 用戶第一次看到 README 的點擊率（要不要調整 TL;DR）

### 下一次建新 skill 時的 checklist（從本次經驗抽出）
1. ✅ 通過「進場判準」（免費做到讓付費頭痛？）
2. ✅ dev 先做完測試穩定
3. ✅ cp -r 到 publish 側，加 docs/
4. ✅ 更新兩版 README 的 Included Skills 表
5. ✅ 加該領域 topics 到 GitHub（不刪既有）
6. ✅ 更新本檔（repo 層 work_progress）
7. ✅ 更新 skill 自己的 `docs/work_progress.md`
8. ✅ commit + push
