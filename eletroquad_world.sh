#!/bin/bash

cd /root/PX4-Autopilot/Tools/simulation/gz/worlds

echo ""
echo ">> Cloning EletroquadWorld folder..." 
echo "" 

git clone git@github.com:harpia-drones/EletroquadWorld.git
cp -r EletroquadWorld/models .
cp -r EletroquadWorld/eletroquad.sdf .
rm -rf EletroquadWorld