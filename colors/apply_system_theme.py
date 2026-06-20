#!/usr/bin/env python3
"""
apply_system_theme.py
Called by ThemeManager._save() as part of the theme-switch chain.
Reads the active theme's QML file, extracts the exact hex colors,
and dynamically generates GTK3/4 CSS to recolor libadwaita/adw-gtk3.
"""

import json
import os
import re
import subprocess
import time

home = os.environ.get("HOME", "/home/grey")
theme_json_path = os.path.join(home, ".config/quickshell/colors/theme.json")
themes_dir = os.path.join(home, ".config/quickshell/colors/themes")

# ── 1. Read active theme name ─────────────────────────────────────────────
try:
    with open(theme_json_path) as f:
        theme_name = json.load(f).get("theme", "Sepia")
except Exception:
    theme_name = "Sepia"

# ── 2. Parse properties from QML ──────────────────────────────
qml_path = os.path.join(themes_dir, f"{theme_name}.qml")
try:
    with open(qml_path) as f:
        qml = f.read()
except Exception:
    exit(0)

def get_str(text, prop, default=""):
    m = re.search(r'property\s+string\s+' + prop + r'\s*:\s*"([^"]*)"', text)
    return m.group(1) if m else default

def get_color(text, prop, default="#000000"):
    # matches e.g. readonly property color primary: "#ff0000"
    m = re.search(r'property\s+color\s+' + prop + r'\s*:\s*"([^"]*)"', text)
    return m.group(1) if m else default

color_scheme = get_str(qml, "colorScheme", "prefer-dark")
is_dark      = (color_scheme == "prefer-dark")
dark_int     = 1 if is_dark else 0

# Extract colors to map to GTK
colors = {
    "primary": get_color(qml, "primary", "#888888"),
    "secondary": get_color(qml, "secondary", "#666666"),
    "primaryContainer": get_color(qml, "primaryContainer", "#444444"),
    "primaryContainerFg": get_color(qml, "primaryContainerFg", "#ffffff"),
    "error": get_color(qml, "error", "#ff0000"),
    "errorContainer": get_color(qml, "errorContainer", "#550000"),
    "errorContainerFg": get_color(qml, "errorContainerFg", "#ffaaaa"),
    "success": get_color(qml, "success", "#00ff00"),
    "secondaryContainer": get_color(qml, "secondaryContainer", "#005500"),
    "secondaryContainerFg": get_color(qml, "secondaryContainerFg", "#aaffaa"),
    "warning": get_color(qml, "warning", "#ffff00"),
    "tertiaryContainer": get_color(qml, "tertiaryContainer", "#555500"),
    "tertiaryContainerFg": get_color(qml, "tertiaryContainerFg", "#ffffaa"),
    "surface": get_color(qml, "surface", "#111111" if is_dark else "#eeeeee"),
    "surfaceFg": get_color(qml, "surfaceFg", "#ffffff" if is_dark else "#000000"),
    "surfaceContainerHigh": get_color(qml, "surfaceContainerHigh", "#222222" if is_dark else "#dddddd"),
    "surfaceContainerLow": get_color(qml, "surfaceContainerLow", "#000000" if is_dark else "#ffffff"),
    "fg": get_color(qml, "fg", "#ffffff" if is_dark else "#000000"),
    "fgDim": get_color(qml, "fgDim", "#cccccc" if is_dark else "#333333"),
    "bg": get_color(qml, "bg", "#000000" if is_dark else "#ffffff"),
    "border": get_color(qml, "border", "#444444" if is_dark else "#bbbbbb"),
    "surfaceTop": get_color(qml, "surfaceTop", "#333333" if is_dark else "#cccccc"),
    "surfaceHigh": get_color(qml, "surfaceHigh", "#222222" if is_dark else "#dddddd"),
}

# The GTK theme we MUST use to allow libadwaita variable overrides for GTK3 apps
gtk_theme = "adw-gtk3-dark" if is_dark else "adw-gtk3"

# ── 3. Generate dynamic gtk.css ───────────────────────────────────────────
css_content = f"""
@define-color accent_color {colors["primary"]};
@define-color accent_bg_color {colors["primaryContainer"]};
@define-color accent_fg_color {colors["primaryContainerFg"]};
@define-color destructive_color {colors["error"]};
@define-color destructive_bg_color {colors["errorContainer"]};
@define-color destructive_fg_color {colors["errorContainerFg"]};
@define-color success_color {colors["success"]};
@define-color success_bg_color {colors["secondaryContainer"]};
@define-color success_fg_color {colors["secondaryContainerFg"]};
@define-color warning_color {colors["warning"]};
@define-color warning_bg_color {colors["tertiaryContainer"]};
@define-color warning_fg_color {colors["tertiaryContainerFg"]};
@define-color error_color {colors["error"]};
@define-color error_bg_color {colors["errorContainer"]};
@define-color error_fg_color {colors["errorContainerFg"]};
@define-color window_bg_color {colors["surface"]};
@define-color window_fg_color {colors["surfaceFg"]};
@define-color view_bg_color {colors["surface"]};
@define-color view_fg_color {colors["surfaceFg"]};
@define-color headerbar_bg_color @window_bg_color;
@define-color headerbar_fg_color @window_fg_color;
@define-color headerbar_border_color @window_bg_color;
@define-color headerbar_backdrop_color @window_bg_color;
@define-color headerbar_shade_color @window_bg_color;
@define-color card_bg_color {colors["surfaceContainerHigh"]};
@define-color card_fg_color {colors["surfaceFg"]};
@define-color card_shade_color rgba(0, 0, 0, 0.07);
@define-color dialog_bg_color @card_bg_color;
@define-color dialog_fg_color @card_fg_color;
@define-color popover_bg_color @card_bg_color;
@define-color popover_fg_color @card_fg_color;
@define-color shade_color rgba(0, 0, 0, 0.36);
@define-color scrollbar_outline_color rgba(139, 145, 152, 0.5);
@define-color sidebar_bg_color {colors["surfaceContainerLow"]};
@define-color secondary_sidebar_bg_color @sidebar_bg_color;
@define-color sidebar_backdrop_color @sidebar_bg_color;
@define-color secondary_sidebar_backdrop_color @sidebar_bg_color;

.navigation-sidebar {{
    background-color: @sidebar_bg_color;
    color: @window_fg_color;
}}

headerbar.default-decoration {{
  margin-bottom: 50px;
  margin-top: -100px;
}}

/* Remove window shadows to prevent double shadows in Hyprland */
window.csd,
window.csd decoration {{
  box-shadow: none;
}}
"""

# ── 4. Write GTK3 config ──────────────────────────────────────────────────
gtk3_dir = os.path.join(home, ".config/gtk-3.0")
os.makedirs(gtk3_dir, exist_ok=True)
with open(os.path.join(gtk3_dir, "settings.ini"), "w") as f:
    f.write(f"""[Settings]
gtk-theme-name={gtk_theme}
gtk-application-prefer-dark-theme={dark_int}
""")

gtk3_css_path = os.path.join(gtk3_dir, "gtk.css")
if os.path.islink(gtk3_css_path):
    os.unlink(gtk3_css_path)
with open(gtk3_css_path, "w") as f:
    f.write(css_content)

# ── 5. Write GTK4 config ──────────────────────────────────────────────────
gtk4_dir = os.path.join(home, ".config/gtk-4.0")
os.makedirs(gtk4_dir, exist_ok=True)
with open(os.path.join(gtk4_dir, "settings.ini"), "w") as f:
    f.write(f"""[Settings]
gtk-application-prefer-dark-theme={dark_int}
""")

gtk4_css_path = os.path.join(gtk4_dir, "gtk.css")
if os.path.islink(gtk4_css_path):
    os.unlink(gtk4_css_path)
with open(gtk4_css_path, "w") as f:
    f.write(css_content)

# ── 6. Apply GTK via gsettings (force redraw) ─────────────────────────────
def gsettings_set(key, val):
    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.interface", key, val],
        capture_output=True
    )

gsettings_set("color-scheme", color_scheme)
# Briefly toggle theme to force running apps to reload CSS
gsettings_set("gtk-theme", "Adwaita")
time.sleep(0.1)
gsettings_set("gtk-theme", gtk_theme)

# ── 7. Generate Qt5/Qt6 dynamic custom palette ─────────────────────────────
qt_colors = [
    colors["fg"],                     # 0 WindowText
    colors["surfaceContainerHigh"],   # 1 Button
    colors["surfaceTop"],             # 2 Light
    colors["surfaceHigh"],            # 3 Midlight
    colors["border"],                 # 4 Dark
    colors["surface"],                # 5 Mid
    colors["fg"],                     # 6 Text
    colors["primary"],                # 7 BrightText
    colors["fg"],                     # 8 ButtonText
    colors["surfaceContainerLow"],    # 9 Base (text edit bg)
    colors["bg"],                     # 10 Window (app bg)
    "#000000",                        # 11 Shadow
    colors["primary"],                # 12 Highlight
    colors["primaryContainerFg"],     # 13 HighlightedText
    colors["primary"],                # 14 Link
    colors["secondary"],              # 15 LinkVisited
    colors["surface"],                # 16 AlternateBase
    "#000000",                        # 17 NoRole
    colors["surfaceContainerHigh"],   # 18 ToolTipBase
    colors["fg"],                     # 19 ToolTipText
    colors["fgDim"]                   # 20 PlaceholderText
]
qt_colors_str = ", ".join(qt_colors)
qt_color_scheme = f"[ColorScheme]\nactive_colors={qt_colors_str}\ndisabled_colors={qt_colors_str}\ninactive_colors={qt_colors_str}\n"

for qtct in ["qt5ct", "qt6ct"]:
    qt_dir = os.path.join(home, f".config/{qtct}")
    qt_colors_dir = os.path.join(qt_dir, "colors")
    os.makedirs(qt_colors_dir, exist_ok=True)
    
    scheme_path = os.path.join(qt_colors_dir, "quickshell.conf")
    with open(scheme_path, "w") as f:
        f.write(qt_color_scheme)

    qt_conf = os.path.join(qt_dir, f"{qtct}.conf")
    with open(qt_conf, "w") as f:
        f.write(f"""[Appearance]
style=Fusion
icon_theme=Adwaita
color_scheme_path={scheme_path}
custom_palette=true
standard_dialogs=default

[Fonts]
general=@Variant(\\0\\0\\0@\\0\\0\\0\\nNoto Sans\\0\\0\\0\\0\\0\\0\\xff\\xff\\xff\\xff\\x5\\x1\\0\\x12\\x10)
fixed=@Variant(\\0\\0\\0@\\0\\0\\0\\x10Noto Sans Mono\\0\\0\\0\\0\\0\\0\\xff\\xff\\xff\\xff\\x5\\x1\\0\\x12\\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
""")

# Tell running qt5ct and qt6ct apps to reload their config via DBUS
# Requires 'qdbus' or 'dbus-send' but qtct handles it natively when we update the file.
# To be safe, we just send a signal if qdbus is installed
subprocess.run(["dbus-send", "--type=method_call", "--dest=org.qt5ct.qt5ct", "/", "org.qt5ct.qt5ct.reload"], capture_output=True)
subprocess.run(["dbus-send", "--type=method_call", "--dest=org.qt6ct.qt6ct", "/", "org.qt6ct.qt6ct.reload"], capture_output=True)

