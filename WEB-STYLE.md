# Web style — krill app landing pages + org site

The web counterpart to [STYLE.md](STYLE.md). STYLE.md governs the *apps*; this governs every public-facing **web page** under krill — the org site at `krill-software.github.io`, and each app's `docs/index.html` shipped via GitHub Pages.

Goal: a single visual vocabulary across the whole web surface. A visitor who lands on the markdown-editor page and then clicks through to the terminal page should *not* feel like they've changed brands.

## Tagline

> **Building native Linux apps that don't make your eyes bleed or your mind hurt. Not too smart, not too big.**

That's the brand voice for the web. Use it (or a tight variant of it) in the org page hero and in each app page's meta description. Don't paraphrase into corporate-speak.

## Palette

Same five colors as the apps — see [STYLE.md → Palette](STYLE.md#palette). On the web, expose them as CSS variables with the same names but a shorter convention (no `--fm-` prefix):

```css
:root {
  --bg:            #FAFAFF;  /* Ghost White — page background */
  --ink:           #30343F;  /* Space Cadet — body text, primary buttons */
  --muted:         #878472;  /* Artichoke — secondary text, eyebrow labels */
  --accent:        #DD7596;  /* Shimmering Blush — links, brand dot, emphasis */
  --accent-strong: #FF82BF;  /* Brilliant Rose — hover states */
  --rule:          rgba(48, 52, 63, 0.08);  /* hairline borders */
  --rule-strong:   rgba(48, 52, 63, 0.18);  /* card borders, button outlines */
}
```

No other colors. No grays except the alpha-Space-Cadet rules above. If a page needs a sixth, raise it as a design decision — same rule as the apps.

## Typography

**Three webfonts via Google Fonts. Same three on every page.**

```html
<link
  href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Inter:wght@400;500;600;700&family=Source+Serif+4:ital,wght@0,400;0,600;1,400&display=swap"
  rel="stylesheet"
/>
```

```css
:root {
  --sans:  "Inter", system-ui, sans-serif;
  --serif: "Source Serif 4", Charter, Georgia, serif;
  --mono:  "JetBrains Mono", "Source Code Pro", ui-monospace, monospace;
}
```

| Variable | Family | Use |
|---|---|---|
| `--sans` | Inter | Body text, app names, lead paragraphs in cards |
| `--serif` | Source Serif 4 | Headlines (h1, h2). Always at heavy size; the serif is *the* swag of the brand on the web. |
| `--mono` | JetBrains Mono | Eyebrow labels, nav links, section labels, code snippets, file extensions, button labels, install boxes |

Note that the **apps** use a different sans (Inter only on chrome) and serif (Charter for prose). The web stack diverges intentionally — Source Serif 4 and JetBrains Mono read better at large sizes on screen than Charter and Hasklig do.

### The headline rule

Every page hero h1 follows the same pattern:

- **Family:** `--serif`
- **Weight:** 400 (regular — not bold)
- **Size:** `clamp(44px, 7vw, 76px)`
- **Line-height:** 1.05
- **Letter-spacing:** `-0.02em`
- **Max width:** `18ch`
- **Contains a single `<em>` styled as accent-italic.** This is the krill h1 idiom — the emphasized word is the one that carries the swag.

```html
<h1>Apps that don't make your eyes bleed or your mind <em>hurt</em>.</h1>
```

```css
h1 em {
  font-style: italic;
  color: var(--accent);
}
```

Don't bold the headline. The serif at 400 + italic accent does the work.

### Section heads (h2)

- **Family:** `--serif`, weight 400
- **Size:** `clamp(32px, 4vw, 44px)`
- **Always preceded by a mono eyebrow** (the "section label") — uppercase, letter-spacing 0.14em, color muted

```html
<div class="section-label">Apps</div>
<h2>Eight tools. One suite.</h2>
```

### Eyebrow (above hero h1)

Mono, 13px, uppercase, letter-spacing `0.12em`, muted. One short phrase that frames what the page *is*.

## Layout

- **Width:** content max 960px, gutters 32px (22px on ≤720px).
- **Hero padding:** 96px top / 80px bottom.
- **Section padding:** 96px vertical, 1px top border in `--rule` between sections.
- **Card grid (apps, features):** 2 columns desktop, 1 column ≤720px.

## Components

### Nav

```html
<nav class="top">
  <div class="brand">krill / markdown</div>
  <ul>
    <li><a href="#features">Features</a></li>
    <li><a href="#install">Install</a></li>
    <li><a href="https://github.com/krill-software/markdown-editor">GitHub</a></li>
  </ul>
</nav>
```

The brand is `krill` on the org page; `krill / <slug>` on app pages — slash + lowercase slug, mono. **A small pink dot** prefixes the brand:

```css
nav.top .brand::before {
  content: "";
  display: inline-block;
  width: 8px;
  height: 8px;
  background: var(--accent);
  border-radius: 50%;
  margin-right: 10px;
  transform: translateY(-1px);
}
```

That dot is part of the brand. Don't skip it.

### Buttons

Two variants, both mono, both 14px:

- **Primary** — dark fill (`--ink` bg, `--bg` text). Hover flips to accent fill.
- **Secondary** — outlined (`--rule-strong` border, `--ink` text). Hover darkens the border.

Hovers lift by 1px (`transform: translateY(-1px)`) on primary only. Mono-style "metadata pill" inside a button (e.g. `· 78 MB`) uses muted color.

### Cards (app cards, feature cards)

- Padding 28px.
- Border 1px in `--rule`, hover 1px in `--rule-strong`.
- Border radius 10–12px.
- Hover: lift 2px, soft shadow.
- Inside, the order is icon → mono tag (accent color) → sans heading → muted description → mono meta footer with a trailing arrow.

### Lucide icons

All inline-rendered SVGs from [Lucide](https://lucide.dev). Stroke `currentColor`, stroke-width 2, rounded caps. App-card icons are 28px. Hero/logo icons are 32–64px. **No filled icons, no emoji.**

### Install boxes

For terminal-style code samples. Inset, 3% alpha-Space-Cadet background, 10px radius. `pre` content in mono 13.5px, comments in muted (`<span class="c">`).

### Footer

Mono 13px, muted color. Two columns: copyright on the left, contextual links on the right. Always includes a link to the source on GitHub.

## Hover / motion

- Transition duration: **120ms** on color and border, **160ms** on transform.
- Easing: `ease`.
- The only motion-tokens are: link border-bottom appearing, card lift on hover, button lift on hover. **No reveal animations on scroll, no parallax, no autoplay video.** Stillness is the brand on the web too.

## Don't

- Don't use a different font for one page.
- Don't put dark mode toggles, theme pickers, or "system / light / dark" radios anywhere.
- Don't use stock photography or marketing illustrations.
- Don't add scroll-triggered animations.
- Don't link out to Twitter / X / Discord / etc. krill is a software project, not a community.
- Don't gradient-fill the headline (it's the italic accent-pink em, full stop).
- Don't introduce "Powered by" badges from hosting providers.

## Canonical starter

`krill-software.github.io/index.html` is the reference implementation. New app pages should diff against it, change the hero text and the feature blocks, and keep everything else identical.

When the canonical changes (e.g. tagline updates, new section pattern), update the org page first and the apps' `docs/index.html` next in a single sweep — drift between pages is more visible on the web than on the desktop.
