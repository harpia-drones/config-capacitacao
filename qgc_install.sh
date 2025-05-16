#!/bin/bash

CONFIG_FOLDER_PATH="$HOME/config"

# Path to a flag file indicating that the script has already run
QGC_FLAG_FILE_I="$CONFIG_FOLDER_PATH/.qgc_setup_done_i"
QGC_FLAG_FILE_II="$CONFIG_FOLDER_PATH/.qgc_setup_done_ii"

# Definitions to install QGC
QGC_URL="https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage"
DEST_DIR="/usr/local/bin"
QGC_APP="$DEST_DIR/QGroundControl.AppImage"

if [ ! -f "$QGC_FLAG_FILE_I" ]; then

    echo ""
    echo "======================================================================="
    echo "  Preparing environment to install QGroundControl."           
    echo "======================================================================="
    echo ""

    # Remove modem manager
    sudo apt-get remove modemmanager -y && \

    # install GStreamer
    sudo apt-get install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y && \
    sudo apt-get install libfuse2 -y && \
    sudo apt-get install libxcb-xinerama0 libxkbcommon-x11-0 libxcb-cursor-dev -y && \

    if [ $? -eq 0 ]; then

        echo ""
        echo "======================================================================="
        echo "  Process done."           
        echo "======================================================================="
        echo ""

        # Create flag file
        sudo touch "$QGC_FLAG_FILE_I"

        # Exit the script returing a success code
        exit 0 
    else
        echo ""
        echo "Error when preparing environment to install QGroundControl."
        echo ">> Configuration aborted."
        echo ""
        
        # Exit the script returing a failure code
        exit 1
    fi
elif [ ! -f "$QGC_FLAG_FILE_II" ]; then

    echo ""
    echo "======================================================================="
    echo "  Installing QGroundControl..."           
    echo "======================================================================="
    echo ""

    # Update packages and install dependencies
    sudo apt update && \

    # Download QGroundControl AppImage
    sudo wget -O "$QGC_APP" "$QGC_URL" && \

    # Give execution permission
    sudo chmod +x "$QGC_APP"

    if [ $? -eq 0 ]; then

        # Allow harpia user to open display
        echo " " >> /home/harpia/.bashrc
        echo "# Allow harpia user to open display" >> /home/harpia/.bashrc
        echo "export DISPLAY=:0" >> /home/harpia/.bashrc

        # Create an alias to open QGroundControl
        echo " " >> /home/harpia/bashrc
        echo "# Create an alias to open QGroundControl" >> /home/harpia/bashrc
        echo "alias qgc='/usr/local/bin/QGroundControl.AppImage'" >> /home/harpia/.bashrc

        # Create an alias to source the terminal
        echo " " >> /home/harpia/bashrc
        echo "# Create an alias to source the terminal" >> /home/harpia/bashrc
        echo "alias bashrc='source /home/harpia/.bashrc'" >> /home/harpia/.bashrc

        # Create flag file
        sudo touch "$QGC_FLAG_FILE_II"

        echo ""
        echo "======================================================================="
        echo "  The environment is ready to use."           
        echo "======================================================================="
        echo ""

        # Exit the script returing a success code
        exit 0  
    else
        echo ""
        echo "Error when installing QGroundControl."
        echo ">> Configuration aborted."
        echo ""
            
        exit 1
    fi
else
    echo ""
    echo ">> Environment is already ready to use."

    # Exit the script returing a success code       
    exit 0
fi