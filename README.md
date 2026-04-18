# claude-skills-rj0217

> **SOP-driven Claude Code skills — frameworks for AI, not command lists.**
> First release: `pre-launch-audit` — a complete pre-deployment web security audit SOP.

[Quick Install](#quick-install) · [Skills](#included-skills) · [Philosophy](#design-philosophy) · [Backward Compatibility](#backward-compatibility) · [繁體中文](#繁體中文)

---

## What this is

A curated collection of Claude Code skills that treat **skill** as **Standard Operating Procedure (SOP)** rather than command scripts. Each skill provides:

- **`SKILL.md`** — flow framework, judgment guidance, common AI failure modes
- **`scripts/`** — deterministic, repetitive work delegated to bash
- **`references/`** — checklists, severity matrices, report templates
- **`docs/`** — fact source + iteration history

The AI reads the SOP and applies judgment; repetitive work is handed off to scripts. This saves tokens, ensures reproducibility, and keeps AI focused on value-add decisions.

---

## Quick Install

### Option A · Claude Code Plugin (Recommended)

```
/plugin install https://github.com/p62003/claude-skills-rj0217
```

Or via marketplace (if the repo evolves into one later):
```
/plugin marketplace add https://github.com/p62003/claude-skills-rj0217
/plugin install claude-skills-rj0217
```

### Option B · Manual Copy (works with Claude Desktop / any version)

```bash
git clone https://github.com/p62003/claude-skills-rj0217.git
cp -r claude-skills-rj0217/skills/* ~/.claude/skills/
```

Restart Claude Code / Desktop to load.

---

## Included Skills

| Skill | Version | Purpose |
|---|---|---|
| [pre-launch-audit](./skills/pre-launch-audit/) | v0.1.1 | Complete web security audit SOP — run before shipping to production or public demo |

### pre-launch-audit in 30 seconds

Designed for Next.js / React / Vue / static sites before going public. Covers:

- **5-phase flow**: context loading → passive recon → white-box audit → active testing (authorization-gated) → fix + verify + report
- **4 scripts**: `passive_recon.sh`, `bundle_scan.sh`, `http_method_fuzz.sh`, `dep_cve_scan.sh`
- **13 attack vectors** mapped with expected/anomalous responses (XSS, SQLi, path traversal, CSRF, rate-limit probing, bundle secret leaks, dependency CVEs, etc.)
- **Severity matrix** (HIGH/MEDIUM/LOW/GOOD) with explicit anti-patterns to avoid
- **Report template** including meta-learning section and competitive positioning block

**Differentiator from Claude's built-in `/security-review`**: `/security-review` audits pending changes on the current branch; `pre-launch-audit` audits the entire site including live behavior and can execute authorized active tests.

---

## Design Philosophy

All skills in this repo follow one principle:

| Layer | Content | Who does it |
|---|---|---|
| **SKILL.md** | SOP flow, judgment guidance, failure modes | AI reads + judges |
| **scripts/** | Deterministic, repetitive work | AI invokes bash |
| **references/** | Checklists, matrices, templates | AI reads as needed |
| **docs/** | Fact source + iteration log | Maintainer writes |

**Skill ≠ command list.** A skill is an SOP for the AI to read and a toolbox for the AI to use. Judgment is the AI's job; repetitive execution is delegated to scripts.

Why this matters:
- **Token efficiency**: AI doesn't regenerate the same curl chains every session
- **Reproducibility**: scripts give deterministic output, AI behavior can vary
- **Focus**: AI value is in judgment, not in executing boilerplate
- **Cross-session stability**: scripts aren't affected by context window or model version
- **No false sense of completion**: framework-style `SKILL.md` forces per-step thinking rather than checklist checkmarks

---

## Repository Structure

```
claude-skills-rj0217/
├── .claude-plugin/
│   └── plugin.json                # Claude Plugin manifest
├── README.md
├── .gitignore
└── skills/
    └── <skill-name>/
        ├── SKILL.md               # SOP (main)
        ├── scripts/               # Deterministic tools
        ├── references/            # Attack vectors / severity / templates
        └── docs/                  # Fact source + iteration history
            ├── index.md
            └── work_progress.md
```

---

## Backward Compatibility

This repo commits to:

- **Adding a new skill** = only add a directory under `skills/`; no structural change
- **Skill version upgrades** = logged in each skill's `docs/work_progress.md`; no breaking changes to the `SKILL.md` trigger conditions
- **Future marketplace upgrade** (if the collection grows large enough) = this repo will remain a valid plugin install path; existing users will not need to migrate

---

## Development Workflow (maintainer only)

```
Dev:     ~/.claude/skills/<name>/            # WSL ext4, Claude Code reads here directly
Publish: /mnt/d/SKILL/skills/<name>/         # This repo, git-tracked
```

**New skill**:
1. Develop + test in `~/.claude/skills/<new>/`
2. When stable, `cp -r` to `/mnt/d/SKILL/skills/<new>/`
3. Write `docs/index.md` (fact source) + `docs/work_progress.md` (first iteration log)
4. Update the "Included Skills" table in this README
5. Commit + push

**Skill iteration**:
1. Edit + test in dev
2. `cp -r` to publish (skip `docs/` — those only live on publish side)
3. Prepend an entry to `<skill>/docs/work_progress.md`
4. Commit + push

---

## Maintainer

[rj0217](https://github.com/p62003) · created 2026-04-18

---

## 繁體中文

### 簡介

rj0217 自建的 Claude Code skills 集合，以 Claude Plugin 形式發佈。**所有 skill 遵循同一哲學：SKILL.md 是 SOP 框架，不是命令清單**；重複性工作交給 `scripts/`，判斷留給 AI。

### 目前收錄

| Skill | 版本 | 用途 |
|---|---|---|
| [pre-launch-audit](./skills/pre-launch-audit/) | v0.1.1 | 產品上線前的完整資安審計 SOP — Web 產品 demo 推廣前使用 |

### 為什麼是 SOP 不是命令清單

- **省 token**：AI 不用每 session 重新組合同樣的 curl 指令
- **可重現**：scripts 固定輸入固定輸出，AI 行為不穩定
- **專注判斷**：AI 的 value 在判斷，不在執行模板
- **跨 session 穩定**：scripts 不受 context / model version 影響
- **避免 checklist 假象**：框架式 SKILL.md 強迫 AI 每步驟思考，不是走完就當完成

### 快速安裝

**方式 A**（Claude Code）：
```
/plugin install https://github.com/p62003/claude-skills-rj0217
```

**方式 B**（手動，相容 Claude Desktop）：
```bash
git clone https://github.com/p62003/claude-skills-rj0217.git
cp -r claude-skills-rj0217/skills/* ~/.claude/skills/
```

### 向後兼容承諾

- **加新 skill** = 只在 `skills/` 新增目錄，不動既有結構
- **版本升級** = 記在 skill 自己的 `docs/work_progress.md`，不破壞觸發條件
- **未來升級 marketplace**（若收錄規模變大）= 本 repo 保留為 plugin，既有 install 路徑永遠有效

### 與官方 `/security-review` 的差異

官方的 `/security-review` 審查 current branch 的 pending changes；`pre-launch-audit` 審查整個站包含線上行為，含可授權執行的主動測試。**互補不取代。**

詳細說明見每個 skill 的 `docs/index.md`。
