# SKILL — rj0217 的 Claude Code Skill 發表目錄

本 repo 收錄 rj0217 自建的 Claude Code skills，含設計哲學、完整 SOP、scripts、references 與迭代歷史。

---

## 為什麼有這個 repo

1. **Skill 開發 / 發表環境分離**
   - Dev：`~/.claude/skills/<name>/`（WSL ext4，claude code 直接讀）
   - Publish：`/mnt/d/SKILL/<name>/`（NTFS，含完整 docs，git 管）
2. **對外分享**：其他人 clone 後可 `cp -r <name>/ ~/.claude/skills/` 直接使用
3. **迭代追蹤**：每個 skill 都有自己的 `docs/index.md`（事實源）+ `docs/work_progress.md`（歷史）

---

## 設計哲學

所有 skill 遵循同一原則（see `meta/preferences/skill_is_sop_not_command.md` in ISST_continuity memory）：

| 層 | 內容 | 誰做 |
|---|---|---|
| **SKILL.md** | SOP 流程框架、判斷指引、常見失誤模式 | AI 讀 + 判斷 |
| **scripts/** | 確定性、重複性工作 | AI 呼叫 bash |
| **references/** | checklist、範本、判準 | AI 按需讀 |
| **docs/** | 事實源 + 迭代歷史（只在 publish 側） | rj0217 維護 |

**Skill ≠ 命令清單**。Skill 是給 AI 讀的 SOP + 給 AI 用的工具箱。判斷是 AI 的職責，執行重複性工作交給 scripts。

---

## 目前收錄的 skills

| Skill | 版本 | 用途 | 狀態 |
|---|---|---|---|
| [pre-launch-audit](./pre-launch-audit/) | v0.1 | 產品上線 / 對外推廣前的完整資安審計 SOP | unverified（2026-04-18 初版） |

---

## 發佈規則

### 新建 skill 流程
1. 在 `~/.claude/skills/<new-name>/` 開發 + 測試
2. 穩定後在 `/mnt/d/SKILL/<new-name>/` 建對應目錄
3. `cp -r` 同步 `SKILL.md`、`scripts/`、`references/`（docs/ 只在 publish 側手寫）
4. 建 `docs/index.md`（事實源）+ `docs/work_progress.md`（首次迭代紀錄）
5. 更新本 README 的「目前收錄」表
6. `git add` + `git commit`

### 已有 skill 迭代流程
1. dev 改 → 測試
2. 穩定後 `cp -r` 同步（**跳過 docs/**，它只在 publish 側）
3. 在 `<skill>/docs/work_progress.md` 頂部新增迭代紀錄
4. 更新 `<skill>/docs/index.md` 如有結構/範圍變動
5. `git commit`

### 版號規則
- `v0.x` = 實戰驗證中（unverified）
- `v1.0+` = 實戰跑過 3 次以上、沒發現 SOP 缺口才升版

---

## 使用其他人的 skill（未來擴充）

若其他人透過此 repo 分享他們的 skill：
```bash
git clone <this-repo>
cp -r <repo>/<skill-name>/ ~/.claude/skills/
# 下次啟動 Claude Code 即可識別
```

---

## 維護者

rj0217 · 2026-04-18 建立
