# Robotics Hackathon — ROS 2 Jazzy / Gazebo Harmonic Pipeline

Repository tracking progress on the qualifying tasks (Task 1 & Task 2) and the
Final Round 3D LiDAR shelter-damage inspection challenge.

## Environment

| Component | Version / Detail |
|---|---|
| OS | Ubuntu 24.04 LTS (Noble), running under **WSL2** |
| ROS 2 distro | **Jazzy Jalisco** |
| Simulator | **Gazebo Harmonic** (via `ros_gz`) |
| Nav stack | Nav2 + SLAM Toolbox |
| Robot | TurtleBot3 (burger), built from source, `jazzy` branch |
| GPU | Integrated graphics only — confirmed software rendering (`llvmpipe`), no discrete GPU passthrough |

**Why this matters:** WSL2 + `llvmpipe` cannot reliably drive the Gazebo GUI —
render lag causes flicker and dropped frames during teleop, which risks corrupting
SLAM scan-matching. The working setup for this environment is **headless Gazebo
server (`gz sim -s` / `headless:=True`) + RViz2** for visualization. This is the
permanent approach going forward, not a workaround for one session.
## TurtleBot3 dependency (not vendored — pinned via vcstool)

This repo does not include the ROBOTIS turtlebot3 packages directly.
To pull them in:

    sudo apt install python3-vcstool   # if not already installed
    mkdir -p ~/turtlebot3_ws/src
    vcs import ~/turtlebot3_ws/src < deps/turtlebot3.repos
    cd ~/turtlebot3_ws
    rosdep install --from-paths src --ignore-src -r -y
    colcon build
    source install/setup.bash
## Status

### ✅ Done
- [x] Base system + ROS 2 Jazzy install, resolved duplicate `ros2.list` apt source conflict
- [x] `rosdep` installed and initialized (`python3-rosdep` was missing initially)
- [x] Nav2 / SLAM Toolbox / teleop packages installed
- [x] TurtleBot3 built from source on the `jazzy` branch (apt packages don't exist for Jazzy yet)
- [x] Gazebo Harmonic simulation launches, TurtleBot3 spawns correctly
- [x] Teleop drives the robot correctly (`teleop_twist_keyboard` fixed to publish `TwistStamped` via `stamped:=true`, matching what `ros_gz_bridge` expects)
- [x] Identified and fixed stale `gz sim` processes causing duplicate publishers on `/clock`, `/odom`, `/cmd_vel`

### 🚧 In progress (active blocker)
- [ ] **Headless-mode transition** — switching from GUI Gazebo to `gz sim -s` (server-only) + RViz2 as the standard visualization path. Not yet fully validated end-to-end.

### ⏭️ Not started (blocked on the above)
- [ ] SLAM mapping (Step 7) run to completion in headless mode, map saved
- [ ] Nav2 bringup validated against the saved map
- [ ] Task 2: waypoint loop navigation (`turtlebot3_waypoint_nav` package — currently targets Humble, needs Jazzy adaptation)
- [ ] Final Round: 3D LiDAR shelter-damage inspection pipeline (deferred)

## Repo layout
.
├── README.md
├── docs/
│ ├── implementation_guide.md
│ └── troubleshooting_log.md
├── scripts/
│ ├── kill_gazebo.sh
│ └── launch_headless.sh
└── src/
└── turtlebot3_waypoint_nav/
## Quick start (once headless mode is validated)

```bash
# Terminal 1 — headless sim
./scripts/launch_headless.sh

# Terminal 2 — SLAM
ros2 launch slam_toolbox online_async_launch.py use_sim_time:=True

# Terminal 3 — RViz2 for visualization (add Map display on /map)
rviz2

# Terminal 4 — teleop to drive coverage for mapping
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true
```

If you ever see duplicate/garbled `/cmd_vel` or `/odom` behavior, run
`./scripts/kill_gazebo.sh` before relaunching.

## Key learnings

- Ubuntu 24.04 → **Jazzy + Gazebo Harmonic**, not Humble. This affects every
  package source and branch choice (e.g. TurtleBot3 must be built from the
  `jazzy` branch, not installed via apt).
- Don't set `GAZEBO_MODEL_PATH` — that's a Gazebo Classic variable and is
  irrelevant (and can be actively misleading) for `ros_gz`/Harmonic.
- Always `pkill -9 -f "gz sim"` before relaunching a simulation session.
- `teleop_twist_keyboard` needs `--ros-args -p stamped:=true` to publish
  `TwistStamped` when bridged via `ros_gz_bridge`.
