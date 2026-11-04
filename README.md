# CardShark (v4.4)

**CardShark** is a custom Windower 4 Lua addon for *Final Fantasy XI* designed for Escutcheon crafters. It parses live incoming chat logs to instantly track, log, and display Crest Card drops and their corresponding monster sources on a clean, draggable onscreen overlay.

---

## Features

* **Direct Chat-Log Parsing:** Automatically reads in-game drop messages to instantly pair Crest Cards with their exact monster source, eliminating packet queue errors and "Unknown Mob" entries during cleave and AOE farming.
* **Grouped Mob Display:** Combines multiple monster sources for the same card type into a clean, single-line comma-separated list (e.g., `Wind Crest Card : Bat, Hippogryph`).
* **Elementally Color-Coded Display:** Both card names and their associated monster lists automatically render in matching elemental colors (Fire=Red, Earth=Yellow, Lightning=Purple, Wind=Green, Light=White, Dark=Gray, Water=Blue, Ice=Light Blue).
* **Zone-Aware Filtering:** The onscreen overlay automatically filters and displays only the card drops relevant to your active zone.
* **Persistent Local Database:** Automatically saves all discovered drop associations to `CardShark_Data.lua` so your data persists across game sessions.

---

## Installation

1. Navigate to your Windower addons directory:
   ```text
   Windower4/addons/
   ```
2. Create a new folder named **`CardShark`**.
3. Place **`CardShark.lua`** inside that folder.
4. Load the addon in-game:
   ```text
   //lua load cardshark
   ```

---

## Commands

* **`//cs`** or **`//cardshark`** — Refreshes and displays the overlay window for your current zone.
* **`//cs show`** — Displays the overlay window.
* **`//cs hide`** — Hides the overlay window.
* **`//cs help`** — Displays command help in the chat window.

---

## Dependencies

CardShark relies on the standard Windower 4 Lua libraries:
- `luau`
- `packets`
- `files`
- `texts`
- `config`
- `resources`
