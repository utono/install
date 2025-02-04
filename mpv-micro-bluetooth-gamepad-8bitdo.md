# mpv-micro-bluetooth-gamepad-8bitdo.md

!!! the key presses of the gamepad are for the real_prog_dvorak layout
!!! in ~/.config/mpv/scripts/micro-to-mpv-27.py, use the qwerty equivalents
!!! systemctl --user stop keyboard-to-mpv-event-27.service
!!! m ---> real_prog_dvorak = m
!!! p ---> real_prog_dvorak = r
!!! t ---> real_prog_dvorak = y

R:        R2:
 +-----+    +-----+
 |  m  |    |  r  |
 | (m) |    | (p) |
 +-----+    +-----+

    ecodes.KEY_M: {"command": ["cycle", "pause"]},
    ecodes.KEY_R: {"command": ["show-progress"]},

L:        L2:
 +-----+    +-----+
 |  y  |    |  b  |
 | (t) |    | (n) |
 +-----+    +-----+

Plus:

    +--------+
    |    o   |
    |   (r)  |
    +--------+

    ecodes.KEY_O: {"command": ["script-message", "add_chapter"]},

Minus:
    +--------+
    |    n   |
    |   (b)  |
    +--------+

    ecodes.KEY_N: {"command": ["script-message", "remove_chapter"]},

YXAB:
           +----------------------------------+
           |            e                     |
           |     d (Remove Chapter)           |
           +----------------------------------+

+---------------+                          +--------------------------+
|      G        |                          |           I              |
|      q        |                          |           j              |
+---------------+                          +--------------------------+

           +------------------------------------+
           |           j                        |
           |    (h -Write Chapters)             |
           +------------------------------------+

Star:
    +--------+
    |        |
    +--------+

Home:

    +--------+
    |   o    |
    +--------+

d-pad:
          +----------+
          |          |
          |     h    |  
          |    (j)   |
          |          |
    +-----+----------+----- +
    |                       |
    |  v                f   |  
    | (.)              (u)  |
    |                       |
    +-----+----------+----- +
          |          |
          |    d     |  
          |   (e)    |
          |          |
          +----------+

