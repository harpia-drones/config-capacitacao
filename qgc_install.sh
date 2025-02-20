#!/bin/bash

# Path to config folder
CONFIG_FOLDER_PATH="/$HOME/config"

# Path to a flag file indicating that the script has already run
FLAG_FILE_II="$CONFIG_FOLDER_PATH/.setup_done_ii"
FLAG_FILE_III="$CONFIG_FOLDER_PATH/.setup_done_iii"

# Definitions to install QGC
QGC_URL="https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage"
DEST_DIR="/usr/local/bin"
QGC_APP="$DEST_DIR/QGroundControl.AppImage"

if [ ! -f "$FLAG_FILE_II" ]; then

    # Remove modem manager
    sudo apt-get remove modemmanager -y && \

    # install GStreamer
    sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y && \
    sudo apt install libfuse2 -y && \
    sudo apt install libxcb-xinerama0 libxkbcommon-x11-0 libxcb-cursor-dev -y && \

    if [ $? -eq 0 ]; then
        # Exit the script returing a success code
        exit 0 
    else
        echo ""
        echo "Error when running configuration script for the third time."
        echo ">> Configuration aborted."
        echo ""
        
        # Exit the script returing a failure code
        exit 1
    fi
elif [ ! -f "$FLAG_FILE_III" ]; then

    # Update packages and install dependencies
    sudo apt update && \

    # Download QGroundControl AppImage
    sudo wget -O "$QGC_APP" "$QGC_URL" && \

    # Give execution permission
    sudo chmod +x "$QGC_APP"

    if [ $? -eq 0 ]; then
        exit 0  
    else
        echo ""
        echo "Error when running configuration script for the fourth time."
        echo ">> Configuration aborted."
        echo ""
            
        exit 1
    fi
else
    echo ""
    echo "Environment is already ready to use."
            
    exit 0
fi
