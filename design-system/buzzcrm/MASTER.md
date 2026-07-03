# Design System Master File

> **LOGIC:** When building a specific page, first check `design-system/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** BuzzCRM
**Generated:** 2026-07-03 11:08:19
**Category:** SaaS (General)

---

## Global Rules

### Color Palette

| Role | Hex | Chatwoot token (this fork) |
|------|-----|--------------|
| Primary | `#0891B2` | `woot-500` / `--blue-9` (light) · `n.brand` |
| On Primary | `#FFFFFF` | `white` |
| Secondary | `#0E7490` | `woot-600` (hover / pressed) |
| Accent/CTA | `#06B6D4` | `woot-400` |
| Background | `#FBFBF8` | `--background-color` (light) |
| Foreground | `#0B0B0D` | `--slate-12` (Chatwoot keeps `#1C2024`) |
| Muted | `#ECFEFF` | `woot-25` / `--solid-blue-2` |
| Border | `#E6E6E1` | `--border-weak` / `--border-strong` |
| Destructive | `#DC2626` | `n.ruby-9` |
| Ring (focus) | `#0891B2` | `focus:outline-n-brand` |

**Dark mode:** accent lifts to `#22D3EE` (`--blue-9` dark) on `#0F1B1F` surfaces, text `#E6F6FA`.

**Color Notes:** BuzzCRM brand cyan (matches Tailwind cyan scale) on off-white surfaces with near-black text. Flat, no gradients. The full `woot`/`--blue-*` scales (25→900) are defined in `theme/colors.js` and `app/javascript/dashboard/assets/scss/_next-colors.scss`.

### Typography

- **Heading Font:** Plus Jakarta Sans
- **Body Font:** Plus Jakarta Sans
- **Mood:** friendly, modern, saas, clean, approachable, professional
- **Google Fonts:** [Plus Jakarta Sans + Plus Jakarta Sans](https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap)

**CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap');
```

### Spacing Variables

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | `4px` / `0.25rem` | Tight gaps |
| `--space-sm` | `8px` / `0.5rem` | Icon gaps, inline spacing |
| `--space-md` | `16px` / `1rem` | Standard padding |
| `--space-lg` | `24px` / `1.5rem` | Section padding |
| `--space-xl` | `32px` / `2rem` | Large gaps |
| `--space-2xl` | `48px` / `3rem` | Section margins |
| `--space-3xl` | `64px` / `4rem` | Hero padding |

### Shadow Depths

| Level | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle lift |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, buttons |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, dropdowns |
| `--shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Hero images, featured cards |

---

## Component Specs

### Buttons

```css
/* Primary Button — flat: hover shifts color only, no transform/shadow */
.btn-primary {
  background: #0891B2; /* woot-500 */
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: background-color 180ms ease-out;
  cursor: pointer;
}

.btn-primary:hover {
  background: #0E7490; /* woot-600 */
}

/* Secondary Button */
.btn-secondary {
  background: transparent;
  color: #0891B2;
  border: 1px solid #0891B2;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: background-color 180ms ease-out, color 180ms ease-out;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #ECFEFF; /* woot-25 */
}
```

### Cards

```css
.card {
  background: #FFFFFF;
  border: 1px solid #E6E6E1;
  border-radius: 12px;
  padding: 24px;
  transition: border-color 180ms ease-out;
  cursor: pointer;
}

.card:hover {
  border-color: #22D3EE; /* woot-300 — flat: no shadow/transform */
}
```

### Inputs

```css
.input {
  padding: 12px 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 200ms ease;
}

.input:focus {
  border-color: #0891B2;
  outline: none;
  box-shadow: 0 0 0 3px #0891B220;
}
```

### Modals

```css
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: var(--shadow-xl);
  max-width: 500px;
  width: 90%;
}
```

---

## Style Guidelines

**Style:** Flat Design

**Keywords:** 2D, minimalist, bold colors, no shadows, clean lines, simple shapes, typography-focused, modern, icon-heavy

**Best For:** Web apps, mobile apps, cross-platform, startup MVPs, user-friendly, SaaS, dashboards, corporate

**Key Effects:** No gradients/shadows, simple hover (color/opacity shift), fast loading, clean transitions (150-200ms ease), minimal icons

### Page Pattern

**Pattern Name:** Real-Time / Operations Landing

- **Conversion Strategy:** For ops/security/iot products. Demo or sandbox link. Trust signals.
- **CTA Placement:** Primary CTA in nav + After metrics
- **Section Order:** 1. Hero (product + live preview or status), 2. Key metrics/indicators, 3. How it works, 4. CTA (Start trial / Contact)

---

## Anti-Patterns (Do NOT Use)

- ❌ Excessive animation
- ❌ Dark mode by default

### Additional Forbidden Patterns

- ❌ **Emojis as icons** — Use SVG icons (Heroicons, Lucide, Simple Icons)
- ❌ **Missing cursor:pointer** — All clickable elements must have cursor:pointer
- ❌ **Layout-shifting hovers** — Avoid scale transforms that shift layout
- ❌ **Low contrast text** — Maintain 4.5:1 minimum contrast ratio
- ❌ **Instant state changes** — Always use transitions (150-300ms)
- ❌ **Invisible focus states** — Focus states must be visible for a11y

---

## Pre-Delivery Checklist

Before delivering any UI code, verify:

- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons from consistent icon set (Heroicons/Lucide)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px
- [ ] No content hidden behind fixed navbars
- [ ] No horizontal scroll on mobile
