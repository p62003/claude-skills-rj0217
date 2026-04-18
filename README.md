# claude-skills-rj0217

> **SOP-driven Claude Code skills collection.** Each skill delegates deterministic work to scripts and keeps AI focused on judgment. Skills are guides for AI, not command lists.

**📄 Available in**: [繁體中文](./README_zh.md)

[Quick Install](#quick-install) · [Skills](#included-skills) · [Philosophy](#design-philosophy) · [Backward Compatibility](#backward-compatibility) · [Support the project](#support-the-project)

---

## What this is

A curated collection of Claude Code skills under one consistent design philosophy. Each skill ships with:

- **`SKILL.md`** — flow framework, judgment guidance, common AI failure modes
- **`scripts/`** — deterministic, repetitive work delegated to bash
- **`references/`** — checklists, severity matrices, report templates
- **`docs/`** — fact source + iteration history

The AI reads the SOP and applies judgment; repetitive work is handed off to scripts. This saves tokens, ensures reproducibility, and keeps AI focused on value-add decisions.

**Scope**: this repo is a *collection*, not a single-topic toolbox. Current inventory is security-focused (v1 is `pre-launch-audit`), but future additions may span documentation workflow, memory management, code review, and other domains.

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
- **Severity matrix** (HIGH/MEDIUM/LOW/GOOD) with explicit anti-patterns
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
├── README.md / README_zh.md
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
4. Update the "Included Skills" table in both READMEs
5. Commit + push

**Skill iteration**:
1. Edit + test in dev
2. `cp -r` to publish (skip `docs/` — those only live on publish side)
3. Prepend an entry to `<skill>/docs/work_progress.md`
4. Commit + push

---

## Support the project

If these skills save you time or money (e.g. skipping a paid pentest, or faster shipping), consider supporting further development:

### ☕ Ko-fi (recommended — credit card / PayPal, one-click)

[![Support on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rj0217)

### 🪙 Crypto (USDT / USDC on BEP20 / BSC)

```
0x55c439b27807415e80452f59ba00fee3441a802d
```

**Network**: BEP20 (Binance Smart Chain).
**Accepted**: USDT, USDC.
⚠️ Other networks (ERC20 / TRC20) are NOT monitored on this address — do not send.

### ⭐ GitHub Star

Costs nothing but helps discoverability. If this repo is useful, a star tells others it's worth their time.

---

## Contact

- **Discord**: https://discord.gg/x52CBg4rcE
- **Email**: dont.stop.ha@gmail.com

---

## Maintainer

[rj0217](https://github.com/p62003) · created 2026-04-18
