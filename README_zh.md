# claude-skills-rj0217（繁體中文）

> **SOP 導向的 Claude Code skills 集合。** 每個 skill 把重複性工作交給 scripts，讓 AI 專注於判斷。Skill 是 AI 的工作指南，不是命令清單。

**📄 Available in**: [English](./README.md)

[快速安裝](#快速安裝) · [目前收錄](#目前收錄) · [設計哲學](#設計哲學) · [向後兼容](#向後兼容) · [贊助支持](#贊助支持)

---

## 這個 repo 是什麼

一個遵循統一設計哲學的 Claude Code skills 集合。每個 skill 內含：

- **`SKILL.md`** — SOP 流程框架、判斷指引、常見 AI 失誤模式
- **`scripts/`** — 確定性、重複性工作交給 bash
- **`references/`** — checklist、嚴重度判準、報告範本
- **`docs/`** — 事實源 + 迭代歷史

AI 讀 SOP 判斷，重複性工作交給 scripts。**這是集合 repo，不是單一主題工具箱**。目前內容以資安為主（v1 是 `pre-launch-audit`），未來可能擴充到文檔流程、記憶管理、code review 等領域。

---

## 快速安裝

### 方式 A · Claude Code Plugin（推薦）

```
/plugin install https://github.com/p62003/claude-skills-rj0217
```

未來若升級為 marketplace：
```
/plugin marketplace add https://github.com/p62003/claude-skills-rj0217
/plugin install claude-skills-rj0217
```

### 方式 B · 手動複製（相容 Claude Desktop / 任何版本）

```bash
git clone https://github.com/p62003/claude-skills-rj0217.git
cp -r claude-skills-rj0217/skills/* ~/.claude/skills/
```

重啟 Claude Code / Desktop 後生效。

---

## 目前收錄

| Skill | 版本 | 用途 |
|---|---|---|
| [pre-launch-audit](./skills/pre-launch-audit/) | v0.1.1 | Web 產品上線前的完整資安審計 SOP |

### pre-launch-audit 30 秒速懂

針對 Next.js / React / Vue / 靜態站上線前的資安檢查。內含：

- **5 階段流程**：context loading → 被動觀察 → 白箱審計 → 主動測試（需授權）→ 修復 + 驗證 + 報告
- **4 個 scripts**：`passive_recon.sh`、`bundle_scan.sh`、`http_method_fuzz.sh`、`dep_cve_scan.sh`
- **13 項攻擊向量**：XSS / SQLi / path traversal / CSRF / rate limit / bundle secret / 依賴層 CVE 等
- **嚴重度判準**（HIGH / MEDIUM / LOW / GOOD）+ 常見誤用警示
- **報告範本**含 meta 學習段 + 競品對照段

**與官方 `/security-review` 的差異**：官方的只審 current branch 的 pending changes；`pre-launch-audit` 審整個站含線上行為，且可執行授權範圍內的主動測試。**互補不取代**。

---

## 設計哲學

所有 skill 遵循同一原則：

| 層 | 內容 | 誰做 |
|---|---|---|
| **SKILL.md** | SOP 流程、判斷指引、失誤模式 | AI 讀 + 判斷 |
| **scripts/** | 確定性、重複性工作 | AI 呼叫 bash |
| **references/** | checklist、判準、範本 | AI 按需讀 |
| **docs/** | 事實源 + 迭代歷史 | 維護者寫 |

**Skill ≠ 命令清單**。Skill 是給 AI 讀的 SOP + 給 AI 用的工具箱。判斷是 AI 的職責，執行重複性工作交給 scripts。

為什麼這樣做：
- **Token 效率**：AI 不用每 session 重新組合同樣的 curl 指令
- **可重現**：scripts 固定輸入固定輸出，AI 行為不穩定
- **專注判斷**：AI 的 value 在判斷，不在執行模板
- **跨 session 穩定**：scripts 不受 context / model version 影響
- **避免 checklist 假象**：框架式 SKILL.md 強迫 AI 每步驟思考

---

## Repo 結構

```
claude-skills-rj0217/
├── .claude-plugin/
│   └── plugin.json                # Claude Plugin manifest
├── README.md / README_zh.md
├── .gitignore
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── scripts/
        ├── references/
        └── docs/
            ├── index.md
            └── work_progress.md
```

---

## 向後兼容

本 repo 承諾：

- **加新 skill** = 只在 `skills/` 新增目錄，不動既有結構
- **版本升級** = 記在 skill 自己的 `docs/work_progress.md`，不破壞觸發條件
- **未來升級 marketplace** = 本 repo 保留為 plugin，既有 install 路徑永遠有效

---

## 贊助支持

如果這些 skill 幫你省時間或省錢（例：跳過一次付費 pentest、加速出貨），歡迎支持繼續開發：

### ☕ Ko-fi（推薦：信用卡 / PayPal 一鍵）

[![Support on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rj0217)

### 🪙 加密貨幣（USDT / USDC on BEP20 / BSC）

```
0x55c439b27807415e80452f59ba00fee3441a802d
```

**網路**：BEP20（Binance Smart Chain）
**接受幣種**：USDT、USDC
⚠️ 其他網路（ERC20 / TRC20）**不會**在此地址收到，請勿誤轉。

### 🏦 銀行轉帳（僅限台灣用戶）

- **中國信託銀行（CTBC，822）**
- **帳號**：`7505-4015-7378`

⚠️ 跨境匯款成本常高於贊助金額，海外用戶請改用 Ko-fi 或加密貨幣。

### ⭐ GitHub Star

不用錢但有用 — 幫我讓更多人看到這個 repo。

---

## 聯絡

- **Discord**：https://discord.gg/x52CBg4rcE
- **Email**：dont.stop.ha@gmail.com

---

## 維護者

[rj0217](https://github.com/p62003) · 2026-04-18 建立
