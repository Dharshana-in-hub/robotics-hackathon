# Implementation Guide — Task 1 & Task 2
### Theme 1: ROS2 & Robotics Simulation
**Target system:** Ubuntu 24.04 LTS (Noble) → ROS 2 Jazzy Jalisco → Gazebo Harmonic (`ros_gz`)

---

## PART A — Environment Setup (do this once)

### Step 1: Update the base system
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git curl gnupg lsb-release software-properties-common
```
**Verify:** `lsb_release -a` should report `Ubuntu 24.04`.

---

### Step 2: Install ROS 2 Jazzy Desktop
```bash
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo add-apt-repository universe -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
  sudo tee /etc/apt/sources.list.d/ros2.list

sudo apt update
sudo apt install -y ros-jazzy-desktop ros-dev-tools

echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```
**Verify:**
```bash
ros2 --version
ros2 run demo_nodes_cpp talker
```
Open a second terminal and run `ros2 run demo_nodes_py listener` — you should see it printing received messages. Ctrl+C both when confirmed.

---

### Step 3: Initialize rosdep
```bash
sudo rosdep init
rosdep update
```
(If it says "already initialized," that's fine — continue.)

---

### Step 4: Install Nav2 (pulls in Gazebo-Harmonic-compatible bridges as dependencies)
```bash
sudo apt install -y ros-jazzy-navigation2 ros-jazzy-nav2-bringup ros-jazzy-slam-toolbox
sudo apt install -y ros-jazzy-teleop-twist-keyboard
```
**Verify:** `ros2 pkg list | grep nav2` should list `nav2_bringup`, `nav2_planner`, `nav2_controller`, etc.

---

### Step 5: Build TurtleBot3 packages from source (Jazzy branch)
TurtleBot3 apt packages aren't published for Jazzy yet — build from the official `jazzy` branch instead.
```bash
mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws/src

git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

cd ~/turtlebot3_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
```
**Verify:** build should finish with `Summary: N packages finished` and no `Failed` entries.

Add these to your shell profile:
```bash
echo "source ~/turtlebot3_ws/install/setup.bash" >> ~/.bashrc
echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
source ~/.bashrc
```
> Note: do **not** set `GAZEBO_MODEL_PATH` — that variable is only relevant to Gazebo Classic (pre-Jazzy). Jazzy uses Gazebo Harmonic via `ros_gz`, which resolves models differently and doesn't need it.

---

## PART B — Task 1: TurtleBot Navigation

### Step 6: Launch the Gazebo Harmonic simulation
```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```
**Expected result:** a Gazebo window opens showing a small square arena with the TurtleBot3 (burger) model in the middle, walls and a few obstacle boxes around it. Leave this terminal running.

---

### Step 7: Build a map with SLAM (only needed once — skip on later runs if you already have a saved map)
Open a **new terminal**:
```bash
source ~/turtlebot3_ws/install/setup.bash
ros2 launch slam_toolbox online_async_launch.py use_sim_time:=True
```
Open a **third terminal** to drive the robot manually and build up the map:
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```
Use the keys shown in that terminal (typically `i` forward, `,` back, `j`/`l` turn, `k` stop) to drive the robot around the entire arena — go along every wall and around every obstacle so SLAM captures full coverage. Watch the map build up live in RViz if you have it open (`rviz2`, add a `Map` display subscribed to `/map`).
