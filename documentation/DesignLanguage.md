Here is the complete Design Language System (DLS) for **The Broken Kitchen**.

This system is built for an all-Flutter UI. It embraces the "KitchenOS" theme—blending the sterile, functional look of a fast-food Point of Sale (POS) system with cozy kitchen elements in a memory puzzle context.

**Assets note:** Typography uses **Space Mono** loaded from local font files. Those files must live under `assets/fonts/` and be registered in the app configuration.

---

### **1. Overall Vibe & Aesthetic**
* **The Look:** "Corporate POS System meets Cozy Kitchen." The UI looks functional and POS-like, creating tension with the puzzle pressure and emoji kitchen items.
* **The Shapes:** Sharp corners for standard UI elements (mimicking old-school terminal software). Puzzle grid tiles use subtle rounding (6dp radius) to soften the grid while keeping the overall POS aesthetic.

### **2. Typography: The "KitchenOS" Font**
Use **Space Mono** for all KitchenOS UI tied to tickets, terminals, and controls. Do not substitute a different monospace unless you update this document and the GDD so marketing and store screenshots stay coherent.

* **Why Space Mono?** Receipt-printer and terminal feel, geometric, legible, and still friendly for a casual puzzle game.

| Hierarchy | Usage | Style Rules (Space Mono) |
| :--- | :--- | :--- |
| **H1 (Titles)** | Splash screen, Terminal Headers | Bold, 32sp, ALL CAPS, Tracking (Letter-spacing): 1.5 |
| **H2 (Subheaders)** | Menu categories, Ticket Numbers | Regular, 24sp, Title Case |
| **Body Large** | Main button text, Dialog headers | Bold, 18sp |
| **Body Medium** | Order ticket items, standard text | Regular, 16sp |
| **Error Text** | Fake bugs, 404 messages | Bold, 14sp, Color: System Red |
| **Micro Text** | Version numbers, fine print | Regular, 10sp |

### **3. Color Palette**
The palette separates the "Interface" from the "Food" and the "Glitches."

#### **Base OS Colors (The Interface)**
* **Countertop Off-White:** `#F4F5F7` (Main background outside the Flame canvas).
* **Receipt White:** `#FFFFFF` (Used for Order Tickets and safe UI panels).
* **Terminal Charcoal:** `#2B2D42` (Primary text color, borders, and standard OS buttons).

#### **Accent Colors (The Kitchen)**
* **Yolk Yellow:** `#FF9F1C` (Call-to-action buttons, "Clock In", highlight states).
* **Mint Appliance:** `#A8DADC` (Secondary buttons, subtle highlights).

#### **Feedback & Status Colors**
* **Panic Red:** `#E63946` (Wrong selections, timer urgency, failure states).
* **BSOD Blue:** `#1D3557` (Terminal backgrounds, tile card backs at rest).
* **Success Green:** `#2A9D8F` (Correct selections, "Order Up," timer healthy state).

### **4. Responsive Layout & Spacing Rules**
* **The Grid:** Use a strict **8dp base grid** for all padding and margins (`8`, `16`, `24`, `32`, `48`).
* **Screen Margins:** A global `16dp` horizontal margin on mobile screens.
* **Safe Areas:** All interactive UI must respect system safe areas (notches, dynamic islands, gesture bars).
* **Dynamic Scaling:** The puzzle grid maintains a **1:1 aspect ratio** within a constrained maximum width (500dp). The ticket header and controls use remaining vertical space with flexible layout.
* **Touch Targets:**
    * Standard buttons: Minimum **48×48 dp** tap area.
    * Puzzle tiles: Scale with grid size. On a 4×4 grid they are generously large; on a 7×7 grid they approach the 48dp minimum. The 1:1 aspect constraint and max-width ensure tiles stay tappable on all devices.

### **5. UI Components & Elements**

#### **A. Buttons (The Culprits)**
* **Standard State:** Flat design, **0** corner radius (sharp corners), solid **Terminal Charcoal** background with **Receipt White** text. A thick **4dp** bottom border for a pushable, POS-like feel.
* **Pressed State:** Bottom border disappears, button shifts down by the same distance as the border (classic plate-button illusion).
* **Glitched State:** Tremor, inverted colors, or label text slightly overflowing the bounds—readable but wrong.

#### **B. The "Ticket" (HUD Element)**
* **Design:** Looks like a literal restaurant order ticket. **Receipt White** background, light drop shadow (small vertical offset, modest blur).
* **Layout:** Pinned to the top of the screen. Text aligned left in **Space Mono**. A jagged bottom edge (graphic or vector) to suggest torn receipt paper.

#### **C. Puzzle Grid Tiles**
* **Face (memorize + result):** Receipt White background, 1dp border, 6dp corner radius. Emoji item centered with FittedBox scaling.
* **Back (recall):** BSOD Blue tint at low alpha, subtle border. A "?" icon centered.
* **Selected back:** Yolk Yellow border (3dp), yellow-tinted background, check icon.
* **Result — correct + selected:** Success Green border, green-tinted background.
* **Result — correct + missed:** Yolk Yellow border, yellow-tinted background (highlights what the player should have picked).
* **Result — wrong + selected:** Panic Red border, red-tinted background.
* **Flip animation:** 350ms 3D Y-axis rotation with perspective (0.001 z-entry).
* **Bounce animation:** 200ms scale sequence (1.0 → 0.9 → 1.05 → 1.0) on selection.

#### **D. Timer Bar**
* **Design:** Horizontal LinearProgressIndicator, 10dp height, 5dp rounded corners.
* **Color transitions:** Success Green (>50%) → Yolk Yellow (25–50%) → Panic Red (<25%).

### **6. Visual Hierarchy & Contrast**
1. **Highest Priority:** The **Recipe Ticket** and **Phase Indicator**. High contrast and light elevation.
2. **Medium Priority:** The **Puzzle Grid** and **Timer Bar**. Central gameplay area that dominates the screen.
3. **Lowest Priority:** The **Submit Order** button and **pause control**. Always accessible but visually subordinate to the grid.
