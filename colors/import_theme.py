#!/usr/bin/env python3
import sys
import os
import shutil
import re

def to_camel_case(text):
    s = re.sub(r"(_|-)+", " ", text).title().replace(" ", "")
    return ''.join([s[0].upper(), s[1:]]) if s else ""

def parse_color_file(filepath):
    colors = {}
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            # match `key = "value"` or `key="value"`
            m = re.match(r'^([a-zA-Z0-9_]+)\s*=\s*["\']?([^"\']+)["\']?', line)
            if m:
                colors[m.group(1)] = m.group(2)
    return colors

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    if len(hex_str) == 3:
        hex_str = ''.join(c + c for c in hex_str)
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return '#{:02x}{:02x}{:02x}'.format(*rgb)

def mix_colors(hex1, hex2, ratio=0.5):
    try:
        rgb1 = hex_to_rgb(hex1)
        rgb2 = hex_to_rgb(hex2)
        mixed = tuple(int(rgb1[i] * (1 - ratio) + rgb2[i] * ratio) for i in range(3))
        return rgb_to_hex(mixed)
    except:
        return hex1

def map_to_theme(colors):
    # Base fallback mapping
    bg = colors.get('background', colors.get('color0', '#1c1c1c'))
    fg = colors.get('foreground', colors.get('color15', '#ffffff'))
    accent = colors.get('accent', colors.get('color4', '#888888')) # blue/accent fallback
    
    # Calculate surfaces to ensure they don't clash with dim text
    surface = mix_colors(bg, fg, 0.04)
    surfaceHigh = mix_colors(bg, fg, 0.08)
    surfaceTop = mix_colors(bg, fg, 0.12)
    border = mix_colors(bg, fg, 0.15)
    
    # Text
    fgMid = colors.get('color7', mix_colors(fg, bg, 0.3))
    fgDim = colors.get('color8', mix_colors(fg, bg, 0.5))
    
    # Try to build the Quickshell Theme format
    theme_data = f"""import QtQuick

QtObject {{
    property string name: "Custom Theme"

    readonly property color bg:              "{bg}"
    readonly property color surface:         "{surface}"
    readonly property color surfaceHigh:     "{surfaceHigh}"
    readonly property color surfaceTop:      "{surfaceTop}"
    
    readonly property color accent:          "{accent}"
    readonly property color accentSoft:      "{colors.get('color12', accent)}"
    readonly property color border:          "{border}"
    readonly property color accentDim:       "{colors.get('color4', accent)}"

    readonly property color fg:              "{fg}"
    readonly property color fgMid:           "{fgMid}"
    readonly property color fgDim:           "{fgDim}"
    readonly property color fgInverted:      "{colors.get('background', '#000000')}"

    readonly property color error:           "{colors.get('color1', '#ff0000')}"
    readonly property color errorText:       "{colors.get('color9', '#ff0000')}"
    readonly property color errorSoft:       "{colors.get('color1', '#ff0000')}"
    readonly property color warning:         "{colors.get('color3', '#ffaa00')}"
    readonly property color success:         "{colors.get('color2', '#00ff00')}"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "{accent}"
    readonly property color primary: "{accent}"
    readonly property color primaryFg: "{bg}"
    readonly property color primaryContainer: "{colors.get('color4', accent)}"
    readonly property color primaryContainerFg: "{fg}"
    readonly property color secondary: "{colors.get('color6', accent)}"
    readonly property color secondaryFg: "{bg}"
    readonly property color secondaryContainer: "{colors.get('color14', accent)}"
    readonly property color secondaryContainerFg: "{fg}"
    readonly property color tertiary: "{colors.get('color5', accent)}"
    readonly property color tertiaryFg: "{bg}"
    readonly property color errorContainer: "{colors.get('color1', '#ff0000')}"
    readonly property color errorContainerFg: "{fg}"
    readonly property color errorFg: "{bg}"
    
    readonly property color surfaceDim: "{bg}"
    readonly property color surfaceBright: "{surfaceHigh}"
    readonly property color surfaceContainerLowest: "{bg}"
    readonly property color surfaceContainerLow: "{bg}"
    readonly property color surfaceContainer: "{surface}"
    readonly property color surfaceContainerHigh: "{surfaceHigh}"
    readonly property color surfaceContainerHighest: "{surfaceTop}"
    readonly property color surfaceFg: "{fg}"
    readonly property color surfaceVariantFg: "{fgMid}"
    readonly property color outline: "{border}"
    readonly property color outlineVariant: "{mix_colors(border, bg, 0.5)}"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}}
"""
    return theme_data

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("ERROR: No file provided")
        sys.exit(1)
        
    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"ERROR: File not found: {filepath}")
        sys.exit(1)
        
    filename = os.path.basename(filepath)
    name_no_ext = os.path.splitext(filename)[0]
    theme_name = to_camel_case(name_no_ext)
    
    # Target directories
    home = os.environ.get('HOME', '/home/grey')
    themes_dir = os.path.join(home, '.config/quickshell/colors/themes')
        
    colors = parse_color_file(filepath)
    qml_content = map_to_theme(colors)
    
    out_qml = os.path.join(themes_dir, f"{theme_name}.qml")
    with open(out_qml, 'w') as f:
        f.write(qml_content)
        
    print(f"SUCCESS: {theme_name}")
