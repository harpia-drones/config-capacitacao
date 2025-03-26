#!/bin/bash

# Path to config folder
CONFIG_FOLDER_PATH="/root/config"
HARPIA_CONFIG_FOLDER_PATH="/home/harpia/config"

# Path to dependencies folder
DEPEND_FOLDER_PATH="/root/dependencies"

# Flag file to verify dependencies folder
DEP_FLAG_FILE="$DEPEND_FOLDER_PATH/package_creation/templates/minimum_node.py"

if [ ! -f "$DEP_FLAG_FILE" ]; then

    # Tmux configuration
    touch /root/.tmux.conf && \
    echo 'set -g mouse on' >> /root/.tmux.conf && \
    echo 'bind -n C-Left select-pane -L' >> /root/.tmux.conf && \
    echo 'bind -n C-Right select-pane -R' >> /root/.tmux.conf && \
    echo 'bind -n C-Up select-pane -U' >> /root/.tmux.conf && \
    echo 'bind -n C-Down select-pane -D' >> /root/.tmux.conf && \
    echo 'setw -g mode-keys vi' >> /root/.tmux.conf

    # Install some ros2 packages
    apt-get update && \
    apt-get install -y ros-jazzy-joint-state-publisher-gui

    # Create an alias to source the terminal
    echo " " >> /root/.bashrc
    echo "# Alias to source the terminal" >> /root/.bashrc
    echo "alias bashrc='source /root/.bashrc'" >> /root/.bashrc

    # Create an alias to build ros2 workspace
    echo " " >> /root/.bashrc
    echo "# Alias to build ros2 workspace" >> /root/.bashrc
    echo "alias cb='colcon build && source /root/.bashrc'" >> /root/.bashrc

    # Create config folder
    mkdir -p /root/config

    # Clone the entrypoint.sh
    curl -L "https://raw.githubusercontent.com/harpia-drones/config/refs/heads/main/entrypoint.sh" -o /root/config/entrypoint.sh && \
    chmod +x /root/config/entrypoint.sh

    # Create an alias to setup
    echo " " >> /root/.bashrc
    echo "# Create an alias to setup" >> /root/.bashrc
    echo "alias setup='bash /root/config/entrypoint.sh'" >> /root/.bashrc

    # Clone dependencies folder 
    echo ">> Cloning make dependencies folder..."
    echo " "
    cd "/root" && \
    git clone git@github.com:harpia-drones/dependencies.git && \

    if [ $? -eq 1 ]; then
        echo ""
        echo "Error when cloning make dependencies folder."
        echo ">> Configuration aborted."

        # Exit the script returing a failure code
        exit 1
    fi
else
    echo " "
    echo ">> Requirement satisfied: Make dependencies."
fi