# CardShark (v3.8)

**CardShark** is a custom Windower 4 addon for *Final Fantasy XI* designed specifically for **Escutcheon** quest progression. It dynamically monitors incoming network packets to track, display, and persist Escutcheon Crest Card drops by mob name and zone in real time.

---

## Features

- **Dynamic Packet Sniffing:** Tracks incoming item drops (`0x020`) and links them directly to recent mob action/defeat events (`0x028`).
- **Cleave & AOE Ready:** Features a sliding memory queue buffer (`recent_kills`) that retains up to 5 recently defeated mobs with high-precision timestamps, ensuring accurate mob attribution even during rapid multi-mob kills or fast-paced AOE pulls.
- **Onscreen Draggable Window:** Displays a real-time UI overlay showing logged card drops for your current zone.
- **Elemental Color Coding:** Color-codes both card names and mob names according to their elemental affinity:
  - <font color="#FF5050">**Fire Crest Card**</font>: Red (`\cs(255,80,80)`)
  - <font color="#FFFF64">**Earth Crest Card**</font>: Yellow (`\cs(255,255,100)`)
  - <font color="#C864FF">**Lightning Crest Card**</font>: Purple (`\cs(200,100,255)`)
  - <font color="#64FF64">**Wind Crest Card**</font>: Green (`\cs(100,255,100)`)
  - <font color="#FFFFFF">**Light Crest Card**</font>: White (`\cs(255,255,255)`)
  - <font color="#A0A0A0">**Dark Crest Card**</font>: Gray (`\cs(160,160,160)`)
  - <font color="#508CFF">**Water Crest Card**</font>: Blue (`\cs(80,140,255)`)
  - <font color="#82DCFF">**Ice Crest Card**</font>: Light Blue (`\cs(130,220,255)`)
- **Zone Filtering:** Automatically filters the UI overlay to reflect only drops for your active zone.
- **Persistent Storage:** Automatically writes and updates discovered drop data to `CardShark_Data.lua`. Data persists across game sessions.

---

## Installation

1. Create a folder named `CardShark` inside your Windower 4 addons directory:
   ```text
   Windower4/addons/CardShark/
   ```
2. Place `CardShark.lua` inside the `CardShark` folder.
3. (Optional) Place an existing `CardShark_Data.lua` file inside the folder if migrating existing drop data.
4. Load the addon in-game:
   ```text
   //lua load cardshark
   ```

---

## Usage & Commands

CardShark runs automatically in the background once loaded. You can interact with the addon using the `//cardshark` or `//cs` command alias.

| Command | Description |
| :--- | :--- |
| `//cs` | Refreshes and displays the overlay window for your current zone. |
| `//cs show` | Forces the overlay window to display. |
| `//cs hide` | Hides the overlay window. |
| `//cs help` | Displays available command options in the chat log. |

---

## Dependencies

CardShark relies on the standard Windower 4 Lua libraries:
- `luau`
- `packets`
- `files`
- `texts`
- `config`
- `resources`