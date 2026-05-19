#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) |
  while read -r img; do
    echo -en "$img\0icon\x1f$img\n"
  done |
  rofi -dmenu \
    -i \
    -p "  Wallpaper" \
    -theme "/home/joe/.config/rofi/dracula-warm" \
    -show-icons \
    -theme-str 'listview { columns: 3; } element-icon { size: 100px; }')

if [ -n "$SELECTED" ]; then
  hyprctl hyprpaper preload "$SELECTED"
  hyprctl hyprpaper wallpaper ",$SELECTED"
  sed -i "s|^wallpaper = .*|wallpaper = ,$SELECTED|" ~/.config/hypr/hyprpaper.conf
  sed -i "s|^preload = .*|preload = $SELECTED|" ~/.config/hypr/hyprpaper.conf
fi
