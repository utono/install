# mpv-micro-bluetooth-gamepad-8bitdo.md


L:              L2:                     R:          R2:
 +----------+      +---------+          +-------+    +----------------+
 |   k      |      |    l    |          |   m   |    |      r         | 
 |          |      |         |          | pause |    | show-progress  |
 +----------+      +---------|          +-------+    +----------------+

YXAB:
              +------------+
              |      h     |    "script-messages", "write_chapters"
              +------------+

+------------+              +-----------+
|      i     |              |     g     |    "add", "chapter", -1 / "add", "chapter", 1
+------------+              +-----------+

              +------------+
              |      j     |    "pause"
              +------------+

Minus:                                  Plus:
+-----+                                 +-----+
|  n  | "no-osd", "seek", 2, "exacts"   |  o  | "script-message", add_chapter
+-----+                                 +-----+

Star:                                   Home:
+--------+                              +-----+
|        |                              |  s  | "no-osd", "seek", -2, "exact"
+--------+                              +-----+

d-pad:
          +-----+
          |  c  |   "add", "volume", 2 
    +-----+-----+----+
    |  e          f  | "script-message", "remove_chapter" / "no-osd", "seek", -5, "exact"
    +-----+-----+----+
          |  d  |  "add", "volume", -2
          +-----+
