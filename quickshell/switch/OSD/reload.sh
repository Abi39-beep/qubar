#!/bin/bash
pkill -f "quickshell -c qubar"
pkill -f "quickshell -c new"
pkill -f "quickshell -c tact"
pkill -f "quickshell -c OSD"
sleep 0.1
quickshell -c OSD &
