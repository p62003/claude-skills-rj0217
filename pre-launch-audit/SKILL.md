---
name: pre-launch-audit
description: 產品上線 / 對外推廣前的完整資安審計 SOP。用時機：MVP 準備 demo 前、整合金流或認證後、想對 AI 做的站做第二輪驗證。範圍：Web 產品（Next.js / React / Vue / 靜態站皆可）。執行方式：AI 讀本檔判斷流程，重複性工作呼叫 scripts/ 內腳本；非重複性判斷（白箱審計、payload 選擇、分級）由 AI 執行。**Phase 4 主動攻擊測試前必須取得用戶明確授權。**
---

# Pre-Launch Audit SOP

## 使用時機
- 產品 MVP 準備 demo 對外推廣前
- 新整合了金流 / 用戶認證 / 敏感資料處理後
- 想對已有的站（含 AI 協作產物）做第二輪驗證
- 搭配其他 AI（Opus / Gemini / ...）已做過的審計做交叉比對

## 前置確認（AI 必做）
1. 目標站是否為用戶自有或明確授權測試？**不是就停，不做任何主動探測**
2. 專案根在哪？`git` repo / code 目錄？
3. 有沒有現成的事實文檔（如 `docs/index.md` / README）可以讀攻擊面？

## 五階段流程

### Phase 1：Context Loading（純讀、不外送請求）
- 讀 `docs/index.md` 或 README 理解**業務邏輯**與**攻擊面**
- 列出：
  - 所有 API routes / endpoints
  - DB schema 或主要資料表
  - 認證 / 授權機制
  - 金流 / 付款整合
  - 第三方服務（Supabase / Auth0 / LINE Pay / Stripe 等）

### Phase 2：Passive Recon（被動觀察，任何訪客都看得到）
對目標 URL 執行：
```bash
bash scripts/passive_recon.sh <URL>     # headers / TLS / robots / security.txt
bash scripts/bundle_scan.sh <URL>       # JS chunks 找秘密洩漏
```
AI 讀輸出，判斷：
- Security headers 覆蓋度（CSP / HSTS / X-Frame-Options / Referrer / Permissions）
- 公開檔洩漏（.env / .git / source maps / DS_Store → scripts 不查的附加清單可手動 curl）
- JS bundle 秘密命中
- robots.txt 洩漏的內部路徑線索

### Phase 3：White-Box Audit（讀 code、AI 判斷）
針對 Phase 1 列的每個 endpoint：
- **認證**：auth check 在哪？用什麼演算法（字串比對 vs constant-time）？
- **輸入驗證**：有沒有 schema（zod/joi/yup）？regex 邊界？
- **授權**：該 endpoint 只 admin 能用、或全 public？有沒有 IDOR 風險？
- **金流**：金額是否 server hardcoded？confirm 階段是否從 DB 二次取值？
- **Rate limiting**：有沒有？用什麼機制？fail-open vs fail-closed？
- **秘密管理**：`.env` 是否 gitignored？service role key 是否只在 server-side？
- **Markdown / HTML 渲染**：有沒有 `dangerouslySetInnerHTML` + 未 sanitize？

### Phase 4：Active Testing（**必須取得用戶授權後才能執行**）

```
⚠️ 停下來問用戶：
「Phase 4 會對站送測試 payload（XSS / SQLi / admin bypass 嘗試 / rate limit 探測）。
 你授權我對 <URL> 執行主動測試嗎？」
```

授權後執行：
- `bash scripts/http_method_fuzz.sh <endpoint>` — 方法列舉
- 手動構造 payload 測：
  - XSS 反射（URL 參數 / 表單欄位）
  - SQL injection 樣式（給被 schema 擋的確認）
  - Admin bypass（空字串 / null byte / 大小寫 / 超長）
  - Open redirect（cancel / confirm / redirect 參數）
  - CSRF preflight（evil origin POST）
  - Rate limit 測試（連打某端點看 429）
- **不做**：實際利用、資料取出、長時間 DoS

### Phase 5：依賴層 + 修復 + 驗證 + 報告
- `bash scripts/dep_cve_scan.sh <project-path>` — npm audit
- 整理所有發現，按 `references/severity_matrix.md` 分級
- 用 `references/report_template.md` 輸出報告
- 若用戶授權，實施修復 → `next build` → commit → deploy → live 驗證

## 常見 AI 失誤模式（務必警覺）

1. **narrative-filling**：對觀察到的現象填入沒證據的解釋（例：「他們刻意 Risk-Based Security」）。**不知道原因就說不知道**，用「我推測」vs「有證據」明確區分。
   參考：`meta/feedback/dont_fill_uncertainty_with_narrative.md`

2. **audit 姿態 vs design 姿態混淆**：只找「既有 code 的 bug」會漏掉「該有但沒有的防線」（例：CSP report-uri / robots.txt）。**Phase 3 結束後主動問自己**：
   - 同規模站常做但我這站沒做的是什麼？
   - 對照 OWASP ASVS / MDN Web Security 最佳實踐有什麼缺口？

3. **漏掉依賴層**：專注應用層很容易忘記 Phase 5 的 `dep_cve_scan.sh`。**不要跳過**。

4. **對「別人的站」沒授權亂打**：Phase 4 只能對用戶自有或明確授權的站執行。不確定就停。

## 輸出規範

報告用 `references/report_template.md` 格式，至少包含：
- 問題分級表（HIGH / MEDIUM / LOW）
- 每項：發現 / 風險 / 修法 / 嚴重度理由
- 修復後 live 驗證結果（若有實施）

## 不要做

- **不要**把 SKILL.md 當死稿按步驟跑。AI 的價值在判斷，不在朗讀清單
- **不要**跑 script 就當作「做完了」。Scripts 只覆蓋被動觀察 + 依賴掃描，白箱審計和主動測試要 AI 判斷
- **不要**在未授權情況下對第三方站做 Phase 4
- **不要**填 narrative — 觀察是觀察，推論要標註「推測」

## 版本
- v0.1 — 2026-04-18 初版，基於 setupbro 2026-04-17 實戰審計經驗抽取
