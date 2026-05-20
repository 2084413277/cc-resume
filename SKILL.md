---
name: cc-resume
description: Build single-page A4 Chinese-language resumes as HTML/CSS, then export to PDF via headless Edge/Chrome. Covers Sino-Western typography pairing, user-driven theme colors, strict A4 fit (210mm × 297mm), and pitfalls when iterating with the user.
license: Internal use only.
---

# Single-Page A4 Chinese Resume — HTML → PDF

## When to use

The user wants a polished CV / 简历 they can print or attach to applications. They will iterate visually: the layout, color, fonts, bullet density, and section ordering will all change multiple times before they're satisfied. Optimize for fast, low-friction iteration over a "perfect first draft."

## Workflow at a glance

1. **Read the source** (`*.txt`, `*.md`, `*.docx`) and extract every fact verbatim. Don't paraphrase or invent.
2. **Build one HTML file per person.** Inline `<style>` — no external CSS file. Each resume is self-contained.
3. **Render to PDF** with headless Edge (Chrome works too):
   ```powershell
   & $edge --headless=new --disable-gpu --no-pdf-header-footer --no-sandbox `
     --print-to-pdf="<out>.pdf" "file:///<absolute-path-to-html>"
   ```
4. **Verify page count** by parsing the PDF — see "Page-count check" below.
5. **Iterate.** Each user remark is usually one of: change a fact, change a color, change a font, change a bullet structure, or "fit on one page."

## Project layout

```
cv/
  resume_<personA>.html         ← one HTML per candidate
  resume_<personB>.html
  resume_<personA>.pdf / resume_<personB>.pdf
  photo_<personA>.jpg, photo_<personB>.png   ← passport-style portraits
  logos/                                     ← school / company logos as round masks
    <school1>.png, <school2>.png, ...
  fonts/                                     ← woff2 fonts, embedded via @font-face
    noto-sans-sc-{400,500,600,700}.woff2
    noto-serif-sc-{400,600,700}.woff2
    ibm-plex-sans-{400,500,600,700}.woff2
    newsreader-{400,400-italic,600}.woff2
  raw_<personA>.txt / raw_<personB>.md       ← original unedited content
```

Keep raw source files alongside the HTML — when the user says "go back to the original wording" you'll need them.

## Typography

**Never rely on PingFang SC** — it doesn't exist on Windows, and headless Edge will fall back to a system font silently, breaking weight rendering. Always embed via `@font-face`.

Stack:

| Role | Font | Weights | Notes |
|---|---|---|---|
| Latin sans body | IBM Plex Sans | 400 / 500 / 600 / 700 | Pairs cleanly with CJK; corporate but not generic |
| CJK body | Noto Sans SC | 400 / 500 / 600 / 700 | PingFang's free open-source equivalent |
| Latin serif citation | Newsreader | 400 / 400-italic / 600 | For paper citations only |
| CJK serif (optional) | Noto Serif SC | 400 / 600 / 700 | If user wants 报刊感 / editorial display |

CDN: `https://cdn.jsdelivr.net/npm/@fontsource/<family>@latest/files/<file>.woff2`

Order in `font-family`: **Latin sans first**, CJK fallback second:
```css
font-family: "IBM Plex Sans", "Noto Sans SC", "PingFang SC", "Microsoft YaHei", sans-serif;
```
The browser uses the first font that has the glyph — IBM Plex covers Latin/digits, Noto Sans SC covers CJK.

**Use `pt`, not `px`, for typography** in print-bound HTML. PDF renders pt natively; px is sensitive to DPI rounding.

Body baseline: 10–10.5pt. Section heads: 11.5–12pt. Name: 20–22pt with `letter-spacing: 0.18em`.

## Theme color systems

Pick **one** brand-aligned accent and stick with it. Define it as a CSS constant the entire stylesheet reuses (one primary `--accent`, one darker `--accent-deep`, one tinted `--tag-bg`).

**Always ask the user for the accent color first.** Don't guess from school/employer affiliation — the user may want a different scheme than their institution's official color. Possible prompts:

- "想要哪个色系？比如学校 / 单位的官方色，或者具体 hex / RGB？"
- Offer 3–4 broad directions to pick from (cool blues, deep purples, school reds, warm oranges/terracotta) so the user can pick fast.

Once the user gives you a primary hex, derive:
- `--accent-deep` ≈ 60–70% lightness of primary (use for section titles & strong text)
- `--tag-bg` ≈ a 6–8% tint of primary on white (use for award-tag pills)

Don't use rainbow icon colors — the user will reject "图标五颜六色". Use **one** accent everywhere; add subtle variation with neutral grays for secondary/tertiary text.

## Layout skeleton

```
.page (210mm × min-height: 297mm)
├─ .header  (photo + name + track + meta + contacts)
└─ .content (sections)
   ├─ section: 教育背景 / Education
   ├─ section: 实习经历 / Internships
   ├─ section: 科研经历 / Research
   ├─ section: 竞赛经历 / Competitions  (2-col grid)
   ├─ section: 荣誉奖项 / Honors  (single line)
   └─ section: 个人陈述 / Statement
```

For non-research majors swap in 项目经历 / 实践工作 / 语言能力 / 技能 instead.

### Section title pattern (uniform accent)

```html
<div class="section-title">
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="2">…</svg>
  教育背景
</div>
```
Border-bottom 1.5px solid in primary accent; font-size 11.5–12pt; weight 700; letter-spacing 0.06em.

### Bullet markers

Avoid:
- `list-style: disc` — looks puny in CJK at small sizes
- Black ▪ ▍ Unicode characters — render unevenly across fonts and look like "black squares" on Windows

Prefer (CSS-rendered, accent-colored):
```css
.entry-bullets li::before {
  content: "";
  position: absolute;
  left: 1px;
  top: 0.62em;
  width: 6px;
  height: 6px;
  background: var(--accent);
  clip-path: polygon(0 0, 100% 50%, 0 100%);  /* small triangle */
}
```
Other clean options: `border-radius: 50%` (filled dot), `transform: rotate(45deg)` (diamond). Pick one and use it everywhere.

### Sub-heading vertical bar

For "▍ 子项目名" — replace the Unicode char with a CSS bar:
```css
.sub-heading { position: relative; padding-left: 11px; }
.sub-heading::before {
  content: "";
  position: absolute;
  left: 0; top: 0.18em; bottom: 0.22em;
  width: 3px;
  background: var(--accent);
  border-radius: 1.5px;
}
```

### Logos

Round masks at 18×18px work well in `entry-header`:
```css
.entry-logo {
  width: 18px; height: 18px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
  background: #fff;
}
```
Some users will say "全部 logo 不要" — be ready to remove every `<img>` and tighten left margins to 0 (顶格).

### Awards grid (2-column)

```css
.award-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 3px 24px; }
.award-item { font-size: 9.5pt; line-height: 1.7; display: flex; gap: 6px; align-items: baseline; }
.award-item::before { content: "▸"; color: var(--accent); font-size: 9pt; }
.award-tag { display: inline-block; background: var(--tag-bg); color: var(--accent-deep); font-size: 8.5pt; font-weight: 600; padding: 0 5px; border-radius: 3px; }
```

### Timeline list (date | event grid)

Replace ugly `cols-2` wrapping bullets for a 6+ event list:
```css
.timeline { display: grid; grid-template-columns: 60px 1fr; column-gap: 14px; row-gap: 3px; }
.timeline .tl-date { font-size: 9pt; font-weight: 600; color: var(--accent); font-variant-numeric: tabular-nums; }
.timeline .tl-event { font-size: 9.5pt; line-height: 1.55; border-left: 1.5px solid #d8d4e2; padding-left: 12px; }
```

## Strict A4 fit (1 page)

A4 at 96 dpi ≈ 210 × 297 mm ≈ 794 × 1123 px. Total content height including header must stay under 1123 px.

Don't use `max-height: 297mm; overflow: hidden` — it silently clips content; the user will say "PDF 不全." Instead, keep `min-height: 297mm` only and trim until it actually fits.

When over by 1 page break, the levers (largest payoff first):

| Lever | Saves | Notes |
|---|---|---|
| `.section { margin-bottom }` 14 → 8 | ~30 px | 5 sections × 6px |
| `.entry { margin-bottom }` 10 → 7 | ~12 px | |
| `.entry-bullets li { line-height }` 1.75 → 1.6 | ~25 px | 12+ bullets |
| Header padding 14/12 → 8/7 | ~12 px | |
| Header photo 92×128 → 76×104 | ~24 px | |
| Header `.name` 22pt → 20pt | ~6 px | |
| Merge two short sections into one | ~30 px | e.g. 语言 + 技能 |
| Drop 个人陈述 / 荣誉 sections | ~50 px each | **Ask first — user often wants these.** |

When **under** (bottom whitespace), reverse the same levers — increase line-height to 1.75–1.85, increase section margins, increase header padding. Aim for the page to *just* fill, not crammed and not airy.

## PDF generation (Windows)

```powershell
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$dir  = "<your-cv-folder>"

# Always kill stale Edge processes — they hold cache locks.
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$out = "$dir\resume.pdf"
Remove-Item $out -Force -ErrorAction SilentlyContinue
$p = Start-Process -FilePath $edge -ArgumentList @(
  "--headless=new","--disable-gpu","--no-pdf-header-footer","--no-sandbox",
  "--print-to-pdf=$out",
  "file:///$($dir.Replace('\','/'))/resume.html"
) -PassThru -NoNewWindow
$p.WaitForExit(30000) | Out-Null
```

### Page-count check (no extra dependency)

```powershell
function Get-PdfPageCount($path) {
  $b = [System.IO.File]::ReadAllBytes($path)
  $t = [System.Text.Encoding]::ASCII.GetString($b)
  return [regex]::Matches($t, '/Type\s*/Page[^s]').Count
}
```
1 page = good. 2 pages = trim. The regex avoids matching `/Type /Pages` (the page tree root).

### File-lock workaround

Windows PDF viewers (Adobe, WPS Office, Foxit) hold the file open. When `--print-to-pdf` fails with `Failed to write file: ... 另一个程序正在使用此文件`:

1. Write to a versioned filename (`resume_v2.pdf`) first.
2. Try to delete + rename in a `try/catch`; if the original is still locked, leave the v2 in place and tell the user *"please close the PDF viewer; v2 is the latest."*

```powershell
try {
  Remove-Item $original -Force -ErrorAction Stop
  Move-Item $tmp $original
} catch {
  Write-Output "PDF locked by viewer; $tmp is the latest"
}
```

## Iteration patterns

The user's edits cluster into four shapes. Recognize them fast.

### 1. Content correction
*"师从 X 助理教授（不是 Y 教授）"* / *"源域、目标域用英文"* / *"21 中共党员"*

→ One targeted `Edit`. Don't restyle.

### 2. Bullet restructuring
*"拆点"* / *"这些不好看"* / *"工整一点"*

The user oscillates between **atomic** (one bullet per fact) and **merged** (one bullet per technology layer). Don't over-split:
- 1 atomic point per fact = "拆得太碎"
- 3+ semicolon-joined sub-clauses per bullet = unreadable
- **Sweet spot: 2–3 bullets per project, each with parallel verb-led structure** (完成 / 构建 / 搭建 / 微调 / 部署)

### 3. Theme / style swap
*"主题色换成 #XXXXXX"* / *"图标统一"* / *"字体换苹方"*

→ Use `Edit` with `replace_all: true` for color hex codes. Section icons need individual edits (each SVG `stroke=`).

### 4. Page-fit complaints
*"下面空了"* / *"没合并到一面"* / *"内容不全"*

→ Run page-count check. Then apply levers from the A4-fit table above. **Don't remove sections without asking** — the user will tell you which content matters.

## Content fidelity

- **Don't drop content** to make A4 fit — ask the user which sections to compress.
- **Don't infer personal facts** (age, 民族, 党员身份) when the source omits them. Ask first.

You *may* adjust:
- Spacing, alignment, half-width spaces between Chinese and Latin/digits (`AI 项目` not `AI项目`).
- Curly vs. ASCII quotes for typographic consistency.
- Capitalization of proper nouns when clearly a typo (e.g., `mysql` → `MySQL`) — but only after confirming with user.

## Common content pitfalls

- **Numerals**: prefer half-width Latin digits (`790 万` not `790万`) for tabular alignment with `font-variant-numeric: tabular-nums`.
- **Quotes**: Chinese curly quotes "..." for Chinese terms; ASCII quotes only inside English code/identifiers.
- **Half-width punctuation around English**: `XX 工程` (space) is more readable than `XX工程` for mixed text.

## Section ordering by major

| Major / target | Section order | Notable accents |
|---|---|---|
| 工科 / IC / AI 研究方向 | 教育 → 实习 → 科研 → 竞赛 → 荣誉 → 个人陈述 | Paper citations in `paper-cite` block; technical em-tags |
| 翻译 / 国际事务 / 文科 | 教育 → 项目经历 → 实践工作 → 语言能力 → 技能 | Timeline grid for口译/活动 records; certificate chips |
| 产品 / 商科 | 教育 → 实习 → 项目 → 竞赛 → 技能 | Project-name sub-headings; outcome metrics in `<strong>` |
| 创业 / Entrepreneurship | 教育 → 创业项目 → 实习 → 团队管理 → 竞赛 → 个人陈述 | "项目名 · 阶段（种子轮 / Pre-A / A 轮）"; revenue / user-count metrics |
| 公务员 / 选调生 / 体制内 | 教育 → 政治面貌 → 实践锻炼 → 学生工作 → 实习 → 荣誉 → 个人陈述 | Lead with 党员身份; emphasize 思想觉悟 / 党课 / 志愿服务; lighter on commercial internships |
| 金融 / 投行 / 券商 / 量化 | 教育 → 证书 → 实习 → 项目 → 竞赛 → 技能 | CFA / CPA / FRM 证书前置; deal sheet & ticker tags; bilingual is common |

### Preset-specific guidance

**创业（entrepreneurship）**
- Replace 实习 as the lead with **创业项目** — each entry needs: company / role-as-founder / fundraising stage / team size / KPI moved.
- Use the `award-tag` chip to mark stage: `种子轮` / `Pre-A` / `A 轮` / `已退出`.
- Metrics belong in `<strong>`: MAU, GMV, 营收, 融资额. If pre-revenue, lead with team milestones (人员扩张到 X 人, 完成 MVP).

**公务员 / 选调生**
- The header `header-basic` line **must** include 政治面貌 (中共党员 / 预备党员). Don't redact this in a public-facing output.
- Add a dedicated 实践锻炼 section above 实习 — covers 三下乡, 支教, 志愿服务, 社会实践调研. Each entry is a one-line `entry-desc`, no bullets needed.
- 学生工作 deserves its own section (not merged with 实践工作) — list 团委 / 学生会 / 党支部 roles in chronological order.
- Tone: avoid Latin technical jargon; prefer 中文术语. The skill should NOT auto-translate Chinese terms to English here.

**金融 / 投行 / 量化**
- Lead with 证书 section (right after 教育). Use the `award-tag` chip per certificate: `CFA L2` / `FRM Part 1` / `CPA` / `Series 7`.
- Deal experience: in 实习 entries, list specific deals/transactions as bullets (匿名化时用 `某 A 股上市公司` / `某美元基金 LP`).
- Numbers everywhere. Each bullet should ideally end with a metric: 募集金额 / 估值 / IRR / Sharpe / 模型回测收益.
- Bilingual (中英对照) version is often required for foreign-IB applications — see [`examples/template-bilingual.html`](examples/template-bilingual.html).

## What NOT to do

- ✗ Bold redesigns when the user says "在原先的基础上优化" — they want incremental improvements, not a new design language.
- ✗ Adding inferred personal info (age, party affiliation) without confirming.
- ✗ Removing sections to fit A4 without asking.
- ✗ Using `max-height + overflow: hidden` to "force" 1 page — content gets silently clipped.
- ✗ Using `list-style: disc` or `▪`/`▍` Unicode block characters for markers.
- ✗ Using PingFang SC in the font stack on Windows — silently falls back.
- ✗ Polling / repeatedly retrying when a PDF write fails: it's almost always a viewer holding the lock; tell the user.

## Final checklist before declaring done

- [ ] Page count = 1 (verified by regex)
- [ ] No `max-height: 297mm` clip
- [ ] All theme colors consistent (one accent + one darker variant)
- [ ] All section icons same color (or intentionally varied — confirm with user)
- [ ] All facts traceable to the raw source file (no invented content)
- [ ] Embedded fonts loading (no `PingFang SC` without `@font-face`)
- [ ] Bottom of page is filled (not airy) and content not cramped
- [ ] PDF viewer closed before final write to avoid file-lock confusion
