#!/bin/bash
pkill -f "quickshell -c qubar"
sleep 0.1
quickshell -c qubar &
