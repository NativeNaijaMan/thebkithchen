# **Game Design Document: The Broken Kitchen**

**Alignment:** Visuals and UI behavior follow `DesignLanguage.md`. Build order and engineering tasks follow `ImplementationPlan.md`. The internal Flutter package name may differ from the **store title** "The Broken Kitchen"; the store listing and in-game branding should use the game name players recognize.

---

## **1. Core Concept & Overview**

**The Broken Kitchen** is a memory-based kitchen puzzle game. The player is a line cook working in a hectic digital kitchen. Each level presents a **recipe request** (e.g. "Fry an Egg") and a **grid of kitchen items**. The items are shown briefly, then disappear. The player must recall which items are needed and tap the correct tiles before time runs out.

The twist: not every item on the grid is relevant, the grid grows larger as levels progress, and the memorization window shrinks. The player doesn't always need a perfect answer—each puzzle has a **minimum threshold** of correct selections to pass—but this leniency creates a fast-paced psychological challenge where the player must decide quickly which items matter most.

* **Target Audience:** Casual players and puzzle fans; family-friendly (**E for Everyone** tone).
* **Tech Stack:** **Flutter** for all UI, grid rendering, animations, and state management. No game engine required—the tile grid is widget-based.
* **Monetization / data:** Decide **one** model before launch—**paid once** *or* **ad-supported**. **Offline-capable** play is a design goal. **No personal data collection**; a short offline privacy notice is still required for stores.

---

## **2. Core Gameplay Loop**

1. **Receive the Order:** A ticket names a recipe (e.g. "Fry an Egg," "Boil Pasta," "Chop a Salad").
2. **Memorize:** A grid of kitchen item tiles (pans, eggs, fire, knives, pots, etc.) is displayed for a limited time. The player studies the grid.
3. **Recall:** All tiles flip face-down (or fade to blank). The player must tap the tiles that contained items needed to fulfill the recipe.
4. **Evaluate:** The game checks selections against the required items. If the player selected at least the **minimum threshold** of correct items, the level is passed.
5. **Score:** Stars are awarded based on accuracy, wrong picks, and remaining time. Next level unlocks.

---

## **3. The Grid System**

The grid is the central gameplay element. It scales with difficulty:

| Grid Size | Total Tiles | Level Range | Character |
| :--- | :--- | :--- | :--- |
| **4×4** | 16 | Levels 1–5 | Tutorial / easy. Few distractors, generous time. |
| **5×5** | 25 | Levels 6–10 | Medium. More items to scan, tighter memorization window. |
| **6×6** | 36 | Levels 11–15 | Hard. Complex recipes with many required items among dense distractors. |
| **7×7** | 49 | Levels 16–20 | Expert. Maximum pressure, minimal memorization time. |

### **Grid Composition**

Each grid contains:
- **Correct items:** Kitchen tools/ingredients needed for the recipe (e.g. frying pan, egg, fire/stove for "Fry an Egg"). Placed at random positions.
- **Distractor items:** Plausible but incorrect kitchen items (e.g. a pot, a whisk, a rolling pin). Fill the remaining tiles.
- **Empty tiles (optional):** At lower difficulties, some tiles may be blank to reduce cognitive load.

### **Memorization Phase**

- Items are shown face-up on the grid for a **limited duration** (scales with difficulty).
- A visible countdown or progress bar shows how much memorization time remains.
- The player cannot interact with tiles during this phase.

### **Recall Phase**

- All tiles flip to a uniform back (kitchen-themed card back).
- The player taps tiles to select them. Selected tiles are visually marked (border highlight or subtle glow) but do **not** reveal their contents until evaluation.
- The player can deselect a tile by tapping it again.
- A **"Submit Order"** button (or automatic submission after selecting the expected number of items) triggers evaluation.
- A countdown timer runs during this phase. If it expires, the level fails.

---

## **4. Kitchen Item Catalog**

All items are kitchen-themed. Each has a unique **ID**, **display name**, and **icon/emoji placeholder**.

### **Cooking Tools**
| ID | Name | Icon |
| :--- | :--- | :--- |
| `frying_pan` | Frying Pan | 🍳 |
| `pot` | Pot | 🍲 |
| `knife` | Knife | 🔪 |
| `cutting_board` | Cutting Board | 🪓 |
| `spatula` | Spatula | 🥄 |
| `whisk` | Whisk | 🥢 |
| `bowl` | Mixing Bowl | 🥣 |
| `plate` | Plate | 🍽️ |
| `oven_mitt` | Oven Mitt | 🧤 |
| `rolling_pin` | Rolling Pin | 📏 |
| `colander` | Colander | 🫗 |
| `ladle` | Ladle | 🥄 |

### **Ingredients**
| ID | Name | Icon |
| :--- | :--- | :--- |
| `egg` | Egg | 🥚 |
| `butter` | Butter | 🧈 |
| `oil` | Oil | 🫒 |
| `salt` | Salt | 🧂 |
| `pepper` | Pepper | 🌶️ |
| `onion` | Onion | 🧅 |
| `tomato` | Tomato | 🍅 |
| `pasta` | Pasta | 🍝 |
| `bread` | Bread | 🍞 |
| `cheese` | Cheese | 🧀 |
| `lettuce` | Lettuce | 🥬 |
| `chicken` | Chicken | 🍗 |
| `water` | Water | 💧 |
| `flour` | Flour | 🌾 |
| `sugar` | Sugar | 🍬 |
| `milk` | Milk | 🥛 |

### **Heat Sources / Appliances**
| ID | Name | Icon |
| :--- | :--- | :--- |
| `stove` | Stove / Fire | 🔥 |
| `oven` | Oven | ♨️ |
| `toaster` | Toaster | 🍞 |
| `microwave` | Microwave | 📡 |

---

## **5. Recipe Definitions**

Each level has a **recipe request** that implies a set of correct items. Recipes are designed so the correct items feel intuitive—players should be able to reason about what's needed even under time pressure.

### **Example Recipes (representative, not exhaustive)**

| Recipe | Correct Items | Min Threshold |
| :--- | :--- | :--- |
| Fry an Egg | `frying_pan`, `egg`, `stove`, `oil` | 2 of 4 |
| Boil Water | `pot`, `water`, `stove` | 2 of 3 |
| Make Toast | `bread`, `toaster`, `butter` | 2 of 3 |
| Chop a Salad | `knife`, `cutting_board`, `lettuce`, `tomato`, `bowl` | 3 of 5 |
| Bake a Cake | `bowl`, `flour`, `egg`, `sugar`, `butter`, `oven` | 4 of 6 |
| Cook Pasta | `pot`, `water`, `stove`, `pasta`, `colander`, `salt` | 4 of 6 |

The threshold is intentionally forgiving on early levels and strict on later ones, creating a psychological balancing act: do I go for all items or play it safe?

---

## **6. Difficulty Scaling**

Difficulty increases across three axes:

### **A. Grid Complexity**
- More tiles means more items to scan and remember.
- Higher levels have more distractor items that are thematically similar to correct ones (e.g. a pot as a distractor when the recipe needs a frying pan).

### **B. Time Pressure**
| Parameter | Levels 1–5 | Levels 6–10 | Levels 11–15 | Levels 16–20 |
| :--- | :--- | :--- | :--- | :--- |
| Memorize duration | 5–6 s | 4–5 s | 3–4 s | 2–3 s |
| Recall timer | 30–25 s | 25–20 s | 20–15 s | 15–12 s |

### **C. Threshold Strictness**
- Early levels: pass with 1–2 correct out of 3–4 required.
- Late levels: must get 4–5 correct out of 5–6 required.

---

## **7. Win / Lose Conditions & Scoring**

### **Win**
The player selects at least **minCorrectThreshold** correct items during the recall phase and submits before the timer expires.

### **Lose**
- **Timeout:** The recall timer expires before the player submits.
- **Below threshold:** The player submits but did not select enough correct items.

### **Star Scoring (1–3 Michelin Stars)**
Stars reward precision and speed:

| Stars | Criteria |
| :--- | :--- |
| 3 Stars | All correct items selected, zero wrong selections, submitted with significant time remaining (>50% timer left) |
| 2 Stars | Threshold met with at most 1 wrong selection |
| 1 Star | Bare minimum threshold met (any number of wrong selections) |

---

## **8. Screen Flow & Thematic UI Naming**

The KitchenOS terminal metaphor is retained from the original design.

### **A. Splash Screen**
* **Visual:** Developer logo, then a short boot-style sequence ("Loading KitchenOS...").
* **Function:** Load assets and transition to the Terminal.

### **B. Main Menu (The Terminal)**
* **Clock In** — Start / continue the campaign (loads the next unlocked level).
* **Order History** — Level select grid showing all 20 levels with star display and lock states.
* **Employee Manual** — How to play (explains memorize → recall → submit loop).
* **Appliance Calibration** — Settings (sound toggle).
* **Hang Up Apron** — Quit.

### **C. Employee Manual (How to Play)**
* **Content:** Explain the core loop: read the recipe, memorize the grid, recall the correct items, submit before time runs out. Mention that you don't always need every item—just enough to meet the threshold.

### **D. Gameplay Screen (The Line)**
* **The Ticket Rack:** Recipe request at the top (ticket styling per Design Language).
* **The Puzzle Grid:** Central area showing the item grid (memorize phase) or card backs (recall phase).
* **The Timer Bar:** Visual countdown bar below the grid.
* **Submit Order:** Button to confirm selections during the recall phase.
* **Halt Order:** Pause control in a consistent corner.

### **E. Pause Menu (Halt Order)**
* **Resume Shift** — Resume play (timer resumes).
* **Scrap Order** — Restart level.
* **Back to Terminal** — Main menu.

### **F. Level Complete / Game Over**
* **Order Up (Win):** Stars earned, accuracy summary (X/Y correct, Z wrong), time remaining. **Next Ticket** or **Back to Terminal**.
* **Health Inspection Failed (Lose):** Show what went wrong (timeout or wrong items). **Retry** and **Back to Terminal**.

### **G. Order History (Level Progression)**
* Grid of 20 tickets showing stars per level.
* Locked levels show as "Ticket Not Printed Yet."
* First level always unlocked; subsequent levels unlock with >= 1 star on previous.

### **H. Privacy (Health & Safety Notice)**
* Accessible from Appliance Calibration.
* States offline play, no data collection, no accounts.

---

## **9. Play, Pause, and Resume**

* **Memorize Phase:** Timer ticks down; pausing freezes the memorize countdown. Resuming does **not** re-show items that were visible—the countdown continues from where it stopped.
* **Recall Phase:** Pausing freezes the recall timer and hides the grid (prevent "pause-peeking" exploits). Resuming restores the grid state with card backs.
* **Between phases:** Pause is always available.

---

## **10. Progression & Campaign**

* **20 levels** across 4 difficulty tiers (4×4 → 5×5 → 6×6 → 7×7).
* **Linear unlock:** Each level requires >= 1 star on the previous level to unlock.
* **Replayability:** Players can replay any unlocked level to improve their star rating.
* **Stars are persistent** via shared_preferences.

---

## **11. Version 1 Content Scope**

* **20 handcrafted levels** with rising difficulty.
* **All screens** from Section 8 implemented.
* **Employee Manual** + **restart** + **privacy** visible.
* **Placeholder icons** (emoji) for kitchen items in v1; custom pixel art or vector icons in a future update.
* **Sound:** Tile flip sound, correct/wrong feedback sounds, timer urgency sound, victory jingle.
