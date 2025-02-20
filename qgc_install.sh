#!/bin/bash

# Path to a flag file indicating that the script has already run
FLAG_FILE_II="/root/config/.setup_done_ii"
FLAG_FILE_III="/root/config/.setup_done_iii"

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
        # Exit of the script returing a success code
        exit 0 
    else
        echo ""
        echo "Error when running setup.sh for the third time."
        echo ">> Configuration aborted."
        echo ""
        
        # Exit of the script returing a failure code
        exit 1
    fi
else
    if [ ! -f "$FLAG_FILE_III" ]; then

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
            echo "Error when running setup.sh for the fourth time."
            echo ">> Configuration aborted."
            echo ""
            
            exit 1
        fi
    else
        exit 2
    fi
fi
