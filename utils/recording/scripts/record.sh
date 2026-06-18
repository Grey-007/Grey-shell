#!/bin/bash
# record.sh
# Handles screen recording via wf-recorder

pidfile="/tmp/quickshell_wf_recorder.pid"

# If recording is running, stop it
if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile")
    if kill -0 "$pid" 2>/dev/null; then
        kill -INT "$pid"
        rm "$pidfile"
        notify-send -t 3000 "Recording Stopped" "Video saved to ~/Videos"
        exit 0
    else
        rm "$pidfile"
    fi
fi

if [ -z "$1" ]; then
    exit 0
fi

# Make sure Videos dir exists
mkdir -p ~/Videos
filename=~/Videos/recording_$(date +"%Y-%m-%d_%H-%M-%S").mp4

case "$1" in
    "output")
        wf-recorder -f "$filename" &
        echo $! > "$pidfile"
        notify-send -t 3000 "Recording Started" "Fullscreen capture initiated."
        ;;
    "region")
        geometry=$(slurp)
        if [ -n "$geometry" ]; then
            wf-recorder -g "$geometry" -f "$filename" &
            echo $! > "$pidfile"
            notify-send -t 3000 "Recording Started" "Region capture initiated."
        fi
        ;;
    "window")
        geometry=$(hyprctl clients -j | jq -r '.[] | select(.hidden==false and .mapped==true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)
        if [ -n "$geometry" ]; then
            wf-recorder -g "$geometry" -f "$filename" &
            echo $! > "$pidfile"
            notify-send -t 3000 "Recording Started" "Window capture initiated."
        fi
        ;;
esac
