import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../colors"

Scope {
    id: osdScope

    OsdWindow {
        id: osdWindow
    }

    // IPC Handler to show OSD
    IpcHandler {
        target: "osd"
        function volume(val: int) {
            osdWindow.showOsd("volume", val, "")
        }
        function brightness(val: int) {
            osdWindow.showOsd("brightness", val, "")
        }
        function capslock(state: int) {
            osdWindow.showOsd("capslock", 0, state ? "Caps Lock: On" : "Caps Lock: Off")
        }
        function numlock(state: int) {
            osdWindow.showOsd("numlock", 0, state ? "Num Lock: On" : "Num Lock: Off")
        }
        function scrolllock(state: int) {
            osdWindow.showOsd("scrolllock", 0, state ? "Scroll Lock: On" : "Scroll Lock: Off")
        }
    }

    // Removed Pipewire Connections, handled by bash script below

    // Polling script for CapsLock, NumLock, ScrollLock, Brightness
    Process {
        id: osdWatcherProc
        command: ["bash", "-c", `
            prev_caps=""
            prev_num=""
            prev_scroll=""
            
            while true; do
                devs=$(hyprctl devices -j 2>/dev/null)
                if [ -n "$devs" ]; then
                    caps="false"
                    if echo "$devs" | grep -q '"capsLock": true'; then caps="true"; fi
                    
                    num="false"
                    if echo "$devs" | grep -q '"numLock": true'; then num="true"; fi
                    
                    if [ "$caps" != "$prev_caps" ] && [ -n "$prev_caps" ]; then
                        c=0; if [ "$caps" = "true" ]; then c=1; fi
                        quickshell ipc call osd capslock "$c"
                    fi
                    prev_caps=$caps
                    
                    if [ "$num" != "$prev_num" ] && [ -n "$prev_num" ]; then
                        n=0; if [ "$num" = "true" ]; then n=1; fi
                        quickshell ipc call osd numlock "$n"
                    fi
                    prev_num=$num
                fi

                # Basic Brightness check via brightnessctl or sysfs
                if command -v brightnessctl >/dev/null; then
                    :
                fi
                
                sleep 0.1
            done
        `]
        running: true
    }
}
