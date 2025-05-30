### 🎮 Gamepad Control Mappings

sudo evtest /dev/input/event##

|  Key    | Gamepad     | MPV/Neovim Function                                     |
| --------------------- | --------------------------------------------------------|
| `KEY_M` | R button    | `script-message dynamic_chapter_loop/toggle`            |
| `KEY_R` | R2 button   | `["cycle", "pause"]`                                    |
| `KEY_K` | L button    | —                                                       |
| `KEY_L` | L2 button   | `["show-progress"]`                                     |
| `KEY_H` | X button    | `script-message chapter_controls/jump_previous_chapter` |
| `KEY_J` | B button    | `script-message chapter_controls/jump_next_chapter`     |
| `KEY_I` | Y button    | `script-message add-chapter <neovim line>`              |
| `KEY_G` | A button    | `script-message chapters/remove_chapter`                |
| `KEY_N` | - select    | `script-message chapter_controls/nudge_chapter_later`   |
| `KEY_O` | + start     | `script-message chapter_controls/nudge_chapter_earlier` |
| `KEY_S` | Home button | `["cycle", "pause"]`                                    |
| `KEY_C` | D-pad up    | `["add", "volume", 2]`                                  |
| `KEY_D` | D-pad down  | `["add", "volume", -2]`                                 |
| `KEY_F` | D-pad right | `["no-osd", "seek", -5, "exact"]`                       |
| `KEY_E` | D-pad left  | `["no-osd", "seek", 5, "exact"]`                        |


|  Key    | Gamepad     | MPV/Neovim Function                                     |
| --------------------- | --------------------------------------------------------|
| `KEY_M` | R button    | `script-message dynamic_chapter_loop/toggle`            |
| `KEY_R` | R2 button   | `["cycle", "pause"]`                                    |
| `KEY_K` | L button    | —                                                       |
| `KEY_L` | L2 button   | `["show-progress"]`                                     |
| `KEY_H` | X button    | `script-message chapter_controls/jump_previous_chapter` |
| `KEY_J` | B button    | `script-message chapter_controls/jump_next_chapter`     |
| `KEY_I` | Y button    | `script-message add-chapter <neovim line>`              |
| `KEY_G` | A button    | `script-message chapters/remove_chapter`                |
| `KEY_N` | - select    | `script-message chapter_controls/nudge_chapter_later`   |
| `KEY_O` | + start     | `script-message chapter_controls/nudge_chapter_earlier` |
| `KEY_S` | Home button | `["cycle", "pause"]`                                    |
| `KEY_C` | D-pad up    | `["add", "volume", 2]`                                  |
| `KEY_D` | D-pad down  | `["add", "volume", -2]`                                 |
| `KEY_F` | D-pad right | `["no-osd", "seek", -5, "exact"]`                       |
| `KEY_E` | D-pad left  | `["no-osd", "seek", 5, "exact"]`                        |




