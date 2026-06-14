# reader-shell — Lock Screen

A minimal, sepia-toned Material 3 ("Material You" / Android 16 Expressive
style) Hyprland lock screen built on **Quickshell 0.3.0**, using the
`wlr-session-lock` protocol via `WlSessionLock`.

## What's included

```
reader-shell/
├── shell.qml          entry point — locks session, one surface per monitor
├── Colours.qml         ★ all colours — sepia Material 3 palette (singleton)
├── Config.qml          all non-colour settings — paths, fonts, sizing, motion
├── Time.qml             shared clock/date (singleton)
├── Auth.qml             PAM authentication (singleton, PamContext wrapper)
├── Card.qml              shared widget container (shape + entrance animation)
├── Background.qml       blurred wallpaper + sepia scrim
├── ClockView.qml         big time + date
├── AvatarRing.qml        circular avatar with sepia ring
├── PasswordField.qml     pill-shaped unlock input, dot indicators, shake-on-fail
├── MediaCard.qml         MPRIS "now playing" widget
├── BatteryPill.qml       battery widget (UPower)
├── WeatherPill.qml       weather widget (wttr.in via curl)
└── ReadingCard.qml       "Now Reading" book/quote widget (the reader-shell touch)
```

## 1. Install

```bash
mkdir -p ~/.config/quickshell
cp -r reader-shell ~/.config/quickshell/
```

**Dependencies**

- `quickshell` ≥ 0.3.0 (with Wayland + PAM support compiled in)
- `curl` — used for the weather widget (skips itself gracefully if missing)
- The **Inter** font is recommended for the cleanest Material 3 look
  (`fc-list | grep -i inter` to check). Falls back to your system sans-serif
  if not installed — nothing breaks.

## 2. Customize

Open **`Config.qml`** and set:

- `avatarPath` — path to a square-ish image (defaults to `~/.face`). If it
  can't load, a tonal circle with your first initial is shown instead.
- `wallpaperPath` — your current Hyprland wallpaper. If missing, a sepia
  gradient is used automatically.
- `readingTitle`, `readingAuthor`, `readingProgress`, `readingQuote` — your
  "Now Reading" widget.
- `weatherLocation` — leave `""` to auto-detect by IP, or set a city name.

All **colours** live in **`Colours.qml`** — it's a sepia Material 3 tonal
palette (`primary`, `surfaceContainer`, `onSurface`, etc). Change `seed` and
the tonal values there to retheme everything at once; every widget pulls
from this one file.

## 3. Test it (safely!)

Before wiring it into Hyprland, run it manually first:

```bash
quickshell -c reader-shell
```

Your screen will lock immediately. Type your normal login password and
press Enter (or tap the → button) to unlock.

⚠️ **Keep an SSH session or another TTY (Ctrl+Alt+F3) open the first time**,
just in case authentication doesn't fire correctly — you can recover with:

```bash
pkill quickshell        # kills the lock surface
loginctl unlock-session # if the session was marked locked
```

## 4. Hyprland integration

In `hyprland.conf`, bind a manual lock key:

```ini
bind = SUPER, L, exec, quickshell -c reader-shell
```

For idle locking, use `hypridle` (`~/.config/hypr/hypridle.conf`):

```ini
general {
    lock_cmd = pidof quickshell || quickshell -c reader-shell
    before_sleep_cmd = loginctl lock-session
}

listener {
    timeout = 300
    on-timeout = loginctl lock-session
}
```

If you currently use `hyprlock`, you can simply stop calling it and point
`lock_cmd` / your lock keybind at the command above instead — no need to
uninstall it.

## 5. Notes & troubleshooting

- **Widgets auto-hide.** The media, battery, weather and reading widgets
  each disappear cleanly (with an animated collapse) if there's nothing to
  show — e.g. no battery on a desktop, or nothing playing in MPRIS.
- **PAM**: `Auth.qml` uses Quickshell's `PamContext` with its default
  service. If unlocking fails immediately with an authentication *error*
  (not just "wrong password"), your distro may need a PAM service file for
  the calling process — check `/etc/pam.d/` (e.g. copy `/etc/pam.d/login`
  to a service quickshell expects) and see
  `Quickshell.Services.Pam.PamContext.configDirectory` in the docs.
- **Performance**: the wallpaper blur is rendered once via `MultiEffect`
  and only a cheap GPU scale transform animates afterwards, so it stays
  smooth even on integrated GPUs. All entrance animations use Material 3
  "emphasized"/"expressive" bezier curves defined in `Config.qml`.
- **Multi-monitor**: `WlSessionLockSurface` is instantiated per screen
  automatically by `WlSessionLock` — every monitor gets its own full
  LockScreen.
- **Album art / avatar masking** uses `MultiEffect`'s `maskSource` (no
  extra Qt modules needed). If your Quickshell build doesn't support
  `QtQuick.Effects` masking, install `qt6-5compat` and swap the
  `MultiEffect` mask block in `AvatarRing.qml` / `MediaCard.qml` for
  `Qt5Compat.GraphicalEffects.OpacityMask` via `layer.effect`.
