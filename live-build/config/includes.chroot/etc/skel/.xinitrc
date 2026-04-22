#!/bin/bash
#
# ~/.xinitrc — wagonOS default
# Executed by startx (or by the dwm session entry via ly)

# Status bar + network applet
slstatus &
nm-applet &

# Compositor (tear-free for gaming)
picom -b &

# Notification daemon
dunst &

# Wallpaper (if present)
[ -f ~/pictures/wallpaper.jpg ] && feh --bg-scale ~/pictures/wallpaper.jpg &
[ -f /usr/share/wagonos/wallpaper/default.jpg ] && [ ! -f ~/pictures/wallpaper.jpg ] && \
    feh --bg-scale /usr/share/wagonos/wallpaper/default.jpg &

# Window manager (final exec keeps the X session alive)
exec dwm
