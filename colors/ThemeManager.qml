pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "themes"

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

    // ── Convenience function ───────────────────────────────────────
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    // ── Public color tokens (with animated transitions) ────────────
    // Surface hierarchy
    property color bg:              _t.bg
    property color surface:         _t.surface
    property color surfaceHigh:     _t.surfaceHigh
    property color surfaceTop:      _t.surfaceTop

    // Accents
    property color accent:          _t.accent
    property color accentSoft:      _t.accentSoft
    property color border:          _t.border
    property color accentDim:       _t.accentDim

    // Text
    property color fg:              _t.fg
    property color fgMid:           _t.fgMid
    property color fgDim:           _t.fgDim
    property color fgInverted:      _t.fgInverted

    // Semantic
    property color error:           _t.error
    property color errorText:       _t.errorText
    property color errorSoft:       _t.errorSoft
    property color warning:         _t.warning
    property color success:         _t.success

    // Lockscreen Material 3 tokens
    property color seed:                    _t.seed
    property color primary:                 _t.primary
    property color primaryFg:               _t.primaryFg
    property color primaryContainer:        _t.primaryContainer
    property color primaryContainerFg:      _t.primaryContainerFg
    property color secondary:               _t.secondary
    property color secondaryFg:             _t.secondaryFg
    property color secondaryContainer:      _t.secondaryContainer
    property color secondaryContainerFg:    _t.secondaryContainerFg
    property color tertiary:                _t.tertiary
    property color tertiaryFg:              _t.tertiaryFg
    property color errorContainer:          _t.errorContainer
    property color errorContainerFg:        _t.errorContainerFg
    property color errorFg:                 _t.errorFg
    property color surfaceDim:              _t.surfaceDim
    property color surfaceBright:           _t.surfaceBright
    property color surfaceContainerLowest:  _t.surfaceContainerLowest
    property color surfaceContainerLow:     _t.surfaceContainerLow
    property color surfaceContainer:        _t.surfaceContainer
    property color surfaceContainerHigh:    _t.surfaceContainerHigh
    property color surfaceContainerHighest: _t.surfaceContainerHighest
    property color surfaceFg:               _t.surfaceFg
    property color surfaceVariantFg:        _t.surfaceVariantFg
    property color outline:                 _t.outline
    property color outlineVariant:          _t.outlineVariant
    property color scrimTop:                _t.scrimTop
    property color scrimBottom:             _t.scrimBottom
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
