#!/bin/bash
pkill -f "quickshell -c tact"
pkill -f "quickshell -c new"
sleep 0.1
quickshell -c new
