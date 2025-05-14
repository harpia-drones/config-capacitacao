#!/bin/bash

cd /root/PX4-Autopilot/Tools/simulation/gz/models

# Remove native x500_mono_cam model directory
rm -rf x500_mono_cam

# Copy models directory
cp -r /root/dependencies/models/x500_mono_cam /root/PX4-Autopilot/Tools/simulation/gz/models/
cp -r /root/dependencies/models/realsense_d435 /root/PX4-Autopilot/Tools/simulation/gz/models/
cp -r /root/dependencies/models/realsense_d435_2 /root/PX4-Autopilot/Tools/simulation/gz/models/