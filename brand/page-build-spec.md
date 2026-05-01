# SORCC Jetson Handoff — Page build specification

Canonical reference for any agent producing HTML pages under `docs/`. Read this in full before writing any HTML. The landing at `docs/index.html` is the visual reference; this document is the structural/class reference.

---

## 1. File locations

```
docs/
├── index.html                          existing landing (DO NOT modify)
├── assets/
│   ├── sorcc.css                       brand stylesheet (DO NOT modify)
│   ├── sorcc.js                        site JS (DO NOT modify)
│   ├── sorcc-logo.png
│   ├── jetson-40pin-pinout.svg
│   └── fc-wiring-diagram.svg
├── 00-before-you-start/                you create
├── 01-flash-and-update/                you create
├── 02-base-system/                     you create
├── 03-hardware/                        you create
└── 04-apps/                            you create
```

**Source markdown** lives at the repo root (one level above `docs/`):
- `00-before-you-start/*.md`
- `01-flash-and-update/*.md`
- `02-base-system/*.{md,sh}`
- `03-hardware/*.{md,svg}`
- `04-apps/<app>/install.{md,sh}`

When converting markdown to HTML: preserve the *content* faithfully. The markdown is the source of truth for what to say. Your job is to render it in the SORCC system, not paraphrase it.

---

## 2. Asset paths from subsections

A page at `docs/<section>/<step>.html` reaches assets at `../assets/sorcc.css`, etc.

Always use **relative paths**. Do not use `/assets/...` (root-absolute paths break on `username.github.io/repo/` deployments).

---

## 3. Page skeleton

Every subsection page uses this skeleton. Two variants: `.page` for landings (no left rail), `.layout-with-rail` for procedural step pages (sticky 220px nav rail).

### 3a. Section landing (no rail)

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>SECTION TITLE — SORCC Jetson Handoff</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="description" content="ONE-SENTENCE DESCRIPTION." />
<link rel="stylesheet" href="../assets/sorcc.css" />
</head>
<body data-resume-label="Section NN · SECTION TITLE" data-resume-href="NN-section-slug/index.html">

<a class="skip" href="#main">Skip to content</a>

<div class="classification">UNCLASSIFIED</div>

<header class="site-header">
  <div class="site-header__inner">
    <div class="site-header__logo" role="img" aria-label="SORCC logo"></div>
    <div class="site-header__title">
      <div class="site-header__title-line"><a href="../index.html">SORCC Jetson Handoff</a></div>
      <div class="site-header__sub">Oak Grove Technologies · self-serve guide for SORCC graduates</div>
    </div>
    <div class="site-header__meta">
      <div>JETPACK 6.2.1</div>
      <div>L4T R36.4.X · ORIN NANO 8GB</div>
      <button data-theme-toggle aria-label="Toggle dark mode">Dark</button>
    </div>
  </div>
</header>

<nav class="breadcrumb">
  <div class="breadcrumb__inner">
    <a href="../index.html">SORCC Jetson Handoff</a>
    <span class="breadcrumb__sep">›</span>
    <span class="breadcrumb__current">Section NN · TITLE</span>
    <span class="breadcrumb__counter">SECTION NN OF 04</span>
  </div>
</nav>

<main id="main" class="page">

  <p class="doc-eyebrow">Section NN · ~MIN</p>
  <h1 class="doc-title">SECTION TITLE</h1>
  <p class="doc-lede">ONE-PARAGRAPH OVERVIEW.</p>

  <!-- step cards or content sections -->

  <div class="pagenav">
    <a class="btn" href="../PREV-SECTION/index.html">‹ PREV SECTION TITLE</a>
    <span class="pagenav__spacer"></span>
    <a class="btn btn--primary" href="../NEXT-SECTION/index.html">NEXT SECTION TITLE ›</a>
  </div>

</main>

<footer class="site-footer">
  <div class="site-footer__inner">
    <div class="site-footer__left">SORCC Jetson Handoff · v1.0</div>
    <div class="site-footer__center">UNCLASSIFIED</div>
    <div class="site-footer__right"><a href="https://github.com/rmeadomavic/sorcc-jetson-handoff">Source on GitHub ›</a></div>
  </div>
</footer>

<script src="../assets/sorcc.js"></script>
</body>
</html>
```

### 3b. Procedural step page (with left rail)

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>STEP TITLE — Section NN — SORCC Jetson Handoff</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="description" content="ONE-SENTENCE DESCRIPTION." />
<link rel="stylesheet" href="../assets/sorcc.css" />
</head>
<body data-resume-label="STEP TITLE · Section NN" data-resume-href="NN-section-slug/STEP-FILE.html">

<a class="skip" href="#main">Skip to content</a>

<div class="classification">UNCLASSIFIED</div>

<header class="site-header"> ... same as 3a ... </header>

<nav class="breadcrumb">
  <div class="breadcrumb__inner">
    <a href="../index.html">SORCC Jetson Handoff</a>
    <span class="breadcrumb__sep">›</span>
    <a href="index.html">Section NN</a>
    <span class="breadcrumb__sep">›</span>
    <span class="breadcrumb__current">STEP TITLE</span>
    <span class="breadcrumb__counter">STEP X OF Y</span>
  </div>
</nav>

<div class="layout-with-rail">

  <aside class="rail" data-rail-progress="sec-NN-step-1,sec-NN-step-2,sec-NN-step-3">
    <p class="rail__heading">Section NN</p>
    <ol>
      <li><a href="index.html"><span class="num">00</span><span>Overview</span></a></li>
      <li><a href="01-FILE.html"><span class="num">01</span><span>STEP 1 TITLE</span></a></li>
      <li><a href="02-FILE.html"><span class="num">02</span><span>STEP 2 TITLE</span></a></li>
      <li><a href="03-FILE.html"><span class="num">03</span><span>STEP 3 TITLE</span></a></li>
      <li><a href="troubleshooting.html"><span class="num">!!</span><span>Troubleshooting</span></a></li>
    </ol>
    <div class="rail__progress">
      <div class="rail__progress-track">
        <div class="rail__progress-fill"></div>
      </div>
      <div class="rail__progress-label">0 / 3 STEPS</div>
    </div>
  </aside>

  <main id="main" class="content">

    <p class="doc-eyebrow">Section NN · Step X · ~MIN</p>
    <h1 class="doc-title">STEP TITLE</h1>
    <p class="doc-lede">ONE-PARAGRAPH OVERVIEW.</p>

    <!-- traps go up high if relevant -->
    <!-- body content using the components below -->

    <label class="step__check" style="display:inline-flex;margin-top:32px;">
      <input type="checkbox" data-step-key="sec-NN-step-X" />
      <span class="box"></span>
      <span>Mark this step complete</span>
    </label>

    <div class="pagenav">
      <a class="btn" href="PREV.html">‹ PREV STEP TITLE</a>
      <span class="pagenav__spacer"></span>
      <a class="btn btn--primary" href="NEXT.html">NEXT STEP TITLE ›</a>
    </div>

  </main>

</div>

<footer class="site-footer"> ... same as 3a ... </footer>

<script src="../assets/sorcc.js"></script>
</body>
</html>
```

JS auto-marks the active rail link from `location.pathname.split('/').pop()` matching the `<a href>` filename. Don't add `is-active` manually.

---

## 4. Components — full class catalog

Use ONLY these classes. Do not invent new ones. Do not add inline styles except where this guide explicitly shows them.

### 4.1 Section labels (the green-rule headers)

```html
<div class="section-label">
  <p class="section-label__text">SECTION HEADER TEXT</p>
  <div class="section-label__rule"></div>
</div>
```

Use one before each major chunk of content. Text appears in UPPER cs60 dark green.

### 4.2 Trap callouts (RED bar — for warnings only)

```html
<div class="trap">
  <div class="trap__head">
    <span class="trap__num">Trap NN</span>
    <span class="trap__title">SHORT WARNING TITLE.</span>
  </div>
  <div class="trap__body">
    <p>BODY PROSE. Use <code class="inline">inline-code</code> as needed.</p>
  </div>
</div>
```

The "Trap NN" tag uses PLACEHOLDER red. Reserve for things that have actually broken a real device. Lift the trap content from the `> **TRAP N**` callouts in the source markdown.

To grid traps: wrap in `<div class="trap-grid trap-grid--2">`.

### 4.3 Note callout (GREEN bar — for context, not warnings)

```html
<div class="note">
  <span class="note__label">Note</span>
  Body prose. Single paragraph form.
</div>
```

`note__label` can be `Note`, `Heads up`, `Tip`, etc. Use for "while you wait this takes 30 minutes" — not for warnings.

### 4.4 Terminal blocks

```html
<div class="term">
  <div class="term__head">
    <span class="term__label">Shell · sorcc@jetson</span>
    <button class="term__copy">Copy</button>
  </div>
<pre class="term__body"><span class="prompt">$ </span>sudo apt-get install nvidia-l4t-jetson-orin-nano-qspi-updater
<span class="comment"># Triple-check the package name. l4t is L-4-T, not 1-4-T.</span>
</pre>
</div>
```

Notes:
- `<pre class="term__body">` content has its leading whitespace preserved literally — start `<pre>` with no indent (the way it appears above).
- Spans inside the body: `.prompt` for `$ ` and `# ` (root) prompts, `.comment` for inline comments, `.ok` for green PASS lines, `.bad` for red FAIL lines, `.hl` for highlighted text.
- Copy button JS strips `.prompt` and `.comment` automatically — author can ignore that.
- Label can be `Shell · sorcc@jetson`, `Shell · host PC`, `Output`, etc.

### 4.5 Inline code

```html
<code class="inline">/dev/ttyACM0</code>
```

Use for paths, package names, identifiers. The `class="inline"` is required.

### 4.6 Step blocks (numbered procedure)

```html
<div class="step">
  <div class="step__num">01</div>
  <div class="step__body">
    <h3>SHORT IMPERATIVE TITLE.</h3>
    <p>Body explaining the step. Can include terminal blocks, notes, traps inside.</p>
  </div>
  <label class="step__check">
    <input type="checkbox" data-step-key="sec-NN-stepname-1" />
    <span class="box"></span>
    Done
  </label>
</div>
```

Use for procedural pages where you want per-step checkboxes. Keys must be unique across the whole site (use the `sec-NN-` prefix).

### 4.7 Card grid (for section landings)

```html
<div class="card-grid">
  <a class="card" href="01-step.html">
    <span class="card__num">Step 01</span>
    <span class="card__title">STEP TITLE</span>
    <span class="card__desc">One-sentence description.</span>
    <span class="card__meta"><span>~MIN</span><span>OPTIONAL TAG</span></span>
  </a>
  ...
</div>
```

Use on section landings to enumerate the steps. Auto-fills 1+ columns based on width.

### 4.8 Tables (modern minimal — no vertical borders, alternating rows)

```html
<table class="modern">
  <thead>
    <tr><th>Heading</th><th>Heading</th></tr>
  </thead>
  <tbody>
    <tr><td>cell</td><td>cell</td></tr>
    ...
  </tbody>
</table>
```

`.content table` is also auto-styled, so plain `<table>` works inside `.content`. Either is fine.

### 4.9 Decision tree

```html
<div class="tree">
  <div class="tree__item is-current">
    <div class="tree__q">QUESTION?</div>
    <div class="tree__hint">If yes → ACTION.</div>
  </div>
  <div class="tree__item">
    <div class="tree__q">NEXT QUESTION?</div>
    <div class="tree__hint">Hint text.</div>
  </div>
</div>
```

Mark the first item `.is-current`. Used on the landing — feel free to use on section landings if there's a meaningful branch.

### 4.10 SVG diagrams

```html
<div class="diagram">
  <object data="../assets/jetson-40pin-pinout.svg" type="image/svg+xml" aria-label="Jetson 40-pin pinout"></object>
</div>
```

Or inline the `<svg>` directly inside `.diagram`. Reserve `.diagram` wrapper for any SVG embed.

### 4.11 Tags / pills

```html
<span class="tag">UNCLASSIFIED</span>
<span class="tag tag--mid">OPTIONAL</span>
<span class="tag tag--pale">~30 MIN</span>
<span class="tag tag--warn">ROOT</span>
```

Use sparingly — for status labels, time tags, etc. The `tag--warn` (red) is a stronger version of trap framing for inline use.

### 4.12 Page nav (prev / next at bottom)

```html
<div class="pagenav">
  <a class="btn" href="prev.html">‹ PREV TITLE</a>
  <span class="pagenav__spacer"></span>
  <a class="btn btn--primary" href="next.html">NEXT TITLE ›</a>
</div>
```

End every step page with this. The primary (green) button always points forward.

---

## 5. Brand rules — non-negotiable

1. **No em dashes** (`—`, `&mdash;`) anywhere in body copy. Use middots (`·`, `&middot;`), commas, or sentence breaks. Em dash is banned by the SORCC brand for operational documents.
2. **"SORCC" is always uppercase**, never "Sorcc" or "sorcc" (the username `sorcc` is fine in code blocks).
3. **Classification bar is always `UNCLASSIFIED`** unless told otherwise.
4. **Footer always reads** `SORCC Jetson Handoff · v1.0` / `UNCLASSIFIED` / `Source on GitHub ›` (back-link to the repo).
5. **Header meta block** always shows `JETPACK 6.2.1` / `L4T R36.4.X · ORIN NANO 8GB`.
6. **Tone**: plain operator voice. The audience is a SORCC graduate doing the procedure for the first time, possibly at night, possibly tethered to a phone hotspot. Hand-hold; assume they have never used Linux. Show every command in full.
7. **Section numbering**: use the prefix in the source (`01-flash-and-update` is "Section 01"). Step numbering within a section follows source filename order (`01-qspi-update.md` is "Step 01").
8. **Links between sections**: relative — `../03-hardware/index.html`, etc. Always include the `.html` suffix.
9. **No external trackers**, no analytics, no fonts beyond what `sorcc.css` already imports (Carlito + Inconsolata via Google Fonts).

---

## 6. Resume / progress hooks

- Every page sets `<body data-resume-label="..." data-resume-href="...">` so JS can record the visit. Label format: `Step Title · Section NN`. Href is the path *relative to docs/* (so `01-flash-and-update/01-qspi-update.html`, not `../01-flash-and-update/01-qspi-update.html`).
- Step checkboxes use unique keys: `sec-NN-stepslug-N` (e.g. `sec-01-qspi-1`, `sec-01-qspi-2`).
- `.rail` element gets `data-rail-progress="key1,key2,key3,..."` listing the step keys for that section. JS computes the progress fill.

---

## 7. Conversion notes per markdown construct

| Markdown | HTML target |
|---|---|
| `# Title` (first) | already in the doc-title block; skip in body |
| `## Heading` | `<h2>` inside `.content` |
| `### Heading` | `<h3>` inside `.content` |
| `**bold**` | `<strong>` |
| `` `code` `` | `<code class="inline">code</code>` |
| Markdown table | `<table class="modern">` |
| Fenced shell block | `<div class="term">...<pre class="term__body">` with `<span class="prompt">$ </span>` prefix on each command line |
| `> **TRAP N**` callout | `<div class="trap">` |
| `> **Note**` / `> **Tip**` | `<div class="note">` |
| `> **Warning**` | `<div class="trap">` (treat warnings as traps in this site) |
| Numbered list of procedural steps | `<div class="step">` blocks, NOT a plain `<ol>` |
| Plain numbered list (non-procedural) | `<ol>` is fine |

---

## 8. What you CANNOT do

- Modify `docs/assets/sorcc.css` or `docs/assets/sorcc.js`. They are stable.
- Modify `docs/index.html`. Already shipped.
- Add new fonts, icons, or external script tags.
- Use Tailwind, Bootstrap, or any utility framework.
- Add inline `<style>` blocks (everything you need is in the stylesheet — if you can't find a class, ask).
- Add JS beyond what `sorcc.js` already provides.
- Commit your changes. The dispatching agent will commit one consolidated change after all sections land.
