---
name: atharva-design
description: Atharva's personal UI taste for building and restyling web interfaces, layered on top of Emil Kowalski's emil-design-eng skill. Minimal light canvas, one accent color, a narrow centered frame, tactile pressable buttons, Tailwind-only styling composed with cn() (clsx + tailwind-merge) and cva variants. Use this skill whenever the user asks to build, remake, restyle, or polish a landing page, marketing site, hero section, navbar, button, card, component, or any frontend UI, mentions "my style", "atharva design", gofunc-style minimalism, Tailwind classes, cn/cva/clsx/tailwind-merge, or wants something to "look clean" or "feel premium", even if they don't name this skill.
---

# Atharva Design

Personal taste layer. It decides how things look and how code is written. For motion, easing, durations, press feedback, and accessibility, read and follow the `emil-design-eng` skill (`~/.claude/skills/emil-design-eng/SKILL.md`) first. This skill only adds to it; where they overlap, Emil's rules on motion win and this skill's rules on look and code win.

Reference for taste: https://gofunc.vercel.app. Quiet, white, editorial, almost nothing on the page, every pixel deliberate.

## 1. Setup before writing UI

Check `package.json`. If missing, install:

```bash
npm i clsx tailwind-merge class-variance-authority
```

(use the project's package manager: pnpm, bun, yarn). Tailwind must already exist; if it does not, stop and ask before adding it.

Add one helper, reuse it everywhere. Put it where the project keeps utils (`lib/utils.ts` is the default):

```ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

Why: plain string concatenation lets conflicting utilities (`min-h-12` and `min-h-10`) both ship, and the CSS order decides the winner. `twMerge` makes the last class win, so overrides are predictable.

## 2. Code rules

- Style only with Tailwind utility classes in `className`. No custom CSS classes, no CSS modules, no inline `style` except for truly dynamic values.
- `globals.css` holds only `@tailwind` directives, font imports, and a small `@layer base` (body bg, text color, selection). Nothing else.
- Design tokens (colors, fonts, easing, keyframes) live in `tailwind.config` `theme.extend`, never as hex scattered across files. Arbitrary values (`text-[13px]`, `tracking-[-1.3px]`) are fine for one-off sizes.
- Any component with more than one look gets a `cva` recipe with `variants` and `defaultVariants`. Callers pick variants; they do not paste class strings.
- Combine classes with `cn()`, always. Conditional classes go through `cn()` objects, not template-string ternaries.
- Repeated class groups (kicker, h2, section padding) become a short const or a small component, not copy-paste.
- Enable `future: { hoverOnlyWhenSupported: true }` in the Tailwind config so `hover:` only applies on real pointers (Emil's touch-hover rule, for free).
- Use `motion-reduce:` variants to drop movement for reduced-motion users.

## 3. Visual system

| Token | Value | Use |
| --- | --- | --- |
| canvas | `#FAFAFA` | page background outside the frame |
| paper | `#FFFFFF` | cards only (never the frame) |
| ink | `#232323` | primary text |
| muted | `#666666` | body copy |
| faint | `#737373` | captions, labels |
| line | `#E5E5E5` | borders and dividers |
| accent | one color, default orange `#EA580C` | primary buttons, links, highlights |
| accent-dark | `#C2410C` | primary button border |

One accent only. Pick an accent shade dark enough for white text (avoid `#F97316` under white text).

Fonts: Inter for UI and body, JetBrains Mono for code, a mono or pixel display face for the h1 and wordmark (Geist Mono by default).

Layout:
- One centered frame: `mx-auto max-w-[800px] border-x border-line` on a `bg-canvas` page with `px-3 sm:px-8`. The frame has no background of its own; it matches the page and only the side borders define it. A white column bar looks off. Reserve `bg-paper` for cards that need it (a white diagram, a terminal).
- No tinted section bands or tinted table headers; on canvas they read as stray lighter strips.
- Navbar `h-16 sm:h-[72px]`, `border-b`, brand left, small text links plus one small primary button right.
- Hero is centered and stacked: kicker, h1, paragraph, CTAs, small badges, then the visual below.
- Sections are separated by `border-t border-line`, padding `px-5 py-10 sm:px-11 sm:py-[60px]`.
- Feature grids: 3 columns, each item has `border-t pt-6`, no card boxes.
- Footer: invitation line, link columns, a huge display wordmark with the accent on one character.

Type scale:
- Kicker: `text-[10px] uppercase tracking-[0.08em] text-[#646464]`
- h1: `font-display text-[clamp(36px,9vw,58px)] leading-[1.1] tracking-[-2px]`, highlight one word with a soft accent marker: `bg-[linear-gradient(#f8c5aa,#f8c5aa)] bg-[length:100%_72%] bg-[position:left_72%] bg-no-repeat`
- h2: `text-[27px] sm:text-[34px] font-medium leading-[1.2] tracking-[-1.3px]`
- Body: `leading-[1.8] text-muted`, 14 to 17px

Avoid: gradients on surfaces, glows, dark heavy sections, emoji, icon soup, more than one accent, rounded-full pills everywhere, drop shadows on cards.

## 4. Buttons (the signature)

Tactile, slightly raised, presses down. Copy this recipe as the project's `Button` (or `buttonVariants` for links):

```ts
import { cva, type VariantProps } from "class-variance-authority";

export const buttonVariants = cva(
  [
    "group inline-flex items-center justify-center gap-2 border font-medium tracking-[-0.15px]",
    "transition-[transform,background-color,border-color] duration-150 ease-out active:scale-[0.97]",
    "shadow-[inset_0_2px_1px_#ffffff40,inset_0_-3px_1px_#00000018,0_0_0_4px_#23232308,0_2px_3px_#17213a20,0_5px_10px_#17213a12]",
    "active:shadow-[inset_0_1px_3px_#00000024,inset_0_-1px_0_#ffffff20,0_0_0_4px_#23232308,0_1px_2px_#17213a12]",
    "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-accent",
    "motion-reduce:transition-none motion-reduce:active:scale-100",
  ],
  {
    variants: {
      variant: {
        primary: "border-accent-dark bg-accent text-paper hover:bg-[#d9520b]",
        secondary: "border-[#c7c7c7] bg-[#f3f3f3] text-[#484848] hover:border-[#bdbdbd] hover:bg-[#eaeaea]",
      },
      size: {
        sm: "min-h-10 rounded-lg px-3 py-2 text-[13px]",
        lg: "min-h-12 rounded-xl px-[18px] py-3 text-[14px]",
      },
    },
    defaultVariants: { variant: "primary", size: "lg" },
  },
);

export type ButtonVariantProps = VariantProps<typeof buttonVariants>;
```

`ease-out` here is the custom `cubic-bezier(0.23, 1, 0.32, 1)` registered in `transitionTimingFunction.out`, per Emil.

Usage:
- Primary: the main action ("Star on GitHub", "Get started"), with a trailing arrow that nudges on hover: `transition-transform duration-150 ease-out group-hover:translate-x-[3px]`.
- Secondary: the alternative action, often a command in `font-mono text-[13px]` like `$ flowctl run`.
- Nav uses `size="sm"` primary. Hero uses `size="lg"`.
- On mobile, hero CTAs go full width in a grid (`grid max-w-[440px] gap-2.5 sm:flex`).

## 5. Motion

Follow `emil-design-eng`. In this style that usually means only:
- Press feedback on every button (built into the recipe above).
- One staggered fade-up on hero items at load (`translateY(8px)` to 0, 500ms custom ease-out, 60ms apart), registered as a Tailwind `keyframes`/`animation`, with `motion-reduce:animate-none`.
- Color-only hover on links (`hover:text-accent hover:underline hover:underline-offset-4`).

Nothing loops, nothing bounces, nothing animates on scroll unless asked.

## 6. Before you finish

- Screenshot at about 1280px and 400px wide and look at it. Fix anything that wraps badly, crowds the edges, or breaks the frame.
- Review against the Emil checklist (its Before/After/Why table format) for any motion you added.
- Grep the diff for custom CSS classes, raw hex outside the config, and string-concatenated `className`s. Replace them with tokens, `cn()`, and `cva`.
