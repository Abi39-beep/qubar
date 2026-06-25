#!/bin/bash
pkill -f "quickshell -c OSD"
sleep 0.1
quickshell -c OSD &
