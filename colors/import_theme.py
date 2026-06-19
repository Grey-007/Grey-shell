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

def map_to_theme(colors):
    # Base fallback mapping
    bg = colors.get('background', colors.get('color0', '#1c1c1c'))
    fg = colors.get('foreground', colors.get('color15', '#ffffff'))
    accent = colors.get('accent', colors.get('color4', '#888888')) # blue/accent fallback
    
    # Try to build the Quickshell Theme format
    theme_data = f"""import QtQuick

QtObject {{
    property string name: "Custom Theme"

    property color bg:              "{bg}"
    property color surface:         "{colors.get('color0', bg)}"
    property color surfaceHigh:     "{colors.get('color8', bg)}"
    property color surfaceTop:      "{colors.get('color0', bg)}"
    
    property color accent:          "{accent}"
    property color accentSoft:      "{colors.get('color12', accent)}"
    property color border:          "{colors.get('color8', '#555555')}"
    property color accentDim:       "{colors.get('color4', accent)}"

    property color fg:              "{fg}"
    property color fgMid:           "{colors.get('color7', fg)}"
    property color fgDim:           "{colors.get('color8', fg)}"
    property color fgInverted:      "{colors.get('background', '#000000')}"

    property color error:           "{colors.get('color1', '#ff0000')}"
    property color errorText:       "{colors.get('color9', '#ff0000')}"
    property color errorSoft:       "{colors.get('color1', '#ff0000')}"
    property color warning:         "{colors.get('color3', '#ffaa00')}"
    property color success:         "{colors.get('color2', '#00ff00')}"

    // Material 3 placeholders mapping to base colors
    property color seed: "{accent}"
    property color primary: "{accent}"
    property color primaryFg: "{bg}"
    property color primaryContainer: "{colors.get('color4', accent)}"
    property color primaryContainerFg: "{fg}"
    property color secondary: "{colors.get('color6', accent)}"
    property color secondaryFg: "{bg}"
    property color secondaryContainer: "{colors.get('color14', accent)}"
    property color secondaryContainerFg: "{fg}"
    property color tertiary: "{colors.get('color5', accent)}"
    property color tertiaryFg: "{bg}"
    property color errorContainer: "{colors.get('color1', '#ff0000')}"
    property color errorContainerFg: "{fg}"
    property color errorFg: "{bg}"
    
    property color surfaceDim: "{colors.get('color0', bg)}"
    property color surfaceBright: "{colors.get('color8', bg)}"
    property color surfaceContainerLowest: "{bg}"
    property color surfaceContainerLow: "{bg}"
    property color surfaceContainer: "{colors.get('color0', bg)}"
    property color surfaceContainerHigh: "{colors.get('color8', bg)}"
    property color surfaceContainerHighest: "{colors.get('color8', bg)}"
    property color surfaceFg: "{fg}"
    property color surfaceVariantFg: "{colors.get('color7', fg)}"
    property color outline: "{colors.get('color8', '#555555')}"
    property color outlineVariant: "{colors.get('color8', '#555555')}"
    
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
    raw_dir = os.path.join(home, '.config/quickshell/colors/raw_themes')
    themes_dir = os.path.join(home, '.config/quickshell/colors/themes')
    
    try:
        shutil.copy2(filepath, os.path.join(raw_dir, filename))
    except Exception as e:
        print(f"ERROR: Could not copy raw file: {e}")
        sys.exit(1)
        
    colors = parse_color_file(filepath)
    qml_content = map_to_theme(colors)
    
    out_qml = os.path.join(themes_dir, f"{theme_name}.qml")
    with open(out_qml, 'w') as f:
        f.write(qml_content)
        
    print(f"SUCCESS: {theme_name}")
