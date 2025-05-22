#!/bin/bash

# Path to config folder
CONFIG_FOLDER_PATH="/root/config"
HARPIA_CONFIG_FOLDER_PATH="/home/harpia/config"

QGC_FLAG_FILE_I="/home/harpia/.qgc_setup_done_i"
QGC_FLAG_FILE_II="/home/harpia/.qgc_setup_done_ii"

# Definitions to install QGC
QGC_URL="https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage"
DEST_DIR="/usr/local/bin"
QGC_APP="$DEST_DIR/QGroundControl.AppImage"

# Path to dependencies folder
DEPEND_FOLDER_PATH="/root/dependencies"

# Flag file to verify dependencies folder
DEP_FLAG_FILE="$DEPEND_FOLDER_PATH/package_creation/templates/minimum_node.py"

# Path to a flag file indicating that the script has already run
FLAG_FILE_I="$CONFIG_FOLDER_PATH/.setup_done_i"
FLAG_FILE_II="$CONFIG_FOLDER_PATH/.setup_done_ii"

# Requirements.txt path file
REQUIREMENTS_PATH="$CONFIG_FOLDER_PATH/requirements.txt"

# Path to ros2 workspace
WS_DIR_PATH=$(find "$HOME" -type d -name "*_ws" -print -quit)

echo ""
echo "Checking pre-requirements..."

# Try to source the python virtual environment
if [ ! -f "/root/harpia_venv/bin/activate" ]; then
    echo ""
    echo ">> Creating a python virtual environment..."
    echo ""

    # Update packages and install python3-venv pkg
    apt-get update && \
    apt-get install -y python3-venv && \

    # Create the virtual environment in /root
    cd "/root" && \
    python3 -m venv harpia_venv && \

    # Configure to activate venv everytime a new bash terminal is open
    echo "" >> /root/.bashrc >> /root/.bashrc
    echo "# Activate python virtual environment" >> /root/.bashrc
    echo "source /root/harpia_venv/bin/activate" >> /root/.bashrc

    if [ $? -ne 0 ]; then        
        echo ""
        echo "Error when creating the virtual environment."
        echo ">> Configuration aborted."
        exit 1
    fi
else
    echo ""
    echo ">> Requirement satisfied: Virtual environment exists."
    echo ""
fi

# Source the venv regardless
source "/root/harpia_venv/bin/activate"

# First configuration stage
if [ ! -f "$FLAG_FILE_I" ]; then
    echo ""
    echo "=================================================================="
    echo "  Installing PX4-Autopilot..."
    echo "=================================================================="
    echo ""
    
    # Updating the system
    apt-get update && \
    apt-get upgrade -y
    
    # Install the PX4 development toolchain
    cd "/root" && \
    echo "" && \
    echo ">> Cloning PX4-Autopilot folder..." && \
    echo "" && \
    git clone git@github.com:PX4/PX4-Autopilot.git --recursive && \
    bash /root/PX4-Autopilot/Tools/setup/ubuntu.sh 

    # Import the custom eletroquad world 
    bash /root/config/eletroquad_world.sh
    
    if [ $? -eq 0 ]; then
        touch "$FLAG_FILE_I"
        echo ""
        echo "=================================================================="
        echo "  PX4-Autopilot installed successfully!"        
        echo "=================================================================="
        exit 0
    else
        echo ""
        echo "Error when running configuration script for the first time."
        echo ">> Configuration aborted."
        exit 1
    fi

# Second configuration stage
elif [ ! -f "$FLAG_FILE_II" ]; then
    echo ""
    echo "======================================================================="
    echo "  Installing python libs..."          
    echo "======================================================================="
    echo ""

    # Install python libs
    python3 -m pip install -r /root/config/requirements.txt

    echo ""
    echo "======================================================================="
    echo "  Installing aditional packages..."          
    echo "======================================================================="
    echo ""

    # Install dependencies
    bash /root/config/install_packages.sh

    echo ""
    echo "=================================================================="
    echo "  Installing Micro-XRCE..."           
    echo "=================================================================="
    echo ""

    # Install XRCE-DDS Agent
    cd "/root/" && \

    echo "" && \
    echo ">> Cloning config folder..." && \
    echo "" && \

    git clone git@github.com:eProsima/Micro-XRCE-DDS-Agent.git && \
    cd Micro-XRCE-DDS-Agent && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig /usr/local/lib/

    # Clone packages
    mkdir -p "$WS_DIR_PATH/src"
    cd "$WS_DIR_PATH/src"

    echo "" && \
    echo ">> Cloning px4_msgs folder..." && \
    echo "" && \

    git clone git@github.com:PX4/px4_msgs.git

    # Import the drone model into px4 (adapt existing model)
    bash /root/config/eletroquad_model.sh

    # Build the environment
    cd "$WS_DIR_PATH" && \
    colcon build --packages-ignore bringup description interfaces

    # User configuration
    echo 'root:senha' | chpasswd

    # Create a new user named harpia
    echo ""
    echo ">> Creating a new user named 'harpia'..."
    echo ""

    useradd -m -s /bin/bash harpia
    echo 'harpia:senha' | chpasswd
    usermod -aG sudo harpia
    usermod -aG dialout harpia
    echo "harpia ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo "export DISPLAY=:0" >> /home/harpia/.bashrc
    cp -r /root/.ssh /home/harpia
    sudo chown -R harpia:harpia /home/harpia/.ssh

    # QGC setup preparation
    mkdir -p "$HARPIA_CONFIG_FOLDER_PATH"
    curl -L "https://raw.githubusercontent.com/harpia-drones/config-capacitacao/main/qgc_install.sh" -o "$HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh"
    chmod a+rwx "$HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh"
    echo "alias setup='bash $HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh'" >> /home/harpia/.bashrc

    echo " " >> /root/.bashrc
    echo "# Alias to launch QGControl"
    echo "alias qgc=\"runuser -l harpia -c 'DISPLAY=:0 /usr/local/bin/QGroundControl.AppImage'\"" >> /root/.bashrc

    if [ $? -eq 0 ]; then
        touch "$FLAG_FILE_II"
        echo ""
        echo "=================================================================="
        echo "  Micro-XRCE installed successfully!"               
        echo "=================================================================="
        echo ""
    else
        echo ""
        echo "Error when running configuration script for the second time."
        echo ">> Configuration aborted."
        echo ""

        exit 1
    fi

    runuser -l harpia -c "source /home/harpia/.bashrc && \
                          bash $HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh"
    exit $?

elif [ ! -f "$QGC_FLAG_FILE_II" ]; then
    runuser -l harpia -c "source /home/harpia/.bashrc && \
                          bash $HARPIA_CONFIG_FOLDER_PATH/qgc_install.sh"
    exit $?
else
    echo ""
    echo ">> Environment is already ready to use."       
    exit 0
fi