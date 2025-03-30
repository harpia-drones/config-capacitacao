#!/bin/bash

cd /root/PX4-Autopilot/Tools/simulation/gz/models

cp -r mono_cam mono_cam2

cd mono_cam
rm -rf model.sdf
touch model.sdf
chmod +x model.sdf
cat << 'EOF' >> model.sdf
<?xml version="1.0" encoding="UTF-8"?>
<sdf version='1.9'>
    <model name='mono_cam'>
        <pose>0 0 0 0 0 0</pose>
        <self_collide>false</self_collide>
        <static>false</static>
        <link name="camera_link">
        <inertial>
            <pose>0.03 0.03 0.03 0 0 0</pose>
            <mass>0.050</mass>
            <inertia>
            <ixx>0.00004</ixx>
            <ixy>0</ixy>
            <ixz>0</ixz>
            <iyy>0.00004</iyy>
            <iyz>0</iyz>
            <izz>0.00004</izz>
            </inertia>
        </inertial>
        <visual name="mono_cam/visual/housing">
            <geometry>
            <box>
                <size>0.02 0.04 0.04</size>
            </box>
            </geometry>
        </visual>
        <visual name="mono_cam/visual/lens">
            <pose>0.015 0 0 0 1.5707 0</pose>
            <geometry>
            <cylinder>
                <radius>0.008</radius>
                <length>0.01</length>
            </cylinder>
            </geometry>
        </visual>
        <visual name="mono_cam/visual/lens_glass">
            <pose>0.014 0 0 0 0 0</pose>
            <geometry>
            <sphere>
                <radius>0.0079</radius>
            </sphere>
            </geometry>
            <material>
            <ambient>.4 .4 .5 .95</ambient>
            <diffuse>.4 .4 .5 .95</diffuse>
            <specular>1 1 1 1</specular>
            <emissive>0 0 0 1</emissive>
            </material>
        </visual>
        <sensor name="imager" type="camera">
            <pose>0 0 0 0 0 0</pose>
            <camera>
            <horizontal_fov>1.74</horizontal_fov>
            <image>
                <width>1280</width>
                <height>960</height>
            </image>
            <clip>
                <near>0.1</near>
                <far>3000</far>
            </clip>
            </camera>
            <always_on>1</always_on>
            <update_rate>30</update_rate>
            <visualize>true</visualize>
            <topic>camera_forward</topic>
        </sensor>
        <gravity>true</gravity>
        <velocity_decay/>
        </link>
    </model>
</sdf>
EOF

cd ../mono_cam2
rm -rf model.sdf
touch model.sdf
chmod +x model.sdf
cat << 'EOF' >> model.sdf
<?xml version="1.0" encoding="UTF-8"?>
<sdf version='1.9'>
    <model name='mono_cam2'>
        <pose>0 0 0 0 0 0</pose>
        <self_collide>false</self_collide>
        <static>false</static>
        <link name="camera2_link">
        <inertial>
            <pose>0.03 0.03 0.03 0 0 0</pose>
            <mass>0.050</mass>
            <inertia>
            <ixx>0.00004</ixx>
            <ixy>0</ixy>
            <ixz>0</ixz>
            <iyy>0.00004</iyy>
            <iyz>0</iyz>
            <izz>0.00004</izz>
            </inertia>
        </inertial>
        <visual name="mono_cam2/visual/housing">
            <geometry>
            <box>
                <size>0.02 0.04 0.04</size>
            </box>
            </geometry>
        </visual>
        <visual name="mono_cam2/visual/lens">
            <pose>0.015 0 0 0 1.5707 0</pose>
            <geometry>
            <cylinder>
                <radius>0.008</radius>
                <length>0.01</length>
            </cylinder>
            </geometry>
        </visual>
        <visual name="mono_cam2/visual/lens_glass">
            <pose>0.014 0 0 0 0 0</pose>
            <geometry>
            <sphere>
                <radius>0.0079</radius>
            </sphere>
            </geometry>
            <material>
            <ambient>.4 .4 .5 .95</ambient>
            <diffuse>.4 .4 .5 .95</diffuse>
            <specular>1 1 1 1</specular>
            <emissive>0 0 0 1</emissive>
            </material>
        </visual>
        <sensor name="imager2" type="camera">
            <pose>0 0 0 0 0 0</pose>
            <camera>
            <horizontal_fov>1.74</horizontal_fov>
            <image>
                <width>1280</width>
                <height>960</height>
            </image>
            <clip>
                <near>0.1</near>
                <far>3000</far>
            </clip>
            </camera>
            <always_on>1</always_on>
            <update_rate>30</update_rate>
            <visualize>true</visualize>
            <topic>camera_down</topic>
        </sensor>
        <gravity>true</gravity>
        <velocity_decay/>
        </link>
    </model>
</sdf>
EOF

cd ../x500_mono_cam
rm -rf model.sdf
touch model.sdf
chmod +x model.sdf
cat << 'EOF' >> model.sdf
<?xml version="1.0" encoding="UTF-8"?>
<sdf version='1.9'>
    <model name='x500_dual_cam'>
        <include merge='true'>
        <uri>x500</uri>
        </include>
        <include merge='true'>
        <uri>model://mono_cam</uri>
        <pose>.12 .03 .242 0 0 0</pose>
        </include>
        <include merge='true'>
        <uri>model://mono_cam2</uri>
        <pose>0 0 .10 0 1.5707 0</pose>
        </include>
        <joint name="Camera1Joint" type="fixed">
        <parent>base_link</parent>
        <child>camera_link</child>
        <pose relative_to="base_link">.12 .03 .242 0 0 0</pose>
        </joint>
        <joint name="Camera2Joint" type="fixed">
        <parent>base_link</parent>
        <child>camera2_link</child>
        <pose relative_to="base_link">0 0 0 0 1.5707 0</pose>
        </joint>
    </model>
</sdf>
EOF

cd /root/harpia_ws/src/config
touch cameras.yaml
chmod +x cameras.yaml
cat << 'EOF' >> cameras.yaml
- ros_topic_name: "camera_forward"
  gz_topic_name: "camera_forward"
  ros_type_name: "sensor_msgs/msg/Image"
  gz_type_name: "gz.msgs.Image"
  lazy: true
  direction: "GZ_TO_ROS"
    
- ros_topic_name: "camera_down"
  gz_topic_name: "camera_down"
  ros_type_name: "sensor_msgs/msg/Image"
  gz_type_name: "gz.msgs.Image"
  lazy: true
  direction: "GZ_TO_ROS"
EOF