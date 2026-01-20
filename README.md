# Save Position Manager v2.6

A high-performance, feature-rich MoonLoader script for **GTA: San Andreas Multiplayer (SA-MP)**. This tool allows players and developers to save, manage, and teleport to multiple coordinates using a modern **mimgui** interface.

---

## Features

*   **Instant Teleportation:** Move to saved locations instantly (supports both on-foot and in-vehicle).
*   **Teleport Cooldown:** Built-in 10-second cooldown to prevent server-side detection or spam.
*   **Multi-Slot Saving:** Save an unlimited number of positions with custom names.
*   **Smart Search:** Quickly filter through your saved positions using the real-time search bar.
*   **Permanent Storage:** All data is saved in `config/SavedPositions.json`.
*   **Export/Import:** Easily share your positions or back them up via the Export/Import system (JSON format).
*   **Modern UI:** Clean and responsive interface built with `mimgui`.

---

## Installation

1.  Ensure you have MoonLoader installed.
2.  Download the script files.
3.  Place `SavePosition.lua` into your `moonloader/` folder.
4.  Place `SavePosJSON.lua` into your `moonloader/lib/` folder.
5.  Launch the game!

---

## Usage

### Hotkeys
| Key | Action |
| :--- | :--- |
| **F10** | Toggle the Main Menu |

### Chat Commands
| Command | Description |
| :--- | :--- |
| `/spos [name]` | Save current position with an optional name |
| `/lpos [index]` | Teleport to a position by its list index |
| `/poslist` | Display all saved positions in the chat |

---

## Data Management

### Exporting
Clicking **EXPORT Positions** generates a human-readable and JSON-formatted file at:
`MoonLoader/config/SavedPositions_Export.txt`

### Importing
1.  Open the Import window in the menu.
2.  Paste the JSON array (e.g., `[{"name": "Grove", "x": ...}]`).
3.  Click **Import Data**.
*Note: Importing replaces your current list. Always export a backup first!*

---

## Dependencies

The script requires the following libraries (included in standard MoonLoader distributions or provided in this repo):
- `mimgui`
- `vkeys`
- `encoding`
- `ffi`
- `SavePosJSON` (Custom JSON parser)

---

## Author

**Developed by BOJO Dev**
*Version: 2.6*

---
*Disclaimer: Use teleportation features responsibly. Some servers may have anti-cheat systems that detect coordinate warping.*