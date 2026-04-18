# Attack Vectors — 13 項標準攻擊向量清單

用於 Phase 4（主動測試，需用戶授權）。每項含：**向量 / payload 範例 / 預期反應 / 若反應異常代表什麼**。

---

## 1. XSS — 反射型

**Payload 位置**：URL 查詢參數、表單欄位、URL path 片段
**範例**：
```
?reason=<script>alert(1)</script>
?q=<img src=x onerror=alert(1)>
```
**預期反應**：React/Vue 自動 escape，payload 當文字顯示；或 server 端 sanitize 後丟棄
**異常反應**：payload 在 DOM 中以可執行形式出現（`<script>` 真的執行）
**判讀**：查看 response body 是否含原始 payload（非 escape 版本）；若有 `dangerouslySetInnerHTML` 且內容未 sanitize 就是高風險

## 2. SQL Injection 樣式

**Payload**：
```
phone=09' OR '1'='1
id=1 UNION SELECT * FROM users--
```
**預期反應**：schema 驗證（zod/joi）層 400 擋下，不到 DB
**異常反應**：500 錯誤 + SQL syntax error leak / 200 且回傳未授權資料
**判讀**：即使現代 ORM 自動參數化，schema 層擋下才是正確防禦

## 3. Type Confusion

**Payload**：把應為 string 的欄位傳 array / object / number / null
```json
{"phone": ["0912345678", "admin"]}
{"phone": {"$ne": null}}   // NoSQL injection 樣式
```
**預期反應**：schema 驗證 400
**異常反應**：500 或 200 帶異常行為（特別是 NoSQL）

## 4. Null Byte / Control Chars

**Payload**：欄位含 `\x00` / `\n` / `\r\n`
**預期反應**：400（應被 regex 擋）或正常處理為字串
**異常反應**：500 帶 stack trace（info leak）/ 繞過某些字串匹配

## 5. 超長 payload（DoS 探測，不是實際 DoS）

**Payload**：單一欄位 5000~50000 字
**預期反應**：400（schema max() 限制）
**異常反應**：500 超時 / 記憶體爆炸（代表無長度驗證）

## 6. Path Traversal

**Payload**：
```
/blog/../../../etc/passwd
/api/../admin
/download?file=../../secrets
```
**預期反應**：403 / 404 / 正常 route 處理
**異常反應**：200 且回傳其他路徑資源
**判讀**：Next.js / 靜態路由器通常已擋，但自定 file-serving API 要檢查

## 7. HTTP 方法 fuzzing

用 `scripts/http_method_fuzz.sh`。
**預期**：POST-only endpoint 對 GET/PUT/DELETE 回 405
**異常**：PUT 回 200（無預期寫入？）/ TRACE 回 200（XST 攻擊可能）

## 8. Admin 認證繞過

**Payload** 樣式：
- 空字串密碼
- 大小寫變體（`X-ADMIN-PASSWORD` vs `x-admin-password`）
- 陣列 / 物件取代字串
- Null byte 嵌入
- 超長（10000+ 字）— 測 timing-safe 是否早退
- 多個 header 重複
**預期**：全 401，無 timing leak
**異常**：500 / 回應時間對超長 payload 不對稱 / 大小寫繞過

## 9. Open Redirect

**Payload**：
```
/api/auth/callback?next=https://evil.example
/logout?redirect_to=//evil.example
```
**預期**：重導目的地是站內 relative path，外部 URL 被拒或 normalized
**異常**：直接 302/307 到外部 URL → 可用於 phishing

## 10. CSRF（跨站請求偽造）

**Test**：從 evil origin 發 preflight
```bash
curl -X OPTIONS -H "Origin: https://evil.example" \
     -H "Access-Control-Request-Method: POST" \
     <endpoint>
```
**預期**：無 `Access-Control-Allow-Origin` header → 瀏覽器阻擋
**異常**：回應含 `Access-Control-Allow-Origin: *` 或 evil domain → CSRF 風險
**判讀**：即使 server 不 set CORS，**custom header 要求**（如 `x-admin-password`）也是一種隱性 CSRF 防護（觸發 preflight）

## 11. Rate Limit 探測

**Test**：連打某端點 N 次（N = 限額 + 15）
**預期**：第 limit+1 次回 429，含 `Retry-After` header
**異常**：全部 200 → 無限流 / 400/500 但無 429 → 限流機制不對

## 12. Bundle Secret Leak

用 `scripts/bundle_scan.sh`。
**預期**：0 命中秘密 pattern
**異常**：任何 hit → 立即需要輪換秘密 + 修 env 變數暴露

## 13. 依賴層 CVE

用 `scripts/dep_cve_scan.sh`。
**預期**：0 critical / 0 high
**異常**：critical/high 存在 → 立即修（優先 direct deps）

---

## 不在本清單但值得補的

- **ReDoS**（正則表達式 DoS）— 特定 regex 遇特定輸入會掛，需人工看 schema
- **XXE** — 若有 XML 處理
- **SSRF** — 若有 server 主動 fetch user 提供 URL 的功能
- **Prototype pollution** — 若有 `Object.assign` 或 deep merge 用戶輸入
- **Race conditions** — 特定業務邏輯（例：訂單付款 idempotency）

本 SOP v0.1 不涵蓋以上，視專案性質判斷是否加。

---

## 交叉驗證原則

若條件允許，同個站可請**另一個 AI**（Opus / Gemini / GPT）做一輪審計，對照兩邊的發現清單。兩個都漏的項目通常是「AI 預設產出」的集體盲區（例：本次 setupbro session 中 CSP report-uri / CSRF cookie / robots.txt 這三項兩個 AI 都沒主動提）。
