# pre-launch-audit — 事實來源

> 建立：2026-04-18
> 維護者：rj0217
> 狀態：**v0.1 初版**（基於 setupbro 2026-04-17 實戰審計經驗抽取）
> Dev 位置：`~/.claude/skills/pre-launch-audit/`
> Publish 位置：`/mnt/d/SKILL/pre-launch-audit/`（本檔）

---

## 1. 是什麼

Claude Code skill — 「產品上線 / 對外推廣前的完整資安審計 SOP」。

**定位**：不是自動化掃描器，不是命令清單。**是一套讓 AI 自己讀、自己判斷、自己呼叫 scripts 的工作框架**。

---

## 2. 設計哲學（參考 `meta/preferences/skill_is_sop_not_command.md`）

| 層 | 內容 | 誰做 |
|---|---|---|
| **SKILL.md** | SOP 流程框架、判斷指引、常見失誤模式 | AI 讀 + 判斷 |
| **scripts/** | 確定性、重複性工作 | AI 呼叫 bash |
| **references/** | 攻擊向量清單、嚴重度判準、報告範本 | AI 按需讀取 |

重複性工作不由 AI 每次組合 curl（浪費 token + 不穩定），確定性工作都交給 scripts。

---

## 3. 檔案結構

```
/mnt/d/SKILL/pre-launch-audit/
├── SKILL.md                        # SOP 主檔（同步自 dev）
├── scripts/                        # 4 個確定性工具
│   ├── passive_recon.sh            # headers / TLS / robots / security.txt / 敏感路徑
│   ├── bundle_scan.sh              # JS chunks 秘密 pattern 掃描
│   ├── http_method_fuzz.sh         # HTTP 方法列舉
│   └── dep_cve_scan.sh             # npm audit 包裝 + 嚴重度摘要
├── references/
│   ├── attack_vectors.md           # 13 項標準攻擊向量 + 判讀指引
│   ├── severity_matrix.md          # HIGH/MEDIUM/LOW 判準
│   └── report_template.md          # 報告輸出格式範本
└── docs/                           # 只存在 publish 側（dev 側沒有）
    ├── index.md                    # 本檔
    └── work_progress.md            # 迭代歷史
```

---

## 4. 五階段流程摘要

1. **Context Loading** — 讀專案文檔建立攻擊面地圖（純讀，不發請求）
2. **Passive Recon** — 被動觀察（任何訪客都看得到的東西），呼叫 `passive_recon.sh` + `bundle_scan.sh`
3. **White-Box Audit** — AI 讀 code 找邏輯風險（認證、輸入驗證、授權、金流、rate limit、秘密管理）
4. **Active Testing**（**需用戶明確授權**）— XSS / SQLi / admin bypass / rate limit 探測
5. **Fix + Verify + Report** — 依賴層 CVE 掃描（`dep_cve_scan.sh`），按 severity_matrix 分級，用 report_template 輸出

---

## 5. 使用時機

- 產品 MVP 準備 demo 對外推廣前
- 新整合了金流 / 用戶認證 / 敏感資料處理後
- 想對已有的站（含 AI 協作產物）做第二輪驗證
- 跨 AI 交叉比對（例：Opus 審過一輪，用這個 skill 讓另一個 Claude session 再審）

---

## 6. 使用範圍

**v0.1 專注**：Web 產品（Next.js / React / Vue / 靜態站）

**不覆蓋**（未來可能另開新 skill）：
- CLI / 桌面軟體
- 行動 App
- 嵌入式韌體
- 合約 / Web3 / 智能合約審計

---

## 7. 已知限制

| 限制 | 原因 | 對策 |
|---|---|---|
| `bundle_scan.sh` 只識別 Next.js 和標準 `/assets` `/static` 路徑 | 其他框架路徑不一致 | 未來加 Vite / Nuxt / SvelteKit 變體 |
| `dep_cve_scan.sh` 只支援 `npm` | Python / Go / Rust 生態系不同 | 未來加 `pip-audit` / `govulncheck` / `cargo audit` 包裝 |
| 主動測試 payload 要 AI 手動構造 | 每個站業務邏輯不同，通用 payload 效果差 | 接受這是 AI 判斷的部分，不自動化 |
| 無自動化 race condition / ReDoS / SSRF 測試 | 這類需深度理解業務邏輯 | v0.1 不做，reference `attack_vectors.md` 段末已標註 |

---

## 8. 與官方 `/security-review` 的差異

| 面向 | 官方 `/security-review` | 本 skill |
|---|---|---|
| 作用域 | Current branch 的 pending changes | 整個站 + 線上行為 |
| 階段 | 單一（audit diff） | 5 個階段 |
| 主動測試 | 無 | 有（需授權） |
| 同業比對 | 無 | 有（選填） |
| Meta 學習記錄 | 無 | 報告含 session 洞察段 |

兩者**互補不取代**。PR 前用 `/security-review`，上線前 demo 前用 `pre-launch-audit`。

---

## 9. 相關記憶

- `meta/preferences/skill_is_sop_not_command.md` — 本 skill 的設計哲學來源
- `meta/feedback/dont_fill_uncertainty_with_narrative.md` — SKILL.md 「常見 AI 失誤模式」段的依據
- `meta/preferences/archive_unused_code_outside_deploy.md` — 物理隔離原則，影響 SKILL.md 中「測試端點處理」的判斷
- `meta/advice/postgres_as_rate_limiter.md` — setupbro 實戰導出的 rate limit 實作參考

---

## 10. 版本歷史

- **v0.1**（2026-04-18）— 初版，從 setupbro 2026-04-17 實戰經驗抽取

---

*狀態：unverified — 待下次實戰使用後依經驗校準*
