@echo off
REM Opens the NanoDrop volume planner in your default browser.
REM Keep this file in the same folder as nanodrop-volume-planner.html.
REM For a desktop icon: right-click this file - Send to - Desktop (create shortcut).
if not exist "%~dp0nanodrop-volume-planner.html" (
    echo nanodrop-volume-planner.html is not next to this file.
    pause
    exit /b 1
)
start "" "%~dp0nanodrop-volume-planner.html"
