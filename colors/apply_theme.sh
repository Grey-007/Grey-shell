#!/bin/sh
MODE=$1
if [ "$MODE" = "Dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme 'default'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
fi
python3 /home/grey/.config/quickshell/colors/update_themes.py
