# Design System Document

## 1. Overview & Creative North Star
### Creative North Star: "The Eldritch Carnival"
This design system is built to bridge the gap between playful gamification and an ominous, high-stakes aesthetic. Inspired by "purplish evil," it moves away from flat, sterile interfaces in favor of a tactile, high-energy world. We reject the standard "digital grid" for an editorial approach that uses **intentional asymmetry**, **overlapping physical layers**, and **high-contrast tonal depth**.

The system creates a sense of "premium chaos." By using chunky 3D forms (Secondary/Gold) against deep, mystical voids (Surface/Deep Purple), the UI feels like a physical machine that is both rewarding to touch and slightly dangerous to operate.

---

## 2. Colors & Textures

### Color Strategy
The palette is dominated by `surface` (#0a0538) to ground the experience in a dark, "evil" space, while `primary` (#cc97ff) and `secondary` (#fed01b) act as high-energy accents.

*   **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. Definition must be achieved through background shifts. For example, a card using `surface-container-highest` (#201a61) should sit directly on a `surface` (#0a0538) background.
*   **Surface Hierarchy & Nesting:** Treat the UI as stacked slabs. 
    *   **Base:** `surface` (#0a0538)
    *   **Sections:** `surface-container-low` (#0e0841)
    *   **Interactive Containers:** `surface-container-highest` (#201a61)
*   **The "Glass & Gradient" Rule:** Use `backdrop-blur` (12px-20px) on floating panels combined with 40% opacity versions of `surface-bright`. 
*   **Signature Textures:** Main CTAs must use a linear gradient: `primary_dim` (#9e41f5) to `primary` (#cc97ff). This provides the "visual soul" required for a premium gamified feel.

---

## 3. Typography

The typography strategy pairs the structural authority of **Epilogue** with the modern readability of **Plus Jakarta Sans**.

*   **Display & Headlines (Epilogue):** Used for large-scale "ominous" messaging. The sharp, geometric terminals of Epilogue provide a sense of architectural weight.
    *   *Scale:* `display-lg` (3.5rem) for major rewards; `headline-md` (1.75rem) for screen headers.
*   **Titles & Body (Plus Jakarta Sans):** These levels handle the "gamified" data. Plus Jakarta’s open apertures ensure legibility even during high-intensity gameplay.
    *   *Scale:* `title-lg` (1.375rem) for card names; `body-md` (0.875rem) for descriptions.
*   **The "Evil" Treatment:** For critical headers, use `on_surface` text with a subtle `secondary` (#fed01b) outer glow to mimic "cursed gold."

---

## 4. Elevation & Depth

In this system, depth is a game mechanic. We avoid traditional drop shadows in favor of **Tonal Layering**.

*   **The Layering Principle:** To lift an element, move up the surface-container scale. A "Collection Card" should use `surface_container_highest` (#201a61) to naturally pop against a `surface_dim` background.
*   **Ambient Shadows:** If an element must float (like a modal), use a high-blur (32px), low-opacity (8%) shadow. The shadow color must be a dark purple tint of the background, never pure black.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke, use `outline_variant` (#454274) at 20% opacity. 
*   **Chunky 3D Effect:** For buttons, simulate a "3D" press by using a 4px solid bottom-offset of a darker color variant (e.g., a `secondary` button with a `secondary_container` bottom "lip").

---

## 5. Components

### Buttons (The "Chunky" Standard)
*   **Primary (Action):** Gradient from `primary_dim` to `primary`. 4px "3D" bottom lip using `on_primary_container`. Corner radius: `md` (0.75rem).
*   **Secondary (Gold/Premium):** Base color `secondary` (#fed01b). These are used for "Shop" or "Claim" actions.

### Cards & Collections
*   **Layout:** Forbid divider lines. Use `1.5rem` (`6` on the spacing scale) of vertical whitespace to separate card groups.
*   **Rarity Glows:** Cards representing high-value items should use an inner-glow effect using `tertiary` (#ff8887) or `secondary` (#fed01b).
*   **Nesting:** Cards must use `surface_container_highest`.

### Navigation Bar
*   **Structure:** A floating dock using a Glassmorphism effect (`surface_container` at 80% opacity + blur).
*   **Iconography:** Bold, thick-stroke icons using `on_surface_variant`. The active state scales the icon by 1.2x and shifts the color to `secondary`.

### Input Fields & Progress Bars
*   **Inputs:** Use `surface_container_lowest` for the field background to create an "inset" feel.
*   **Progress Bars:** The fill must use a vibrant `primary` to `tertiary` gradient.

---

## 6. Do's and Don'ts

### Do
*   **Do** use overlapping elements. A character icon should "break" the top boundary of its container card to create depth.
*   **Do** use `secondary` (#fed01b) sparingly as a "high-value" light source.
*   **Do** utilize the full `xl` (1.5rem) roundedness for large modal containers to maintain the "playful" feel.

### Don't
*   **Don't** use 100% opaque black for shadows. It kills the "purplish evil" vibrance.
*   **Don't** use a standard grid for the Collection view; slightly offset the vertical alignment of columns to create an organic, editorial look.
*   **Don't** use `error` (#ff6e84) for non-critical elements. In this system, red is "dangerous" and reserved for negative feedback only.