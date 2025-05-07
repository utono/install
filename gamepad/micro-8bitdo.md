# mpv-micro-bluetooth-gamepad-8bitdo.md

!!! the key presses of the gamepad are for the real_prog_dvorak layout
!!! in ~/.config/mpv/scripts/micro-to-mpv-27.py, use the qwerty equivalents
!!! systemctl --user stop keyboard-to-mpv-event-27.service
!!! m ---> real_prog_dvorak = m
!!! p ---> real_prog_dvorak = r
!!! t ---> real_prog_dvorak = y

L:              L2:                     R:          R2:
 +----------+      +---------+          +-------+    +----------------+
 |   k      |      |    l    |          |   m   |    |      r         | 
 |  (t)     |      |         |          |  (m)  |    |     (p)        |
 |          |      |         |          | pause |    | show-progress  |
 +----------+      +---------|          +-------+    +----------------+

Minus:                                  Plus:
+-----+                                 +-----+
|  n  | "no-osd", "seek", 2, "exacts"   |  o  | "script-message", add_chapter
| (b) |                                 | (r) |
+-----+                                 +-----+

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
              |      j     |    "pause"
              |     (h)    |
              +------------+

Star:
    +--------+
    |        |
    +--------+

Home:

    +--------+
    |  (s)   |  "no-osd", "seek", -2, "exact"
    |   o    |
    +--------+

d-pad:
          +-----+
          |  c  |   "add", "volume", 2 
    +-----+-----+----+
    |  e          f  | "script-message", "remove_chapter" / "no-osd", "seek", -5, "exact"
    +-----+-----+----+
          |  d  |  "add", "volume", -2
          +-----+

