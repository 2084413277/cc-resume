<div align="center">

# cc-resume

**A Claude Skill for crafting single-page A4 Chinese-language resumes**

HTML/CSS template · embedded fonts · headless PDF export · strict 210 × 297 mm

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skill](https://img.shields.io/badge/Claude-Skill-D97757)](SKILL.md)
[![Platform](https://img.shields.io/badge/platform-Windows-0078D4)](#requirements)

[**Skill →**](SKILL.md) · [**Template →**](examples/template.html) · [**Quick Start →**](#quick-start)

</div>

---

## What this is

A self-contained playbook for producing **publication-grade Chinese resumes** that fit on **exactly one A4 page**. Drop `SKILL.md` into Claude / Cursor / Cline, and the model will:

- Pick a sensible section ordering for your major (research / IC / translation / product / …).
- Ask you for the accent color before styling — no surprise palettes.
- Embed `Noto Sans SC + IBM Plex Sans + Newsreader` via `@font-face` so the PDF doesn't fall back to system fonts on Windows.
- Render through headless Edge with a built-in page-count check; if it's not exactly 1 page, the doc lists the precise CSS levers to buy back vertical space.
- Stay faithful to your source content — no paraphrasing, no inferred personal details, no surprise English/Chinese swaps.

---

## Highlights

| | |
|---|---|
| **Sino-Western typography** | IBM Plex Sans (Latin) + Noto Sans SC (CJK) + Newsreader (paper citations). Embedded as `.woff2` for offline rendering. |
| **Three-color theme system** | Re-skin the entire resume by changing three CSS vars: `--accent`, `--accent-deep`, `--tag-bg`. |
| **Strict A4** | `210mm × min-height: 297mm` with no silent clipping. The skill doc maps each CSS lever to its px-savings. |
| **CSS-only markers** | Bullet triangles via `clip-path`, sub-heading bars via pseudo-elements. No ugly Unicode block characters. |
| **One-shot PDF build** | `scripts/build-pdf.ps1` runs Edge headless, kills stale processes, handles file-lock from open PDF viewers, and prints a page-count warning if you slip past A4. |
| **Faithful to the source** | The skill explicitly forbids paraphrasing, inferring personal facts (age / 民族 / 党员), or dropping sections to force fit. |

---

## Quick start

```powershell
# 1. Clone
git clone https://github.com/2084413277/cc-resume.git
cd cc-resume

# 2. Download the embedded fonts (one-time, ~5 MB)
.\scripts\fetch-fonts.ps1

# 3. Copy the template, fill in your content
Copy-Item examples\template.html my-resume.html
# edit my-resume.html — replace every {{PLACEHOLDER}}

# 4. Render to PDF
.\scripts\build-pdf.ps1 -Html my-resume.html -Pdf my-resume.pdf
```

Open `my-resume.pdf`. If you're at 2 pages, the skill doc has an A4-fit lever table — every margin/line-height value is mapped to its rough px-savings.

---

## Repository layout

```
cc-resume/
├── SKILL.md                  ← the skill itself (load into Claude / Cursor / Cline)
├── README.md
├── LICENSE                   ← MIT
├── .gitignore
├── examples/
│   └── template.html         ← blank A4 resume with {{PLACEHOLDER}} slots
└── scripts/
    ├── fetch-fonts.ps1       ← downloads .woff2 fonts into fonts/
    └── build-pdf.ps1         ← headless-Edge PDF render + page-count check
```

`fonts/` is `.gitignore`'d — fetch on first run.

---

## Use as a Claude Skill

1. Drop `SKILL.md` into the skills folder of your AI coding tool (Claude Code, Cursor, Cline, Continue, …).
2. When you start a new resume project, paste your raw text and ask:
   > *"Build me a single-page A4 Chinese resume from this content."*
3. The skill will walk through:
   - Choosing accent color (it will **ask**, not assume)
   - Picking section ordering for your major
   - Setting up `@font-face` and CSS vars
   - Rendering, page-count checking, iterating
   - Trimming or loosening spacing to hit exactly 1 page

The skill is also useful **outside** AI tooling — it's a fully readable design doc you can follow by hand.

---

## What it intentionally won't do

- Make up personal facts (age, ethnicity, political affiliation) — it asks.
- Translate or paraphrase your wording — it stays faithful to the source.
- Remove sections to force A4 fit without checking with you first.
- Use `max-height: 297mm; overflow: hidden` to "force" 1 page — that silently clips content.
- Rely on `PingFang SC` from system fonts — it embeds a free equivalent.

---

## Requirements

- **Windows** with PowerShell 5.1+ (the build scripts are PowerShell; on macOS/Linux the same logic translates trivially — PRs welcome).
- **Microsoft Edge** (any modern version) — used in headless mode for PDF rendering. Chrome works too with a one-line script tweak.
- **Network** for the one-time `.woff2` font fetch from jsDelivr.

---

## Customization recipes

**Re-skin to a different brand color** — change three values:

```css
:root {
  --accent:      #2C1A5C;   /* your primary */
  --accent-deep: #1E1241;   /* ~70% lightness of primary */
  --tag-bg:      #ece8f5;   /* ~6% tint on white */
}
```

**Swap section icons** — the template uses inline SVG `stroke="var(--accent)"`. Pick any 16×16 line-icon (Lucide, Heroicons, Tabler) and paste.

**Switch bullet style** — the marker is a CSS triangle:
```css
.entry-bullets li::before {
  clip-path: polygon(0 0, 100% 50%, 0 100%);  /* triangle */
  /* or: border-radius: 50%;                   ← dot */
  /* or: transform: rotate(45deg);              ← diamond */
}
```

**Use a serif display face for the name** — add `Noto Serif SC` to the `font-family` of `.header-name` after fetching it via the script.

---

## Status & roadmap

Pre-1.0. The skill works for the common Chinese-resume genres (research, IC/AI, translation, product). Planned:

- macOS / Linux build script (`build-pdf.sh`)
- More section presets (创业 / 公务员 / 金融)
- A "double resume" template (中英对照)
- Optional Tailwind-style utility build

Issues, PRs, screenshots welcome.

---

## License

[MIT](LICENSE) © 2026 cc-resume contributors. Free for personal and commercial use; please retain the copyright notice.

The bundled fonts retain their own licenses (SIL OFL for Noto, OFL for IBM Plex Sans, OFL for Newsreader) — all permissively licensed.
