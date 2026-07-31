# Troubleshooting Log

Chronological record of issues encountered while working through Task 1 / Task 2,
and how each was resolved. Kept for future-self and for anyone else setting up
the same WSL2 + integrated-GPU environment.

---

### 1. Conflicting apt sources for ROS 2
**Symptom:** `apt update` errors / conflicting package versions from two ROS 2
repo entries.
**Cause:** A manually-created `ros2.list` file existed alongside another ROS 2
source entry, so apt saw the repo listed twice.
**Fix:** Removed the manual `ros2.list` file, kept a single canonical source entry.

---

### 2. `rosdep: command not found`
**Cause:** `python3-rosdep` was not installed as part of the base ROS 2 install.
**Fix:** `sudo apt install -y python3-rosdep`, then `sudo rosdep init && rosdep update`.

---

### 3. `teleop_twist_keyboard` messages not reaching the robot
**Symptom:** Keypresses registered in the teleop terminal but the robot didn't move
in Gazebo.
**Cause:** `teleop_twist_keyboard` publishes plain `geometry_msgs/Twist` by default,
but the `ros_gz_bridge` on this stack expects `geometry_msgs/TwistStamped`.
**Fix:**
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true
```

---

### 4. Stale `gz sim` processes causing duplicate/garbled topic data
**Symptom:** After restarting a simulation session, `/clock`, `/odom`, and
`/cmd_vel` showed conflicting or duplicated publishers; robot behaved
erratically or ignored commands.
**Cause:** A previous `gz sim` server process hadn't fully terminated and was
still publishing alongside the new one.
**Fix:** Always kill stale processes before relaunching:
```bash
pkill -9 -f "gz sim"
```

---

### 5. Gazebo GUI flicker / render lag under WSL2
**Symptom:** Gazebo client window flickers and lags badly during teleop,
making manual SLAM-mapping runs unreliable.
**Cause:** No discrete GPU passthrough into WSL2 — Gazebo is falling back to
`llvmpipe` software rendering, which can't keep up with the GUI's real-time
rendering demands.
**Fix (in progress):** Move to headless simulation — run the Gazebo **server**
only (`gz sim -s`, or the launch file's `headless:=True` argument) and use
**RViz2** for all visualization instead of the Gazebo client window. This is
being adopted as the standard approach for this environment, not a one-off
workaround.
**Status:** Transition not yet fully complete — SLAM (Step 7) and Nav2 bringup
are blocked on finishing this.

---

### 6. Wrong target ROS distro assumed initially
**Cause:** Initial implementation assumed ROS 2 Humble.
**Correction:** Ubuntu 24.04 maps to **ROS 2 Jazzy Jalisco + Gazebo Harmonic**,
not Humble. This changed package sourcing (`ros-jazzy-*` instead of
`ros-humble-*`) and required building TurtleBot3 from its `jazzy` source
branch, since apt packages for Jazzy don't exist yet upstream.
