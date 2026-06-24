import json
import re
import os
import subprocess

def get_hex_from_qml(content, var_name):
    m = re.search(r'property color ' + var_name + r'\s*:\s*"#([0-9a-fA-F]+)"', content)
    if m:
        hex_val = m.group(1)
        if len(hex_val) == 8:
            return '#' + hex_val[:6] # drop alpha for cava/kitty
        return '#' + hex_val
    return None

try:
    with open(os.path.expanduser('~/.config/quickshell/colors/theme.json'), 'r') as f:
        theme_info = json.load(f)
        theme_name = theme_info.get('theme', 'Sepia')
except Exception:
    theme_name = 'Sepia'

qml_path = os.path.expanduser(f'~/.config/quickshell/colors/themes/{theme_name}.qml')
bg_color, fg_color, accent_color = '#1e1e2e', '#cdd6f4', '#89b4fa'

try:
    with open(qml_path, 'r') as f:
        content = f.read()
        bg_color = get_hex_from_qml(content, 'bg') or bg_color
        fg_color = get_hex_from_qml(content, 'fg') or fg_color
        accent_color = get_hex_from_qml(content, 'accent') or accent_color
except Exception:
    pass

# Update Kitty
kitty_conf = os.path.expanduser('~/.config/kitty/quickshell-theme.conf')
with open(kitty_conf, 'w') as f:
    f.write(f"background {bg_color}\nforeground {fg_color}\nselection_background {accent_color}\n")

# Update Cava
cava_conf = os.path.expanduser('~/.config/cava/config')
if os.path.exists(cava_conf):
    with open(cava_conf, 'r') as f:
        cava_lines = f.readlines()
    
    with open(cava_conf, 'w') as f:
        for line in cava_lines:
            if line.startswith('foreground =') or line.startswith('; foreground ='):
                f.write(f"foreground = '{accent_color}'\n")
            elif line.startswith('background =') or line.startswith('; background ='):
                f.write(f"background = '{bg_color}'\n")
            else:
                f.write(line)
    
    subprocess.run(['killall', '-USR1', 'cava'], stderr=subprocess.DEVNULL)

subprocess.run(['killall', '-USR1', 'kitty'], stderr=subprocess.DEVNULL)
