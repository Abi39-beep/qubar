#!/bin/bash
pkill -f "quickshell -c OSD"
pkill -f "quickshell -c new"
pkill -f "quickshell -c tact"
pkill -f "quickshell -c qubar"
sleep 0.1
quickshell -c qubar &
