#!/bin/bash



# Update system
apt-get update

# Install packages
apt-get install -y python3-colcon-common-extensions \
    "ros-$ROS_DISTRO-desktop python3-argcomplete" \
    ros-dev-tools \
    "ros-$ROS_DISTRO-cv-bridge" \
    python3-opencv \
    libopencv-dev