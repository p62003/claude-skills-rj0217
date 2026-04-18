# Severity Matrix — 問題分級判準

AI 在 Phase 5 整理發現時，按此分級。**不要套用公式，用判斷**。

---

## 🔴 HIGH — 必須上線前修

符合以下任一：
- **直接可被利用**：無需特殊條件，請求打過去就生效
- **影響金流 / 用戶資料 / 認證**
- **公開端點沒 auth 或 auth 可繞過**
- **秘密在 client bundle 外洩**（service role key / API secret / admin password）
- **SQL injection / RCE 等經典重大漏洞確認存在**
- **依賴層 critical CVE** 且該 package 在熱路徑

範例（從 setupbro 實戰）：
- `/api/pay/test-request` 公開無 auth，可任意創 1 元訂單
- 全站無 rate limit（單純可暴力破解 admin）
- admin 字串比對非 timing-safe + 無 rate limit 組合

---

## 🟡 MEDIUM — 應該上線前修，但不修也不會立刻被打爆

符合以下任一：
- **資訊洩漏**（bundle、headers、error messages）不直接可利用但輔助後續攻擊
- **缺少 defense-in-depth**（例：缺 CSP / Frame-Options / nosniff）
- **有防護但防線弱**（例：admin 密碼只做字串比對、無 timing-safe）
- **可被枚舉但資料已遮蔽**（例：手機號查詢有遮隱私但可確認存在）
- **依賴層 high CVE** 但在冷路徑 / 配置可繞過

範例：
- 缺 Permissions-Policy / Referrer-Policy
- 訂單查詢可枚舉手機號（雖回傳資訊已遮）
- blog 用 marked 未 sanitize（但來源可信）

---

## 🟢 LOW — 可留待後續 polish

符合：
- **Best-practice 偏離但無實質風險**
- **純 UX 問題被誤標成資安**（例：錯誤訊息應 400 但回 500）
- **理論攻擊在現實條件下幾乎不成立**（例：HTTPS 下的 timing attack 對短字串）

範例：
- `x-matched-path` header 露出內部路由
- `/api/orders/query` 空 body 回 500 而非 400
- HSTS 缺 `preload`

---

## 🔵 GOOD — 做得好的地方（一定要列）

**不要只列壞的**。把做對的列出來，避免「為了寫報告而誇大問題」的偏差，也讓用戶知道哪些東西保留下來就好。

範例：
- ✅ LINE Pay 簽章 HMAC-SHA256 正確
- ✅ 金額 server 端 hardcoded，不採信前端
- ✅ Bundle scan 零命中秘密

---

## 判級常見陷阱

1. **對獨立站用大廠標準打分** — 企業有 Risk-Based trade-off 空間，獨立站不行，判級時要注意對象規模
2. **只看威脅不看影響**：「有 XSS」但如果那個頁面無用戶認證 / 無敏感資料顯示，影響就小
3. **以 checklist 取代判斷**：CSP 沒加就等於 HIGH？錯 — 要看該站的實際 XSS 攻擊面有多大
4. **不列 GOOD**：如果只列壞的，用戶會以為站全面崩壞，扭曲了實際風險畫面

---

## 跨組織比對

**不要**把分級跟「同業 benchmark」混為一談。
- HIGH/MED/LOW 是**對這個站**的嚴重度
- 「跟 XX 站比我們多或少」是**相對位置**，該放在報告的另一個 section，不是分級欄
