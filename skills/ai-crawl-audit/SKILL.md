---
name: ai-crawl-audit
description: 從 AI 爬蟲視角診斷網站的可爬取性與內容可發現性。餵一個 URL，跑完 robots.txt → sitemap → 首頁 → llms.txt → 關鍵頁面的檢查流程，輸出結構化診斷報告。適用於所有網站（Docusaurus / Next.js / Hugo / WordPress / 靜態站皆可）。
---

# AI Crawl Audit SOP

## 使用時機
- 新站上線前，確認 AI 爬蟲能正確理解站點結構
- 既有站流量下滑，懷疑 AI 搜尋引擎（Perplexity / ChatGPT / Gemini）無法爬取
- 加了 llms.txt 後想驗證是否正確
- 跨站點批次檢查（例：同時審計旗下多個專案）

## 前置確認
1. 取得目標 URL（必須是公開可訪問的網址）
2. 如果有本地源碼路徑，一併取得（可跳過部分 WebFetch，直接讀檔）

---

## Phase 1：基礎設施檢查

用 WebFetch 依序抓取以下檔案，記錄結果：

### 1.1 robots.txt
```
WebFetch: {URL}/robots.txt
```
檢查項：
- [ ] 是否存在（非 404）
- [ ] `User-agent: *` 是否 `Allow: /`（或至少未 Disallow 主要內容路徑）
- [ ] 是否有 `Sitemap:` 指向
- [ ] 是否有 `Llms-txt:` 指向（llmstxt.org 規範）
- [ ] 是否針對特定 AI bot 做了限制（GPTBot / ClaudeBot / PerplexityBot / Bytespider）

### 1.2 sitemap.xml
```
WebFetch: {URL}/sitemap.xml
```
檢查項：
- [ ] 是否存在
- [ ] 總 URL 數量
- [ ] URL 品質分析：
  - 有多少是 tag/category 聚合頁？（佔比 > 30% = 稀釋警告）
  - 有多少是實際內容頁？
  - 有沒有預設模板頁、測試頁、或不該被索引的頁面？
  - URL 路徑是否一致、有規律？（混亂的路徑結構 = 警告）
- [ ] 是否有 sitemap index（多個 sitemap 分檔）

### 1.3 llms.txt
```
WebFetch: {URL}/llms.txt
```
檢查項：
- [ ] 是否存在（非 404）
- [ ] 格式是否符合 llmstxt.org 規範（`# 標題`、`> 摘要`、`## 分類`、`- [連結](URL)` 格式）
- [ ] 內容是否完整涵蓋站點主要分類
- [ ] 連結是否為絕對 URL 且可訪問

---

## Phase 2：內容可發現性

### 2.1 首頁
```
WebFetch: {URL}/
```
檢查項：
- [ ] 內部連結 vs 外部連結比例（外部 > 內部 = 警告，爬蟲找不到內容）
- [ ] 是否有指向主要內容區的導航結構
- [ ] Meta tags 完整性：
  - `<title>` 是否有意義
  - `<meta name="description">` 是否存在且有內容
  - `og:title` / `og:description` / `og:image`
  - `canonical` URL
- [ ] 是否有 JSON-LD 結構化資料

### 2.2 主要內容入口頁
根據 sitemap 或導航結構，選擇 2-3 個主要的內容入口頁（如 /docs、/blog、/articles）：
```
WebFetch: {URL}/{content-path}
```
檢查項：
- [ ] 頁面是否正常回應（非 404、非空白、非搜尋頁）
- [ ] 是否有側邊欄 / 目錄結構讓爬蟲發現子頁面
- [ ] 是否有 breadcrumb 導航
- [ ] 頁面標題和 meta 是否有意義（不是「搜尋」或「首頁」等無內容標題）

### 2.3 內容頁抽樣
從 sitemap 隨機抽 2-3 篇實際內容頁：
```
WebFetch: {URL}/{sample-article}
```
檢查項：
- [ ] 內容是否為 SSR/SSG（HTML 中有實際文字內容，不是純 SPA 空殼）
- [ ] 標題層級是否正確（h1 → h2 → h3）
- [ ] 是否有作者 / 日期 / 最後更新等 metadata
- [ ] 內部連結是否指向其他相關內容

---

## Phase 3：已知陷阱檢查

根據技術棧，檢查常見問題：

### 通用陷阱
- [ ] SPA 無 SSR：首頁/內容頁 HTML 中是否只有空的 `<div id="root">`
- [ ] 靜態 fallback 位置錯誤：如果有 crawler fallback HTML，必須放在 React mount point **外部**（sibling div），不能放在 `#app` 內部 — `createRoot().render()` 會立刻清空 mount point，半 JS 爬蟲（執行 JS 但未完整渲染）會兩頭落空
- [ ] JavaScript-only 導航：爬蟲無法跟隨的 onClick 路由
- [ ] 搜尋頁劫持內容路由：搜尋 plugin 覆蓋了內容索引路徑
- [ ] 無限滾動無分頁：爬蟲只能看到第一頁內容

### 框架特定
| 框架 | 常見問題 |
|---|---|
| Docusaurus | `markdown-page.md` 預設模板被索引；minisearch 路由衝突；tag 頁未排除 |
| Next.js | `_next/data` 路徑洩漏；ISR 頁面 stale；`noindex` 被誤用在有價值頁面 |
| Hugo | `draft: true` 頁面意外發布；taxonomy 頁稀釋 sitemap |
| WordPress | `?p=123` 和 pretty URL 重複；`/wp-admin/` 在 robots.txt 暴露後台 |

---

## Phase 4：報告產出

將所有檢查結果整理為以下格式：

```markdown
# AI Crawl Audit Report — {site name}

**目標**：{URL}
**日期**：{date}
**技術棧**：{detected or provided}

## 總評
{一句話概括：良好 / 有問題需修復 / 嚴重不友善}

## 嚴重問題（必須修復）
{列出所有 critical findings}

## 警告（建議修復）
{列出所有 warnings}

## 缺失項（建議補齊）
{列出 nice-to-have 項目}

## 正常項
{列出通過檢查的項目，確認使用者知道哪些沒問題}

## 建議修復優先順序
1. ...
2. ...
3. ...
```

---

## 補充：llms.txt 建立指引

如果診斷結果建議建立 llms.txt，參考以下格式（llmstxt.org 規範）：

```markdown
# {Site Name}

> {一句話描述站點用途和語言}

## Site Info

- URL: {url}
- Language: {language code}
- Content type: {content types}

## Categories

### {Category Name}
- [{Article Title}]({full URL})
- [{Article Title}]({full URL})
```

放置位置：靜態資源根目錄（Docusaurus: `static/`、Next.js: `public/`、Hugo: `static/`）
同時在 `robots.txt` 加 `Llms-txt: {URL}/llms.txt`
