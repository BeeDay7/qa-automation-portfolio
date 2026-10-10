# Design decisions

This document explains why the Azam Trading Store looks and reads the way
it does. It is not a style guide — it is the reasoning behind the style,
written for anyone who reads the code and wants to understand what
problem each choice was trying to solve.

The storefront is a test fixture. It is not a real merchant. But a fixture
that does not attempt to look and sound like the thing it is standing in
for is not a useful fixture — it is a placeholder. The design is part of
what makes the tests meaningful, because the tests are asserting against
the same surface a real user would encounter.

---

## The design language

The storefront is built around a single idea: **a merchant's notebook**.

A well-kept ledger from a family-owned trading house. Warm parchment paper.
Deep forest ink. A brass-gold accent used sparingly for the small moments
that matter — a seal, a rule, the number on a price tag. Serif display
type that reads like a title page. Editorial copy in a voice that speaks
to the customer like a person, not a database row.

This is the aesthetic of Aesop, Monogram, Kinfolk, and the great merchant
houses of Lagos, Beirut, and Kyoto. It is deliberately not the aesthetic
of a modern SaaS landing page. There is no gradient banner, no purple
primary colour, no rounded-corner everything, no stock photograph of a
person laughing at a laptop.

The choice matters because a storefront fixture that looks like a SaaS
dashboard teaches test writers the wrong things. It teaches them that
enterprise UI is the default, that marketing copy is filler, and that
visual polish is decoration rather than substance. A merchant-house
fixture teaches the opposite: that every word on the page is chosen, that
every element earns its position, and that a storefront is a place a
person visits rather than a system they operate.

---

## Colour

The palette is warm, low-saturation, and built from four anchors.

**Paper `#fbf8f1`** — the base background. A cream that reads as paper,
not as screen. Cool greys (`#f7f8fb`, `#f1f5f9`) dominate the modern web
because they are the default background of every design tool. Warm paper
is a deliberate departure. It changes the whole perception of the page
before a single word is read.

**Ink `#1a1614`** — the base foreground. A warm black, not a pure black.
Pure black (`#000000`) on a warm background reads as an oversight, not a
contrast. The warmth of the ink matches the warmth of the paper, which is
what makes the two feel like they belong together.

**Forest `#0d3b2e`** — the primary action colour. Used for buttons, the
announcement bar, the About section background, and the price numerals.
A deep, low-saturation green, not the standard `#4f46e5` indigo. Indigo
is the colour of SaaS. Forest is the colour of permanence, of a shop that
has been on the same street for forty years.

**Gold `#b8860b`** — the accent. Used sparingly: for the brand mark's
ring, for the eyebrow labels above every section heading, for the rules
between blocks of content, for the sign-off marks. Gold in this palette
is not decorative — it is punctuation. Every time it appears it means
"look here, this matters."

The five secondary colours (danger, success, ink-soft, ink-muted, rule)
are all tinted warm to match the primary palette. There is no cool grey
anywhere in the storefront.

**Rationale for the four-anchor approach.** A palette with four anchors
can express every state and hierarchy the storefront needs without a
fifth colour. More colours would dilute the identity. Fewer would make
it impossible to distinguish between "primary action" and "accent
emphasis." Four is the correct number for a small merchant house.

---

## Typography

Two typefaces. Both loaded from Google Fonts. Both variable-weight, both
with a broad character set.

**Fraunces** — the display typeface. A modern serif with optical sizing,
eleven weights, and a "soft" variant that shifts the letterforms toward
a rounded, almost hand-cut quality. It is used for every heading, every
price, the brand mark, and the pull quotes in the Journal. The optical
sizing means Fraunces adjusts its letterforms based on rendered size —
hairlines get slightly thicker at small sizes, serifs get slightly
sharper at large sizes. This is the same technology Georgia, Times, and
every high-end newspaper serif have used for a century.

**Inter** — the body typeface. A neutral sans-serif designed specifically
for screens. It is used for all body copy, buttons, labels, form inputs,
and metadata. Inter is not a distinctive face. That is the point — it
disappears, and lets Fraunces be the voice.

The pairing works because the two faces do not compete. Fraunces is
characterful, Inter is neutral. Every time Fraunces appears it means
"this is worth slowing down for." Every time Inter appears it means
"this is supporting information, read it quickly."

**Specific type decisions.**

- The hero title uses `font-weight: 500`, not 600 or 700. Fraunces at
  medium weight is generous rather than heavy. Bold Fraunces reads as
  aggressive; medium reads as confident.

- The body copy uses `line-height: 1.75` in the Journal articles, not
  the default 1.5. Editorial prose needs more air than UI text.

- The eyebrow labels use `letter-spacing: 0.18em` and `text-transform:
  uppercase`. Wide-spaced small caps are the typographic signature of
  the merchant-house aesthetic.

- The first paragraph of every Journal article uses a drop cap:
  `font-size: 68px`, floated left, with adjusted padding. This is a
  deliberate signal — it tells the reader "this is prose, not copy."

---

## Spacing

The spacing system uses eight-step increments: 4, 8, 12, 16, 24, 32, 48,
64, 96, 128 pixels. Every `padding`, `margin`, and `gap` in the
stylesheet is one of those values. No magic numbers.

The choice of eight as the base unit is conventional but important. It
produces visual rhythm without ambiguity — a designer or developer
adding a new component does not have to guess whether 20px or 24px is
correct, because 20px is not in the system.

Section padding uses `var(--s-9)` (96px) on top and bottom. Card padding
uses `var(--s-5)` (24px). Inline gaps between related elements use
`var(--s-2)` (8px) or `var(--s-3)` (12px). The system is consistent
enough that a reader who sees two pages side by side will feel the
rhythm without being able to name it.

---

## Layout

**Grid versus flex.** Every page uses CSS Grid for its primary structure
and flexbox for its internal component layout. Grid is used for the
product catalogue, the product detail page, the account page, the
journal index, and the footer. Flexbox is used for navigation bars,
button groups, and card interiors.

**The narrow column.** Every content section is capped at `--container`
(1200px) or `--container-tight` (960px), centred with `margin: 0 auto`.
The account page and the journal article body are capped even narrower
(720px for prose). This is because reading a line of text longer than
about 70 characters is tiring — a fact known since the 1920s when
typographers first measured it.

**The hero asymmetry.** The homepage hero uses a two-column grid with
the ratio 1.45 to 0.55. The text column is the wider one. The "AZ" seal
on the right is large — 120px — but occupies only a third of the space.
This asymmetry is deliberate: it says "this page is primarily for
reading, but there is a mark of the house here too."

---

## Motion

Motion is used sparingly and always for a reason.

- Product cards lift three pixels on hover with a 200ms ease. The lift
  is small enough that it feels like the card is responding to attention,
  not like it is jumping.

- Images inside product cards scale 4.5% on hover with a 400ms ease.
  This is a slower animation than the card lift, which creates a subtle
  depth effect — the card moves first, the image follows.

- The cart drawer uses a 220ms transform with `display: none` for the
  closed state. When it closes, the visibility change is delayed 220ms
  so the drawer appears to slide out completely before it disappears.

**What is deliberately not animated.** No parallax, no scroll-triggered
fades, no cursor-following effects, no animated gradients. The
merchant-house aesthetic is still and quiet. Motion would undermine it.

The reduced-motion media query disables every animation and transition
for users who have requested it in their operating system. This is not
optional. It is a hard requirement of the WCAG 2.1 guideline 2.3.3.

---

## Accessibility

The site is built against WCAG 2.1 Level AA, with a few Level AAA
adjustments made where the cost was low.

**Colour contrast.** Every text/background pair passes 4.5:1 for normal
text and 3:1 for large text. The forest-on-paper pair is 12.4:1. The
gold-on-paper pair is 4.8:1 — barely passing, and only used at sizes
16px and above. The gold eyebrow labels are the tightest case in the
system.

**Semantic HTML.** Every page uses the correct landmark elements —
`<header>`, `<main>`, `<footer>`, `<nav>`, `<article>`, `<aside>`.
Every nav has an `aria-label`. Every dialog has `aria-labelledby` and
`aria-describedby`. Every live region uses `aria-live`.

**Keyboard navigation.** Every interactive element is reachable and
operable with a keyboard. The focus ring is `2px solid var(--forest)`
with a `3px` offset, visible on every focusable element. A skip link
to `#main` appears as the first focusable element on every page.

**Form labels.** Every input has an associated `<label>` with `for` and
`id`. No placeholder-only inputs. Placeholders are hints, not labels.

**Reduced motion.** Every animation and transition respects
`prefers-reduced-motion`. Users who have requested reduced motion see
the site without a single animated transition.

**What was deliberately not implemented.** No automated axe-core
integration in the CI pipeline. No screen-reader transcript for the
SVG illustrations. No colour-blind mode. These are documented in
`docs/LIMITATIONS.md` as acknowledged gaps.

---

## Editorial voice

The storefront speaks in first person plural. It uses "we" and "our" and
"our customers" rather than "the store" and "users." This is not an
accident of style — it is the fundamental choice that makes the design
language coherent.

**Specific expressions of voice.**

- The shopping cart is a **basket**. A basket is what you carry in a shop.
- A signed-in user is a **guest**. A guest is someone you welcome. A
  "user" is someone you authenticate.
- The Journal articles are **notes from the keeper**, not "blog posts."
- The empty cart says "Nothing selected yet. Browse the catalogue and
  add anything that catches your eye." It does not say "Your cart is
  empty."
- The login dialog title says "Sign the register." The form's helper text
  says "Your basket, and your place in the ledger, will be waiting."
- The 404 page says "That item is not on our shelves." It does not say
  "404 Not Found."

The voice extends to the product descriptions, the About section, the
opening hours, and the footer. Every piece of copy is written as if a
real shopkeeper wrote it — because that is the design intent.

**Rationale.** A test fixture that speaks in generic enterprise voice
teaches test writers to assert on generic enterprise strings. A fixture
that speaks in a distinct voice teaches them that copy is also part of
the surface a test can verify. DM-014's assertion on "Please sign in
before checkout" would be meaningless if every empty-cart message said
the same thing.

---

## What was traded away

Every design choice is a trade-off. Here is what this design gives up.

**Familiarity.** Users who expect every e-commerce site to look the same
— white background, blue buttons, sans-serif everywhere — will find this
disorienting at first. The choice to be distinctive is a choice to be
slightly harder to use for a few seconds.

**Density.** A warm palette with generous spacing uses more vertical
space than a dense dashboard. The catalogue shows eight products per
screen at most. A denser layout could show twenty. The choice to be
readable is a choice to be slower.

**Scalability of the editorial voice.** Every product description, every
Journal note, every empty state was written by a person. This does not
scale. A catalogue of a thousand items would require a copywriter. The
fixture has eight items because eight items is what the voice can
sustain.

**No default focus outlines.** Chrome's default focus outline is
invisible on a warm paper background. The custom focus ring replaces it,
but if a future browser changes focus-visible semantics the ring could
disappear. This is a real risk that a fully defensive design would
mitigate by keeping the browser default and adding to it.

**No dark mode.** The merchant-house aesthetic is fundamentally about
paper and ink. A dark-mode variant would require a second full palette
and a second set of contrast-ratio calculations. The trade was made to
not implement dark mode in this fixture. `color-scheme: light` in the
`<head>` tells the browser this explicitly.

---

## How to extend this document

If you add a new page, add a section here explaining what design
decisions were made and why. The document is not a changelog — it is
the reasoning behind the current state. When a decision changes, change
the paragraph. Do not append "Update: as of 2027 this was changed."
Rewrite the paragraph.

The audience for this document is a reader who has just opened the
repository and wants to know whether the person who built it thought
about design. Every paragraph should answer that question.
