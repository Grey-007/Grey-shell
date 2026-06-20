# Quickshell Config Requirements

This document lists all the necessary dependencies to get this Quickshell setup running perfectly from a fresh Arch Linux + Hyprland installation.

## 1. Core & Window Manager
- `hyprland` - The Wayland compositor
- `quickshell` - The Qt-based shell framework
- `xdg-desktop-portal-hyprland` - Desktop portal for screensharing/Wayland compatibility

## 2. Qt, GTK & Theming
Quickshell actively generates themes for your system. These tools ensure the generated themes apply across Qt and GTK applications smoothly:
- `qt5-wayland` & `qt6-wayland` - Essential for running Qt apps natively on Wayland
- `qt5ct` & `qt6ct` - Qt configuration tools (Quickshell writes color palettes directly to these)
- `kvantum` & `kvantum-qt5` - SVG-based theme engine for Qt applications
- `nwg-look` - GTK settings editor for Wayland (useful for setting GTK cursors, icons, etc.)
- `glib2` - Provides `gsettings`, used by Quickshell to instantly apply GTK themes on the fly
- `dbus` - Provides `dbus-send`, used by Quickshell to instruct apps to reload their themes

## 3. Audio & Media
Quickshell communicates directly with Pipewire for volume control and media readouts:
- `pipewire` - Core audio server
- `wireplumber` - Session/policy manager for Pipewire
- `pipewire-audio` & `pipewire-pulse` - For full PulseAudio drop-in compatibility

## 4. Hardware, Network & Bluetooth
The Control Centre dynamically hooks into CLI tools to manage connections and hardware:
- `networkmanager` - Provides `nmcli` for Wi-Fi scanning and connection
- `bluez` & `bluez-utils` - Provides `bluetoothctl` for Bluetooth scanning and connection
- `brightnessctl` - Required for adjusting screen backlight through the Control Centre

## 5. Screenshots & Screen Recording
Used by the Screen Capture and Recording widgets in the shell:
- `hyprshot` - Core screenshot tool wrapper
- `grim` - Image grabber for Wayland
- `slurp` - Region selector for Wayland
- `wf-recorder` - Used for capturing video recordings of your screen

## 6. Clipboard Management
Used by the Quickshell clipboard history manager:
- `cliphist` - Keeps track of clipboard history
- `wl-clipboard` - Provides `wl-copy` and `wl-paste`

## 7. General Utilities
- `python` - Powers the intelligent theme importing logic (`import_theme.py`, `apply_system_theme.py`, etc.)
- `kitty` - The default terminal. Quickshell automatically injects generated colors into `~/.config/kitty/theme.conf`.
- `libnotify` - Provides `notify-send` for shell notifications

## 8. Fonts & Icons
To ensure symbols, text, and application icons render properly:
- `noto-fonts` & `noto-fonts-emoji` - Primary sans-serif and emoji fonts
- `ttf-nerd-fonts-symbols` - Provides Nerd Font icons (CPU, RAM, Volume symbols, etc.)
- `papirus-icon-theme` - Recommended fallback icon theme for launcher and tray icons

*After installing fonts, make sure to refresh your font cache:*
```sh
fc-cache -fv
```
