# Quickshell Config Requirements

## Runtime

- `quickshell`
- `hyprland`
- `hyprctl`
- `pipewire`
- A working XDG desktop app database for launcher entries

## Fonts

Install these system-wide or user-local:

- `Noto Sans`
- `Noto Sans Mono`
- `Noto Sans Symbols`
- `Noto Sans Symbols 2`
- `Noto Serif Display` for the lockscreen clock

Recommended optional font:

- `Symbols Nerd Font`

Suggested locations:

- User fonts: `~/.local/share/fonts/`
- Config-local fonts: `~/.config/quickshell/fonts/`

Refresh font cache after adding fonts:

```sh
fc-cache -fv
```

## Icons And SVGs

Required config asset:

- `Bar/assets/logo.svg`

Recommended icon theme for launcher and tray icons:

- `Papirus`
- `Tela`
- `Adwaita`

Suggested locations:

- User icon themes: `~/.local/share/icons/`
- System icon themes: `/usr/share/icons/`
- Quickshell-only SVG assets: `~/.config/quickshell/Bar/assets/`

The launcher uses desktop entry icons from the active icon theme. If app icons are missing, install a complete icon theme such as Papirus and make sure desktop entries reference valid icon names.

## Current Bar Symbols

The bar uses Noto-compatible symbols by default:

- CPU: `⚙`
- RAM: `▦`
- Volume muted: `🔇`
- Volume low: `🔈`
- Volume high: `🔊`
- Battery charging: `⚡`
- Power: `⏻`

If you want Nerd Font icons instead, install `Symbols Nerd Font` and update the icon text in:

- `Bar/modules/Cpu.qml`
- `Bar/modules/Ram.qml`
- `Bar/modules/Volume.qml`
- `Bar/modules/PowerButton.qml`
