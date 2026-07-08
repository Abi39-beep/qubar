#!/bin/bash
pkill -f "quickshell -c OSD"
pkill -f "quickshell -c qubar"
pkill -f "quickshell -c tact"
pkill -f "quickshell -c new"
sleep 0.1
quickshell -c new
