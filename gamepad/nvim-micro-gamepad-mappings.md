### 🎮 Gamepad Control Mappings

| Gamepad Button (Key) | Position on Gamepad | MPV/Neovim Function                                     | Description                               |
| -------------------- | ------------------- | ------------------------------------------------------- | ----------------------------------------- |
| `KEY_K`              | L1 button           | —                                                       | (Unassigned in script)                    |
| `KEY_L`              | L2 button           | —                                                       | (Unassigned in script)                    |
| `KEY_M`              | R2 button           | `["cycle", "pause"]`                                    | Toggle MPV pause/play                     |
| `KEY_R`              | R1 button           | `["show-progress"]`                                     | Show MPV's on-screen progress bar         |
| `KEY_H`              | X button            | `nvim.input('<Up>')`                                    | Move Neovim cursor up one line            |
| `KEY_J`              | B button            | `nvim.input('<Down>')`                                  | Move Neovim cursor down one line          |
| `KEY_I`              | Y button            | `script-message add-chapter <neovim line>`              | Send current Neovim line as chapter title |
| `KEY_G`              | A button            | `script-message chapter_controls/jump_previous_chapter` | Move MPV to previous chapter              |
| `KEY_O`              | Plus button         | `["no-osd", "seek", -2, "exact"]`                       | Seek backward 2 seconds without OSD       |
| `KEY_N`              | Minus button        | `["no-osd", "seek", 2, "exact"]`                        | Seek forward 2 seconds without OSD        |
| `KEY_S`              | Home button         | `script-message write_chapters`                         | Write chapters to .ffmetadata file        |
| `KEY_C`              | D-pad up            | `["add", "volume", 2]`                                  | Increase volume by 2                      |
| `KEY_D`              | D-pad down          | `["add", "volume", -2]`                                 | Decrease volume by 2                      |
| `KEY_E`              | D-pad left          | `script-message remove_chapter`                         | Remove the current chapter                |
| `KEY_F`              | D-pad right         | `script-message chapter_controls/jump_next_chapter`     | Move MPV to next chapter                  |
