pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "themes"
import "../Settings/Models"

// ─────────────────────────────────────────────────────────────────────────
// ThemeManager — the single source of truth for all colors in quickshell.
//
// Every module imports this singleton and binds to its color properties.
// When setTheme(name) is called the properties update and all bindings
// across every window repaint instantly via Qt's Behavior on color.
//
// Persistence: theme name is saved to
//   ~/.config/quickshell/colors/theme.json
// ─────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    // ── Active theme name ──────────────────────────────────────────
    property string activeTheme: "Sepia"

    // ── Dynamic Inversion Logic ────────────────────────────────────
    property bool isThemeLight: {
        if (!_t) return false;
        var c = _t.bg;
        var lum = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
        return lum > 0.5;
    }

    property bool wantsLight: SettingsManager.store.themeMode === "Light"
    property bool shouldInvert: isThemeLight !== wantsLight

    function invertColor(c) {
        return Qt.hsla(c.hslHue, c.hslSaturation, 1.0 - c.hslLightness, c.a);
    }

    function applyColor(c, a, invert) {
        var col = invert ? invertColor(c) : c;
        if (a !== undefined) {
            return Qt.rgba(col.r, col.g, col.b, a);
        }
        return col;
    }

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    // ── Public color tokens (with animated transitions) ────────────
    // Surface hierarchy
    property color bg:              applyColor(_t.bg, SettingsManager.store.transparency / 100, shouldInvert)
    property color surface:         applyColor(_t.surface, SettingsManager.store.transparency / 100, shouldInvert)
    property color surfaceHigh:     applyColor(_t.surfaceHigh, SettingsManager.store.transparency / 100, shouldInvert)
    property color surfaceTop:      applyColor(_t.surfaceTop, SettingsManager.store.transparency / 100, shouldInvert)

    // Accents
    property color accent:          applyColor(_t.accent, undefined, shouldInvert)
    property color accentSoft:      applyColor(_t.accentSoft, undefined, shouldInvert)
    property color border:          applyColor(_t.border, undefined, shouldInvert)
    property color accentDim:       applyColor(_t.accentDim, undefined, shouldInvert)

    // Text
    property color fg:              applyColor(_t.fg, undefined, shouldInvert)
    property color fgMid:           applyColor(_t.fgMid, undefined, shouldInvert)
    property color fgDim:           applyColor(_t.fgDim, undefined, shouldInvert)
    property color fgInverted:      applyColor(_t.fgInverted, undefined, shouldInvert)

    // Semantic
    property color error:           applyColor(_t.error, undefined, shouldInvert)
    property color errorText:       applyColor(_t.errorText, undefined, shouldInvert)
    property color errorSoft:       applyColor(_t.errorSoft, undefined, shouldInvert)
    property color warning:         applyColor(_t.warning, undefined, shouldInvert)
    property color success:         applyColor(_t.success, undefined, shouldInvert)

    // Lockscreen Material 3 tokens
    property color seed:                    applyColor(_t.seed, undefined, shouldInvert)
    property color primary:                 applyColor(_t.primary, undefined, shouldInvert)
    property color primaryFg:               applyColor(_t.primaryFg, undefined, shouldInvert)
    property color primaryContainer:        applyColor(_t.primaryContainer, undefined, shouldInvert)
    property color primaryContainerFg:      applyColor(_t.primaryContainerFg, undefined, shouldInvert)
    property color secondary:               applyColor(_t.secondary, undefined, shouldInvert)
    property color secondaryFg:             applyColor(_t.secondaryFg, undefined, shouldInvert)
    property color secondaryContainer:      applyColor(_t.secondaryContainer, undefined, shouldInvert)
    property color secondaryContainerFg:    applyColor(_t.secondaryContainerFg, undefined, shouldInvert)
    property color tertiary:                applyColor(_t.tertiary, undefined, shouldInvert)
    property color tertiaryFg:              applyColor(_t.tertiaryFg, undefined, shouldInvert)
    property color errorContainer:          applyColor(_t.errorContainer, undefined, shouldInvert)
    property color errorContainerFg:        applyColor(_t.errorContainerFg, undefined, shouldInvert)
    property color errorFg:                 applyColor(_t.errorFg, undefined, shouldInvert)
    property color surfaceDim:              applyColor(_t.surfaceDim, undefined, shouldInvert)
    property color surfaceBright:           applyColor(_t.surfaceBright, undefined, shouldInvert)
    property color surfaceContainerLowest:  applyColor(_t.surfaceContainerLowest, undefined, shouldInvert)
    property color surfaceContainerLow:     applyColor(_t.surfaceContainerLow, undefined, shouldInvert)
    property color surfaceContainer:        applyColor(_t.surfaceContainer, undefined, shouldInvert)
    property color surfaceContainerHigh:    applyColor(_t.surfaceContainerHigh, undefined, shouldInvert)
    property color surfaceContainerHighest: applyColor(_t.surfaceContainerHighest, undefined, shouldInvert)
    property color surfaceFg:               applyColor(_t.surfaceFg, undefined, shouldInvert)
    property color surfaceVariantFg:        applyColor(_t.surfaceVariantFg, undefined, shouldInvert)
    property color outline:                 applyColor(_t.outline, undefined, shouldInvert)
    property color outlineVariant:          applyColor(_t.outlineVariant, undefined, shouldInvert)
    property color scrimTop:                applyColor(_t.scrimTop, undefined, shouldInvert)
    property color scrimBottom:             applyColor(_t.scrimBottom, undefined, shouldInvert)
    property real  scrimOpacity:            _t.scrimOpacity

    // ── Smooth color transitions ───────────────────────────────────
    Behavior on bg              { ColorAnimation { duration: 220 } }
    Behavior on surface         { ColorAnimation { duration: 220 } }
    Behavior on surfaceHigh     { ColorAnimation { duration: 220 } }
    Behavior on surfaceTop      { ColorAnimation { duration: 220 } }
    Behavior on accent          { ColorAnimation { duration: 220 } }
    Behavior on accentSoft      { ColorAnimation { duration: 220 } }
    Behavior on border          { ColorAnimation { duration: 220 } }
    Behavior on accentDim       { ColorAnimation { duration: 220 } }
    Behavior on fg              { ColorAnimation { duration: 220 } }
    Behavior on fgMid           { ColorAnimation { duration: 220 } }
    Behavior on fgDim           { ColorAnimation { duration: 220 } }
    Behavior on fgInverted      { ColorAnimation { duration: 220 } }
    Behavior on error           { ColorAnimation { duration: 220 } }
    Behavior on errorText       { ColorAnimation { duration: 220 } }
    Behavior on errorSoft       { ColorAnimation { duration: 220 } }
    Behavior on warning         { ColorAnimation { duration: 220 } }
    Behavior on success         { ColorAnimation { duration: 220 } }
    Behavior on primary         { ColorAnimation { duration: 220 } }
    Behavior on primaryContainer    { ColorAnimation { duration: 220 } }
    Behavior on surfaceFg           { ColorAnimation { duration: 220 } }
    Behavior on surfaceVariantFg    { ColorAnimation { duration: 220 } }
    Behavior on surfaceContainer    { ColorAnimation { duration: 220 } }
    Behavior on surfaceContainerHigh    { ColorAnimation { duration: 220 } }
    Behavior on surfaceContainerHighest { ColorAnimation { duration: 220 } }
    Behavior on surfaceContainerLowest  { ColorAnimation { duration: 220 } }
    Behavior on outline         { ColorAnimation { duration: 220 } }
    Behavior on outlineVariant  { ColorAnimation { duration: 220 } }
    Behavior on tertiary        { ColorAnimation { duration: 220 } }
    Behavior on errorContainer  { ColorAnimation { duration: 220 } }

    // ── Private: current theme data object ─────────────────────────
    property var _t: Sepia {}

    // ── Theme switch ───────────────────────────────────────────────
    function setTheme(name, force) {
        if (name === activeTheme && !force) return
        var url = "themes/" + name + ".qml"
        if (force) {
            url = "file://" + Quickshell.env("HOME") + "/.config/quickshell/colors/themes/" + name + ".qml?v=" + Date.now()
        }
        var comp = Qt.createComponent(url)
        if (comp.status !== Component.Ready) {
            console.warn("ThemeManager: cannot load theme '" + name + "': " + comp.errorString())
            return
        }
        var obj = comp.createObject(root)
        if (!obj) {
            console.warn("ThemeManager: createObject failed for theme '" + name + "'")
            return
        }
        if (_t && _t.destroy) {
            _t.destroy()
        }
        _t = obj
        activeTheme = name
        _save()
    }

    // ── Persistence ────────────────────────────────────────────────
    readonly property string _statePath: Quickshell.env("HOME") + "/.config/quickshell/colors/theme.json"

    function _save() {
        saveProc.exec(["sh", "-c",
            "printf '%s' " + JSON.stringify(JSON.stringify({ theme: activeTheme })) +
            " > " + JSON.stringify(_statePath) + " && python3 ~/.config/quickshell/colors/update_kitty_theme.py && python3 ~/.config/quickshell/colors/apply_system_theme.py && hyprctl reload"
        ])
    }

    Process {
        id: loadProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var obj = JSON.parse(this.text.trim())
                    if (obj && obj.theme && obj.theme !== root.activeTheme) {
                        root.setTheme(obj.theme)
                    }
                } catch(e) {}
            }
        }
    }

    Process { id: saveProc }

    Component.onCompleted: {
        loadProc.exec(["sh", "-c", "cat " + JSON.stringify(_statePath) + " 2>/dev/null || echo '{}'"])
    }
}
