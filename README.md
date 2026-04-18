# claude-skills-rj0217

rj0217 自建的 Claude Code skills 集合，以 Claude Plugin 形式發佈。

---

## 快速安裝

### 方式 A：Claude Code Plugin（推薦）

在 Claude Code 內執行：

```
/plugin install https://github.com/p62003/claude-skills-rj0217
```

或透過 marketplace（若未來升級）：
```
/plugin marketplace add https://github.com/p62003/claude-skills-rj0217
/plugin install claude-skills-rj0217
```

### 方式 B：手動複製（相容 Claude Desktop / 任何版本）

```bash
git clone https://github.com/p62003/claude-skills-rj0217.git
cp -r claude-skills-rj0217/skills/* ~/.claude/skills/
```

重啟 Claude Code / Desktop 後生效。

---

## 目前收錄的 skills

| Skill | 版本 | 用途 |
|---|---|---|
| [pre-launch-audit](./skills/pre-launch-audit/) | v0.1 | 產品上線 / 對外推廣前的完整資安審計 SOP |

---

## 設計哲學

所有 skill 遵循同一原則：

| 層 | 內容 | 誰做 |
|---|---|---|
| **SKILL.md** | SOP 流程框架、判斷指引、常見失誤模式 | AI 讀 + 判斷 |
| **scripts/** | 確定性、重複性工作 | AI 呼叫 bash |
| **references/** | checklist、範本、判準 | AI 按需讀 |
| **docs/** | 事實源 + 迭代歷史 | 維護者寫 |

**Skill ≠ 命令清單**。Skill 是給 AI 讀的 SOP + 給 AI 用的工具箱。判斷是 AI 的職責，執行重複性工作交給 scripts。

---

## Repo 結構

```
claude-skills-rj0217/
├── .claude-plugin/
│   └── plugin.json                # Claude Plugin manifest
├── README.md                      # 本檔
├── .gitignore
└── skills/
    └── <skill-name>/
        ├── SKILL.md               # SOP 主檔
        ├── scripts/               # 確定性工具
        ├── references/            # 攻擊向量 / 判準 / 範本
        └── docs/                  # 事實源 + 迭代歷史
            ├── index.md
            └── work_progress.md
```

---

## 向後兼容承諾

- **加新 skill** = 只在 `skills/` 下新增目錄，不動 plugin.json 結構
- **未來若升級成 marketplace** = 本 repo 保留為 plugin，同時可接 `marketplace.json`，既有 install 路徑不失效
- **skill 版本升級** = 在該 skill 的 `docs/work_progress.md` 記載，不破壞 SKILL.md 的觸發條件

---

## 開發流程（維護者專用）

```
Dev 環境：~/.claude/skills/<name>/            ← WSL ext4，claude code 直接讀
Publish：/mnt/d/SKILL/skills/<name>/          ← 本 repo，git 追蹤
```

新建 skill：
1. 在 `~/.claude/skills/<new>/` 開發 + 測試
2. 穩定後 `cp -r` 到 `/mnt/d/SKILL/skills/<new>/`
3. 在該 skill 建 `docs/index.md` + `docs/work_progress.md`
4. 更新本 README 的「目前收錄」表
5. commit + push

既有 skill 迭代：
1. dev 改 + 測試
2. `cp -r` 同步（跳過 `docs/`，那只在 publish 側）
3. 在 `<skill>/docs/work_progress.md` 頂部加迭代紀錄
4. commit + push

---

## 維護者

[rj0217](https://github.com/p62003) · 2026-04-18 建立
