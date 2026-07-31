#!/usr/bin/env bash
# Launch the TurtleBot3 Gazebo Harmonic simulation in headless (server-only)
# mode. Use RViz2 in a separate terminal for visualization instead of the
# Gazebo GUI, since WSL2 + integrated graphics (llvmpipe) can't reliably
# drive the Gazebo client window.
#
# Adjust WORLD_LAUNCH / ARGS below to match your actual launch file and
# argument names once the headless transition is validated end-to-end.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Make sure no stale gz sim processes are still running
"$SCRIPT_DIR/kill_gazebo.sh"

# 2. Source the workspace (adjust path if different on your machine)
source /opt/ros/jazzy/setup.bash
source ~/turtlebot3_ws/install/setup.bash

export TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL:-burger}"

# 3. Launch headless.
#    Try the launch-file argument first; if your version of
#    turtlebot3_gazebo doesn't expose headless:=, fall back to
#    `gz sim -s -r <world>.sdf` directly.
echo "Launching turtlebot3_world in headless mode (TURTLEBOT3_MODEL=$TURTLEBOT3_MODEL)..."
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py headless:=True use_sim_time:=True

# --- Alternative (server-only) invocation if the above argument isn't supported:
# gz sim -s -r ~/turtlebot3_ws/src/turtlebot3_simulations/turtlebot3_gazebo/worlds/turtlebot3_world.world
