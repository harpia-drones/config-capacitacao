#!/bin/bash

# Path to config folder
CONFIG_FOLDER_PATH="/root/config"
HARPIA_CONFIG_FOLDER_PATH="/home/harpia/config"

# Path to dependencies folder
DEPEND_FOLDER_PATH="/root/dependencies"

# Flag file to verify dependencies folder
DEP_FLAG_FILE="$DEPEND_FOLDER_PATH/package_creation/templates/minimum_node.py"

# Path to a flag file indicating that the script has already run
FLAG_FILE_I="$CONFIG_FOLDER_PATH/.setup_done_i"
FLAG_FILE_II="$CONFIG_FOLDER_PATH/.setup_done_ii"

# Path to ros2 workspace
WS_DIR_PATH=$(find "$HOME" -type d -name "*_ws" -print -quit)

echo "Checking pre-requirements..."
    
# Try to source the python virtual environment
source "/root/harpia_venv/bin/activate"

if [ $? -eq 1 ]; then

    echo ">> Creating a python virtual environment..."
    echo ""

    # Update packages and install python3-venv pkg
    apt-get update && \
    apt-get install -y python3-venv && \

    # Create the virtual environment in //root
    cd "/root" && \
    python3 -m venv harpia_venv && \

    # Activate the virtual environment
    source "/root/harpia_venv/bin/activate" && \

    # Configure to activate venv everytime a new bash terminal is open
    echo "source /root/harpia_venv/bin/activate" >> /root/.bashrc

    # Validate the venv creation
    if [ $? -eq 1 ]; then        
        echo ""
        echo "Error when creating the virtual environment."
        echo ">> Configuration aborted."

        # Exit the script returing a failure code
        exit 1
    fi
else
    echo ""
    echo ">> Requirement satisfied: Virtual environment sourced."
fi

# If the flag file does not exist, run the script and create the flag
if [ ! -f "$FLAG_FILE_I" ]; then

    echo ""
    echo "=================================================================="
    echo "  Starting the first part of configuration..."
    echo "=================================================================="
    echo ""
    
    # Updating the system
    apt-get update && \
    apt-get upgrade -y
    
    # Install the PX4 development toolchain to use the simulator
    cd "/root" && \
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive && \
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh 
    
    # Verify if the last command return 0 (succesfully executed)
    if [ $? -eq 0 ]; then

    	# Create the flag file
        touch "$FLAG_FILE_I"
        
        echo ""
        echo "=================================================================="
    	echo "  First part of cofiguration completed successfully!"        
    	echo "=================================================================="
        echo ""
        echo ">> You must restart the container."
        echo ""

        # Exit the script returning a success code
        exit 0
    else
        echo ""
        echo "Error when running configuration script for the first time."
        echo ">> Configuration aborted."

        # Exit the script returing a failure code
        exit 1
    fi
elif [ ! -f "$FLAG_FILE_II" ]; then

    echo ""
    echo "=================================================================="
    echo "  Starting the second part of configuration..."           
    echo "=================================================================="
    echo ""

    # Install some dependencies for ros2
    pip install -U "empy==3.3.4" pyros-genmsg setuptools catkin_pkg lark
    apt-get update
    apt-get install -y python3-colcon-common-extensions
    apt-get install -y "ros-$ROS_DISTRO-desktop python3-argcomplete"
    apt-get install -y ros-dev-tools

    # Install XRCE-DDS Agent
    cd "/root/" && \
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git && \
    cd Micro-XRCE-DDS-Agent && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig /usr/local/lib/

    # Clone dependency packages for PX4
    cd "$WS_DIR_PATH/src" && \
    git clone https://github.com/PX4/px4_msgs.git && \
    git clone https://github.com/PX4/px4_ros_com.git && \

    # Build the environment
    cd "$WS_DIR_PATH" && \
    colcon build --packages-ignore bringup description interfaces

    # Create a password to /root
    echo 'root:senha' | chpasswd

    # Create a new user named harpia
    useradd -m -s /bin/bash harpia && \

    # Create a password to harpia
    echo 'harpia:senha' | chpasswd && \

    # Add harpia to usdo and dialout groups
    usermod -aG sudo harpia && \
    usermod -aG dialout harpia && \

    # Give permissions to harpia run sudo without password
    echo "harpia ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \

    # Allow display to harpia
    echo "" >> /home/harpia/.bashrc
    echo "export DISPLAY=:0" >> /home/harpia/.bashrc

    # Create a config folde in /home/harpia
    mkdir -p "$HARPIA_CONFIG_FOLDER_PATH" && \

    # Clone qgc_install.sh script
    curl -L "https://raw.githubusercontent.com/harpia-drones/config/refs/heads/main/qgc_install.sh" -o "$HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh" && \
    chmod a+rwx "$HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh" && \
    
    # Create an alias to install qgc
    echo " " >> /home/harpia/.bashrc && \
    echo "# Create an alias to install QGroundControl" >> /home/harpia/.bashrc && \
    echo "alias setup='bash $HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh'" >> /home/harpia/.bashrc && \

    # Verify if the last command return 0 (succesfully executed)
    if [ $? -eq 0 ]; then

        # Create the flag file
        touch "$FLAG_FILE_II"
            
        echo ""
        echo "=================================================================="
        echo "  Second part of cofiguration completed successfully!"               
        echo "=================================================================="
        echo ""

        # Exit the script returing a failure code
        exit 0
    else
        echo ""
        echo "Error when running configuration script for the sencond time."
        echo ">> Configuration aborted."

        # Exit the script returing a failure code
        exit 1
    fi
else
    echo ""
    echo "All the configurations for root is done. Check configurations for harpia."
    echo ""

    # Exit the script returing a success code
    exit 0
fi