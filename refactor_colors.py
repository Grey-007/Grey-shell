import os
import re

def replace_in_file(filepath, replacements, import_statement):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        content = f.read()

    # add import after the last import
    if import_statement not in content:
        lines = content.split('\n')
        last_import = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i
        lines.insert(last_import + 1, import_statement)
        content = '\n'.join(lines)

    # remove inline palette definitions
    content = re.sub(r'readonly property color.*?\n', '', content)

    for old, new in replacements.items():
        if re.match(r'^[A-Za-z0-9_]+$', old):
            # Only alphanumeric, use word boundaries
            content = re.sub(r'\b' + re.escape(old) + r'\b', new, content)
        else:
            content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

# Bar
bar_files = {
    'Bar.qml': {'bar.bgRaised': 'ThemeManager.surfaceHigh', 'bar.bgInset': 'ThemeManager.surface', 'bar.bg': 'ThemeManager.bg', 'bar.accentSoft': 'ThemeManager.accentSoft', 'bar.accent': 'ThemeManager.accent', 'bar.fg': 'ThemeManager.fg', 'bar.muted': 'ThemeManager.fgMid', 'bar.border': 'ThemeManager.accentSoft', '"#ffffff"': 'ThemeManager.fgInverted'},
    'modules/calendar/CalendarPopup.qml': {'sepiaBase': 'ThemeManager.bg', 'sepiaSurface': 'ThemeManager.surface', 'sepiaPanel': 'ThemeManager.surfaceHigh', 'sepiaBorder': 'ThemeManager.accentSoft', 'sepiaAccent': 'ThemeManager.accent', 'sepiaText': 'ThemeManager.fg', 'sepiaMuted': 'ThemeManager.fgMid', 'sepiaDim': 'ThemeManager.accentDim', 'sepiaTodayFg': 'ThemeManager.fgInverted', 'sepiaToday': 'ThemeManager.accent', 'sepiaHover': 'ThemeManager.surfaceTop'},
    'modules/clock/Clock.qml': {'"#f0e0c0"': 'ThemeManager.fg', '"#d4a45a"': 'ThemeManager.accent', '"#8a7055"': 'ThemeManager.fgMid'},
    'modules/metrics/Battery.qml': {'"#e87a52"': 'ThemeManager.warning', '"#d4a45a"': 'ThemeManager.accent'},
    'modules/metrics/MetricBar.qml': {'"#d4a45a"': 'ThemeManager.accent', '"#2C241D"': 'ThemeManager.surfaceHigh', 'Qt.rgba(0.83, 0.64, 0.35, 0.15)': 'ThemeManager.alpha(ThemeManager.accent, 0.15)', '"#5a4030"': 'ThemeManager.fgDim', '"#e87a52"': 'ThemeManager.warning'},
    'modules/metrics/SystemPopup.qml': {'bg': 'ThemeManager.bg', 'surface': 'ThemeManager.surfaceHigh', 'accent': 'ThemeManager.accent', 'fg': 'ThemeManager.fg', 'muted': 'ThemeManager.fgMid', 'border_c': 'ThemeManager.accentSoft', '"#e87a52"': 'ThemeManager.warning', '#e87a52': 'ThemeManager.warning'},
    'modules/tray/Tray.qml': {'"#d4a45a"': 'ThemeManager.accent'},
    'modules/workspaces/Workspaces.qml': {'accent': 'ThemeManager.accent', 'activeInk': 'ThemeManager.fgInverted', 'inactiveInk': 'ThemeManager.fgMid', 'emptyInk': 'ThemeManager.fgDim', '"#1c1510"': 'ThemeManager.fgInverted', '"#c8a87a"': 'ThemeManager.fgMid', '"#5a4030"': 'ThemeManager.fgDim', '"#d4a45a"': 'ThemeManager.accent'}
}

# Control Centre
cc_files = {
    'ControlCentreCard.qml': {'sp_bg': 'ThemeManager.bg', 'sp_surfaceTop': 'ThemeManager.surfaceTop', 'sp_surfaceHigh': 'ThemeManager.surfaceHigh', 'sp_surface': 'ThemeManager.surface', 'sp_onPrimary': 'ThemeManager.fgInverted', 'sp_primary': 'ThemeManager.accent', 'sp_textMuted': 'ThemeManager.fgMid', 'sp_text': 'ThemeManager.fg', 'sp_border': 'ThemeManager.border', 'sp_errorText': 'ThemeManager.errorText'},
    'AndroidSlider.qml': {'sp_trackBg': 'ThemeManager.surfaceTop', 'sp_trackFill': 'ThemeManager.accent', 'sp_thumb': 'ThemeManager.fg', 'sp_labelDim': 'ThemeManager.fgMid', 'sp_label': 'ThemeManager.accent', '"#3A2E26"': 'ThemeManager.surfaceTop', '"#A67C52"': 'ThemeManager.accent', '"#F2E0C8"': 'ThemeManager.fg', '"#8C6F56"': 'ThemeManager.fgMid', '"#30A67C52"': 'ThemeManager.alpha(ThemeManager.accent, 0.19)'},
    'DeviceRow.qml': {'bgOff': 'ThemeManager.surfaceHigh', 'bgOn': 'ThemeManager.surfaceTop', 'chipBgOn': 'ThemeManager.accent', 'chipBgOff': 'ThemeManager.bg', 'chipTxtOn': 'ThemeManager.fgInverted', 'chipTxtOff': 'ThemeManager.accent', 'primary': 'ThemeManager.accent', 'onSurfV': 'ThemeManager.fgMid', 'onSurf': 'ThemeManager.fg', '"#2C241D"': 'ThemeManager.surfaceHigh', '"#3A2E26"': 'ThemeManager.surfaceTop', '"#A67C52"': 'ThemeManager.accent', '"#1A1410"': 'ThemeManager.bg', '"#F2E0C8"': 'ThemeManager.fg', '"#8C6F56"': 'ThemeManager.fgMid'},
    'MenuPanel.qml': {'surface': 'ThemeManager.surface', 'errorColor': 'ThemeManager.errorText', 'borderCol': 'ThemeManager.border', 'onSurfV': 'ThemeManager.fgMid', 'onSurf': 'ThemeManager.fg', '"#241D18"': 'ThemeManager.surface', '"#E8906A"': 'ThemeManager.errorText', '"#5A4736"': 'ThemeManager.border', '"#8C6F56"': 'ThemeManager.fgMid', '"#F2E0C8"': 'ThemeManager.fg'},
    'NotificationToasts.qml': {'surface': 'ThemeManager.surface', 'primary': 'ThemeManager.accent', 'onSurfV': 'ThemeManager.fgMid', 'onSurf': 'ThemeManager.fg', 'border': 'ThemeManager.border', '"#241D18"': 'ThemeManager.surface', '"#A67C52"': 'ThemeManager.accent', '"#8C6F56"': 'ThemeManager.fgMid', '"#F2E0C8"': 'ThemeManager.fg', '"#5A4736"': 'ThemeManager.border'},
    'PillButton.qml': {'bgExpanded': 'ThemeManager.surfaceTop', 'bgOff': 'ThemeManager.surfaceHigh', 'bgOn': 'ThemeManager.accent', 'iconBgOff': 'ThemeManager.bg', 'iconBgOn': 'ThemeManager.accentSoft', 'iconColorOff': 'ThemeManager.fgMid', 'iconColorOn': 'ThemeManager.fg', 'subtitleOn': 'ThemeManager.fgInverted', 'subtitleOff': 'ThemeManager.fgMid', 'titleOn': 'ThemeManager.fgInverted', 'titleOff': 'ThemeManager.fg', 'border': 'ThemeManager.border', '"#3A2E26"': 'ThemeManager.surfaceTop', '"#2C241D"': 'ThemeManager.surfaceHigh', '"#A67C52"': 'ThemeManager.accent', '"#1A1410"': 'ThemeManager.bg', '"#7A5A3A"': 'ThemeManager.accentSoft', '"#8C6F56"': 'ThemeManager.fgMid', '"#F2E0C8"': 'ThemeManager.fg', '"#2C1A0E"': 'ThemeManager.fgInverted', '"#5A4736"': 'ThemeManager.border'},
    'SmallButton.qml': {'bgOff': 'ThemeManager.surfaceTop', 'bgOn': 'ThemeManager.accent', 'textOff': 'ThemeManager.accent', 'textOn': 'ThemeManager.fgInverted', 'border': 'ThemeManager.border', '"#3A2E26"': 'ThemeManager.surfaceTop', '"#A67C52"': 'ThemeManager.accent', '"#1A1410"': 'ThemeManager.fgInverted', '"#5A4736"': 'ThemeManager.border'},
    'NotificationPopupCard.qml': {'sp_bg': 'ThemeManager.bg', 'sp_surfaceTop': 'ThemeManager.surfaceTop', 'sp_surfaceHigh': 'ThemeManager.surfaceHigh', 'sp_surface': 'ThemeManager.surface', 'sp_onPrimary': 'ThemeManager.fgInverted', 'sp_primary': 'ThemeManager.accent', 'sp_textMuted': 'ThemeManager.fgMid', 'sp_text': 'ThemeManager.fg', 'sp_border': 'ThemeManager.border', 'sp_errorText': 'ThemeManager.errorText'}
}

# Others
other_files = {
    'launcher/Launcher.qml': {'root.creamDark': 'ThemeManager.surfaceHigh', 'root.cream': 'ThemeManager.bg', 'root.border': 'ThemeManager.accentSoft', 'root.fgMid': 'ThemeManager.fgMid', 'root.fg': 'ThemeManager.fg', 'root.fillColor': 'ThemeManager.accent', 'root.fillText': 'ThemeManager.fgInverted', '"#55000000"': 'ThemeManager.alpha(ThemeManager.bg, 0.33)'},
    'powermenu/PowerMenu.qml': {'"#2e2118"': 'ThemeManager.surfaceHigh', '"#a0784a"': 'ThemeManager.accentSoft', '"#d4a45a"': 'ThemeManager.accent', '"#1c1510"': 'ThemeManager.bg', '"#f0e0c0"': 'ThemeManager.fg'},
    'mediadeck/MediaDeck.qml': {'"#241D18"': 'ThemeManager.surface', '"#5A4736"': 'ThemeManager.border'},
    'mediadeck/views/CompactView.qml': {'"#A67C52"': 'ThemeManager.accent', '"#F2E0C8"': 'ThemeManager.fg'},
    'mediadeck/views/ExpandedView.qml': {'"#3A2E26"': 'ThemeManager.surfaceTop', '"#A67C52"': 'ThemeManager.accent', '"#5A4736"': 'ThemeManager.border', '"#8C6F56"': 'ThemeManager.fgMid', '"#F2E0C8"': 'ThemeManager.fg'},
    'utils/clipboard/ClipboardManager.qml': {'"#241D18"': 'ThemeManager.surface', '"#5A4736"': 'ThemeManager.border', '"#a0784a"': 'ThemeManager.accentSoft', '"#d4a45a"': 'ThemeManager.accent', '"#f0e0c0"': 'ThemeManager.fg'},
    'utils/recording/RecordingPill.qml': {'"#241D18"': 'ThemeManager.surface', '"#5A4736"': 'ThemeManager.border', '"#e04a4a"': 'ThemeManager.error', '"#f0e0c0"': 'ThemeManager.fg', '"#a04a4a"': 'ThemeManager.errorSoft', '"#1c1510"': 'ThemeManager.fgInverted', '"#d45a5a"': 'ThemeManager.errorText'},
    'wallpaper/components/ConfigPanel.qml': {'"#241D18"': 'ThemeManager.surface', '"#5A4736"': 'ThemeManager.border', '"#F2E0C8"': 'ThemeManager.fg', '"#A67C52"': 'ThemeManager.accent'},
    'wallpaper/components/FilmStrip.qml': {'"#241D18"': 'ThemeManager.surface', '"#5A4736"': 'ThemeManager.border'},
    'wallpaper/components/SearchBar.qml': {'"#241D18"': 'ThemeManager.surface', '"#A67C52"': 'ThemeManager.accent', '"#5A4736"': 'ThemeManager.border', '"#F2E0C8"': 'ThemeManager.fg'}
}

base_path = '/home/grey/.config/quickshell/'

for f, reps in bar_files.items():
    p = base_path + 'Bar/' + f
    import_stmt = 'import "../colors"' if f == 'Bar.qml' else 'import "../../../colors"'
    replace_in_file(p, reps, import_stmt)

for f, reps in cc_files.items():
    p = base_path + 'ControlCentre/' + f
    replace_in_file(p, reps, 'import "../colors"')

for f, reps in other_files.items():
    p = base_path + f
    import_stmt = 'import "../colors"'
    if 'views' in f or 'clipboard' in f or 'recording' in f or 'components' in f:
        import_stmt = 'import "../../colors"'
    replace_in_file(p, reps, import_stmt)

