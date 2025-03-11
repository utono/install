# mpv-micro-bluetooth-gamepad-8bitdo.md

!!! the key presses of the gamepad are for the real_prog_dvorak layout
!!! in ~/.config/mpv/scripts/micro-to-mpv-27.py, use the qwerty equivalents
!!! systemctl --user stop keyboard-to-mpv-event-27.service
!!! m ---> real_prog_dvorak = m
!!! p ---> real_prog_dvorak = r
!!! t ---> real_prog_dvorak = y

R:        R2:
 +-----+    +-----+
 |  m  |    |  r  | pause / show-progress
 | (m) |    | (p) |
 +-----+    +-----+

L:        L2:
 +-----+    +-----+
 |  y  |    |  b  | pause / show-progress
 | (t) |    | (n) |
 +-----+    +-----+

Minus: Plus:

    +--------+
    |    o   |  "script-message", add_chapter
    |   (r)  |
    +--------+

Minus:
    +--------+
    |    n   |   "no-osd", "seek", 2, "exacts"
    |   (b)  |
    +--------+

YXAB:
              +------------+
              |      h     |    "script-messages", "write_chapters"
              |     (d)    |
              +------------+

+------------+              +-----------+
|      i     |              |     g     |    "add", "chapter", -1 / "add", "chapter", 1
|     (c)    |              |    (i)    |
+------------+              +-----------+

              +------------+
              |      j     |    "show-progress"
              |     (h)    |
              +------------+

Star:
    +--------+
    |        |
    +--------+

Home:

    +--------+
    |  (s)   |  "no-osd", "seek", -2, "exacts"
    |   o    |
    +--------+

d-pad:
          +----------+
          |          |
          |     c    |   "add", "volume", 2 
          |    (j)   |
          |          |
    +-----+----------+----- +
    |                       |
    |  e                f   | "show-progress" / "script-message", "remove_chapter" 
    | (.)              (u)  |
    |                       |
    +-----+----------+----- +
          |          |
          |    d     |  "add", "volume", -2
          |   (e)    |
          |          |
          +----------+

