# zh-resume-a4

> A Claude Skill for building **single-page A4 Chinese-language resumes** as HTML/CSS, then exporting to PDF via headless Edge/Chrome.

中文简历用 HTML/CSS 排版，严格压在 A4 一页内，导出为印刷级 PDF — 这套 skill 把整个流程的字体、配色、版式、A4 适配杠杆、PDF 导出脚本写成可复用的工作手册。

---

## What's in here

| File | Purpose |
|---|---|
| [`SKILL.md`](SKILL.md) | The skill itself — load this into Claude / Cursor / Cline / etc. |
| [`examples/template.html`](examples/template.html) | A blank resume template using the SKILL's CSS conventions, with `{{PLACEHOLDER}}` slots |
| [`scripts/fetch-fonts.ps1`](scripts/fetch-fonts.ps1) | Downloads the embedded `.woff2` fonts (Noto Sans SC + IBM Plex Sans + Newsreader) into `fonts/` |
| [`scripts/build-pdf.ps1`](scripts/build-pdf.ps1) | Renders any HTML to PDF via headless Edge, with page-count sanity check |
| `LICENSE` | MIT |

The `fonts/` folder is `.gitignore`'d — run `scripts/fetch-fonts.ps1` once to populate it.

---

## Quick start

```powershell
# 1. Clone
git clone https://github.com/<you>/cc-resume.git
cd cc-resume

# 2. Download embedded fonts (one-time, ~5 MB)
.\scripts\fetch-fonts.ps1

# 3. Copy the template, fill in your content
Copy-Item examples\template.html my-resume.html
# edit my-resume.html in your editor — replace every {{PLACEHOLDER}}

# 4. Render to PDF
.\scripts\build-pdf.ps1 -Html my-resume.html -Pdf my-resume.pdf
```

Open `my-resume.pdf`. If you're at 2 pages, see the **A4-fit levers** table in [`SKILL.md`](SKILL.md#strict-a4-fit-1-page).

---

## How to use as a Claude Skill

1. Drop `SKILL.md` into the skills folder of your AI coding tool (Claude Desktop, Claude Code, Cursor, Cline, etc.).
2. When you start a new resume project, ask the model: *"build me a single-page A4 Chinese resume from this raw text"* — and paste your content.
3. The skill will:
   - Pick a sensible section ordering for your major (research / translation / product / etc.)
   - Ask you for the accent color before styling
   - Embed the fonts via `@font-face`
   - Render to PDF and verify it actually fits on one page
   - Iterate with you on bullet structure, colors, and spacing

It will **not**:
- Invent personal facts (age, ethnicity, party affiliation) — it will ask
- Drop sections to force A4 fit without confirming with you
- Translate or paraphrase your wording — it stays faithful to the source

---

## Design choices, briefly

- **Typography pairing**: IBM Plex Sans (Latin) + Noto Sans SC (CJK) + Newsreader (paper citation serif). Embedded as `.woff2` so Windows headless Edge doesn't fall back to a system font silently.
- **Strict A4**: `width: 210mm; min-height: 297mm`. No `max-height + overflow: hidden` — that silently clips your content. The skill doc lists the exact CSS levers (section margins, line-heights, header padding) that buy back ~10–30 px each so you can tune to fit.
- **One accent color**: defined as `--accent` / `--accent-deep` / `--tag-bg` CSS vars. Re-skin the whole resume by changing three hex codes.
- **CSS-rendered markers**: bullet triangles via `clip-path`, sub-heading vertical bars via pseudo-element. Avoids ugly Unicode block characters that render unevenly across fonts.
- **Headless PDF**: uses Edge (or Chrome) with `--print-to-pdf`. The skill doc has a workaround for the common Windows pitfall where a PDF viewer holds the file open and blocks overwrite.

---

## Status

Pre-1.0. The skill works for the common Chinese-resume genres (research, IC/AI, translation, product), but section orderings and patterns will evolve. Issues / PRs welcome.

## License

MIT — see [`LICENSE`](LICENSE).
