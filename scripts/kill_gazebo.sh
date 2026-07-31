#!/usr/bin/env bash
# Force-kill any stale Gazebo Harmonic (gz sim) processes.
# Run this before relaunching a simulation session if you see duplicate
# publishers on /clock, /odom, or /cmd_vel.

set -euo pipefail

echo "Looking for running 'gz sim' processes..."
if pgrep -f "gz sim" > /dev/null; then
    echo "Found stale processes, killing them:"
    pgrep -af "gz sim"
    pkill -9 -f "gz sim"
    echo "Done."
else
    echo "No stale 'gz sim' processes found."
fi

