### 🎮 Gamepad Control Mappings

| Gamepad Button (Key) | Position on Gamepad | MPV/Neovim Function                                     | Description                               |
| -------------------- | ------------------- | ------------------------------------------------------- | ----------------------------------------- |
| `KEY_K`              | L button            | —                                                       |                                           |
| `KEY_L`              | L2 button           | —                                                       |                                           |
| `KEY_R`              | R button            | `["show-progress"]`                                     |                                           |
| `KEY_M`              | R2 button           | `script-message write_chapters`                         |                                           |
| `KEY_H`              | X button            | `script-message chapter_controls/jump_previous_chapter` |                                           |
| `KEY_J`              | B button            | `script-message chapter_controls/jump_next_chapter`     |                                           |
| `KEY_I`              | Y button            | `script-message add-chapter <neovim line>`              |                                           |
| `KEY_G`              | A button            | `script-message chapters/remove_chapter`                |                                           |
| `KEY_N`              | - select            | `script-message chapter_controls/nudge_chapter_later`   |                                           |
| `KEY_O`              | + start             | `script-message chapter_controls/nudge_chapter_earlier` |                                           |
| `KEY_S`              | Home button         | `["cycle", "pause"]`                                    |                                           |
| `KEY_C`              | D-pad up            | `["add", "volume", 2]`                                  |                                           |
| `KEY_D`              | D-pad down          | `["add", "volume", -2]`                                 |                                           |
| `KEY_E`              | D-pad right         | `["no-osd", "seek", 5, "exact"]`                        |                                           |
| `KEY_F`              | D-pad left          | `["no-osd", "seek", -5, "exact"]`                       |                                           |






| Gamepad Button (Key) | Position on Gamepad | MPV/Neovim Function                                     | Description                               |
| -------------------- | ------------------- | ------------------------------------------------------- | ----------------------------------------- |
| `KEY_K`              | L button            |                                                         |                                           |
| `KEY_L`              | L2 button           |                                                         |                                           |
| `KEY_R`              | R button            |                                                         |                                           |
| `KEY_M`              | R2 button           |                                                         |                                           |
| `KEY_H`              | X button            |                                                         |                                           |
| `KEY_J`              | B button            |                                                         |                                           |
| `KEY_I`              | Y button            |                                                         |                                           |
| `KEY_G`              | A button            |                                                         |                                           |
| `KEY_N`              | - select            |                                                         |                                           |
| `KEY_O`              | + start             |                                                         |                                           |
| `KEY_S`              | Home button         |                                                         |                                           |
| `KEY_C`              | D-pad up            |                                                         |                                           |
| `KEY_D`              | D-pad down          |                                                         |                                           |
| `KEY_E`              | L2 button           |                                                         |                                           |
| `KEY_F`              | L2 button           |                                                         |                                           |

| `KEY_H`              | X button            | `nvim.input('<Up>')`                                    | Move Neovim cursor up one line            |
| `KEY_J`              | B button            | `nvim.input('<Down>')`                                  | Move Neovim cursor down one line          |

