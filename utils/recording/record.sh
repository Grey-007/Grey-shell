#!/bin/bash
MODE=$1
mkdir -p ~/Videos
FILE="$HOME/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
GEOMETRY=""

if [ "$MODE" = "output" ]; then
    GEOMETRY="output"
elif [ "$MODE" = "region" ]; then
    sleep 0.5
    GEOMETRY=$(slurp 2>/dev/null)
elif [ "$MODE" = "window" ]; then
    sleep 0.5
    GEOMETRY=$(hyprctl clients -j | jq -r '.[] | select(.hidden==false and .mapped==true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp 2>/dev/null)
fi

if [ -n "$GEOMETRY" ]; then
    quickshell ipc call recordingpill showPill
    if [ "$MODE" = "output" ]; then
        wf-recorder -f "$FILE" >/dev/null 2>&1
    else
        wf-recorder -g "$GEOMETRY" -f "$FILE" >/dev/null 2>&1
    fi
    quickshell ipc call recordingpill hidePill
    notify-send -t 3000 "Recording Finished" "Saved to ~/Videos"
fi
