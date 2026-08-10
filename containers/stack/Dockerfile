# syntax=docker/dockerfile:1
#
# Fern/Runpod runtime: one process-supervised image for a standard Runpod Pod.
# The base is Epic's Ubuntu 22.04 UE 5.8 image. ROS 2 Jazzy is built from source in
# this image; copying the project's Ubuntu 24.04 ROS image here would be ABI-invalid.
ARG UE_BASE_IMAGE=ghcr.io/coolcmyk/drone-sim-unreal-base:5.8-daac02628ea8
FROM ${UE_BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

ARG ROS2_REF=cf1dbea3c2df5b3c07ad39dc9dcdb02c5b076325
ARG VISION_OPENCV_SHA=f5b738d9694f0cee5904440d03912fc249943f8a
ARG PERCEPTION_PCL_SHA=3128bdf505ab1616fd10581080ef46de972f964b
ARG PCL_MSGS_SHA=16c4174b4903982c8b031672c8cfcdd16a7430dc
ARG PX4_TAG=v1.16.0
ARG PX4_SHA=6ea3539157ca358c70a515878b77077af7d4611d
ARG XRCE_TAG=v2.4.3
ARG XRCE_SHA=73622810d984349b80bbac0ef55fc0b694d62222
ARG PX4_MSGS_SHA=392e831c1f659429ca83902e66820d7094591410
ARG PX4_ROS_COM_SHA=86e9aeb20e55a4673fa8a9f1c29ea06a6c5ad1af
ARG COSYS_SHA=a552dd6cd517b8d5d26629ad88004356c3007326
ARG GEOGRAPHIC_INFO_SHA=24806adc767414eb3a34a58aefeb648ee415b09a
ARG MAVROS_SHA=19f28c8a9bf46fe1795301b2b9a471d94fb1878a
ARG QGC_VERSION=5.0.8
ARG QGC_SHA256=06969c67ef58ea063def0a8271447a1cc385438c4a7df36813315b4475146737
ARG QGC_URL=https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=jazzy \
    PX4_DIR=/opt/px4 \
    FASTDDS_BUILTIN_TRANSPORTS=UDPv4

# Runtime and build dependencies are installed in the Jammy image. `rosdep` resolves the
# Jazzy source tree against this base, so an unavailable dependency fails the image build.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git gnupg locales sudo \
      build-essential cmake ninja-build pkg-config patch rsync wget unzip zip \
      python3 python3-pip python3-venv python3-argcomplete python3-empy python3-msgpack \
      lsb-release software-properties-common \
      libeigen3-dev liburdfdom-headers-dev protobuf-compiler libxml2-utils bc \
      xvfb libfuse2 fonts-dejavu-core openbox x11-utils xterm \
      libopengl0 libegl1 libwayland-client0 \
      libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 \
      libxcb-xkb1 libpulse0 libspeechd2 \
      x11vnc novnc websockify supervisor \
 && python3 -m pip install --no-cache-dir \
      rosdep vcstool colcon-common-extensions catkin_pkg rosdistro \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen C.UTF-8 \
 && rosdep init

# Build the exact Jazzy source revision. Do not replace this with Jazzy apt packages:
# official Jazzy binaries are Noble-only, while this UE image is Jammy.
WORKDIR /opt/ros2-src
RUN git clone https://github.com/ros2/ros2.git . \
 && git checkout --detach "${ROS2_REF}" \
 && test "$(git rev-parse HEAD)" = "${ROS2_REF}" \
 && vcs import src < ros2.repos \
 && git clone https://github.com/ros-perception/vision_opencv.git src/vision_opencv \
 && git -C src/vision_opencv checkout --detach "${VISION_OPENCV_SHA}" \
 && git clone https://github.com/ros-perception/perception_pcl.git src/perception_pcl \
 && git -C src/perception_pcl checkout --detach "${PERCEPTION_PCL_SHA}" \
 && test "$(git -C src/perception_pcl rev-parse HEAD)" = "${PERCEPTION_PCL_SHA}" \
 && git clone https://github.com/ros-perception/pcl_msgs.git src/pcl_msgs \
 && git -C src/pcl_msgs checkout --detach "${PCL_MSGS_SHA}" \
 && test "$(git -C src/pcl_msgs rev-parse HEAD)" = "${PCL_MSGS_SHA}" \
 && rosdep update \
 && apt-get update \
 && rosdep install --from-paths src --ignore-src --rosdistro jazzy -r -y \
      --skip-keys "urdfdom_headers rti-connext-dds-6.0.1 python3-catkin-pkg-modules python3-vcstool python3-rosdistro-modules" \
 && colcon build --merge-install --install-base /opt/ros/jazzy --packages-up-to \
      rclcpp rclpy launch_ros ros2topic ros2bag rosbag2_storage_mcap \
      rmw_fastrtps_cpp tf2_ros tf2_geometry_msgs tf2_sensor_msgs image_transport cv_bridge pcl_conversions \
 && test -x /opt/ros/jazzy/bin/ros2 \
 && /opt/ros/jazzy/bin/ros2 --help >/dev/null

# PX4 is built from the pinned firmware tree on the same OS that will run it.
WORKDIR /opt/px4
RUN git clone --recursive --branch "${PX4_TAG}" https://github.com/PX4/PX4-Autopilot.git . \
 && test "$(git rev-parse HEAD)" = "${PX4_SHA}" \
 && bash Tools/setup/ubuntu.sh --no-sim-tools \
 && apt-get update \
 && apt-get install -y --no-install-recommends bc libeigen3-dev protobuf-compiler pkg-config libxml2-utils \
 && rm -rf /var/lib/apt/lists/* \
 && make px4_sitl_default \
 && test -x build/px4_sitl_default/bin/px4

# The agent and branch-matched messages are built against the source Jazzy overlay.
WORKDIR /opt/xrce
RUN git clone --branch "${XRCE_TAG}" https://github.com/eProsima/Micro-XRCE-DDS-Agent.git . \
 && test "$(git rev-parse HEAD)" = "${XRCE_SHA}" \
 && source /opt/ros/jazzy/setup.bash \
 && cmake -B build -DUAGENT_USE_SYSTEM_FASTDDS=ON -DCMAKE_PREFIX_PATH=/opt/ros/jazzy \
 && cmake --build build -j"$(nproc)" \
 && cmake --install build \
 && ldconfig \
 && test -x /usr/local/bin/MicroXRCEAgent

WORKDIR /opt/drone-sim/ros2
COPY ros2/src/interfaces src/interfaces
COPY ros2/src/control src/control
COPY ros2/src/bringup src/bringup
RUN mkdir -p src/px4_msgs src/px4_ros_com \
 && git clone https://github.com/PX4/px4_msgs.git src/px4_msgs \
 && git -C src/px4_msgs checkout --detach "${PX4_MSGS_SHA}" \
 && git clone https://github.com/PX4/px4_ros_com.git src/px4_ros_com \
 && git -C src/px4_ros_com checkout --detach "${PX4_ROS_COM_SHA}" \
 && git clone https://github.com/ros-geographic-info/geographic_info.git src/geographic_info \
 && git -C src/geographic_info checkout --detach "${GEOGRAPHIC_INFO_SHA}" \
 && git clone https://github.com/mavlink/mavros.git src/mavros \
 && git -C src/mavros checkout --detach "${MAVROS_SHA}" \
 && source /opt/ros/jazzy/setup.bash \
 && rosdep install --from-paths src --ignore-src --rosdistro jazzy -r -y \
 && colcon build --merge-install --packages-up-to px4_msgs px4_ros_com geographic_msgs mavros_msgs interfaces control bringup \
 && test -x install/control/lib/control/offboard_control \
 && test -f install/bringup/share/bringup/launch/perception.launch.py

# Cosys-AirSim is baked into the image because a Runpod workload cannot receive the repository
# as the bind mount used by sim_up.sh. Its ROS wrapper has to be built in place.
WORKDIR /opt/Cosys-AirSim
RUN git clone --recursive https://github.com/Cosys-Lab/Cosys-AirSim.git . \
 && git checkout --detach "${COSYS_SHA}" \
 && test "$(git rev-parse HEAD)" = "${COSYS_SHA}"
COPY simulator/unreal/patches/cosys-airsim /opt/drone-sim/simulator/unreal/patches/cosys-airsim
RUN mkdir -p /airsim_root \
 && for d in cmake AirLib MavLinkCom; do ln -s "/opt/Cosys-AirSim/$d" "/airsim_root/$d"; done \
 && cp -r external /airsim_root/external \
 && cp -r ros2 /airsim_root/ros2 \
 && for patch_file in /opt/drone-sim/simulator/unreal/patches/cosys-airsim/*.patch; do \
      grep -qE '^\+\+\+ b/Unreal/' "$patch_file" || patch -d /airsim_root -p1 --forward --batch < "$patch_file"; \
    done \
 && source /opt/ros/jazzy/setup.bash \
 && source /opt/drone-sim/ros2/install/setup.bash \
 && cd /airsim_root/ros2 \
 && colcon build --merge-install \
 && test -x install/airsim_ros_pkgs/lib/airsim_ros_pkgs/airsim_node

# Build the UE plugin with UE's own Clang toolchain, never a system compiler.
RUN id -u ue4 >/dev/null 2>&1 || useradd -m -s /bin/bash ue4
RUN chown -R ue4:ue4 /opt/Cosys-AirSim /airsim_root /opt/drone-sim
USER ue4
RUN cd /opt/Cosys-AirSim \
 && ./build.sh --ue-root /home/ue4/UnrealEngine

USER root
# QGC is the MAVLink datalink; it is baked and checksum-verified so Fern does not need a
# mutable download at runtime.
RUN curl -fL --retry 3 -o /tmp/qgc.AppImage "${QGC_URL}" \
 && echo "${QGC_SHA256}  /tmp/qgc.AppImage" | sha256sum --check - \
 && chmod 0755 /tmp/qgc.AppImage \
 && mkdir -p /opt/qgc \
 && cd /opt/qgc \
 && /tmp/qgc.AppImage --appimage-extract >/dev/null \
 && rm -f /tmp/qgc.AppImage \
 && test -x /opt/qgc/squashfs-root/AppRun \
 && useradd -m -s /bin/bash qgcuser \
 && mkdir -p /home/qgcuser/tmp \
 && chown -R qgcuser:qgcuser /home/qgcuser /opt/qgc

COPY runtime/local/qgc-entrypoint.sh /usr/local/bin/qgc-entrypoint.sh
COPY runtime/runpod/interactive-entrypoint.sh /usr/local/bin/drone-sim-interactive-entrypoint
COPY runtime/runpod/vnc-desktop.sh /usr/local/bin/drone-sim-vnc-desktop
COPY runtime/runpod/start-px4.sh /usr/local/bin/drone-sim-start-px4
COPY runtime/runpod/readiness.sh /usr/local/bin/drone-sim-readiness
COPY runtime/runpod/sim_up_local.sh /opt/drone-sim/runtime/runpod/sim_up_local.sh
COPY runtime/local/airsim_rpc_client.py /opt/drone-sim/runtime/local/airsim_rpc_client.py
COPY simulator/unreal/settings.json /opt/drone-sim/settings.json
RUN chmod 0755 /usr/local/bin/qgc-entrypoint.sh /usr/local/bin/drone-sim-interactive-entrypoint /usr/local/bin/drone-sim-vnc-desktop /usr/local/bin/drone-sim-start-px4 /usr/local/bin/drone-sim-readiness /opt/drone-sim/runtime/runpod/sim_up_local.sh \
 && mkdir -p /var/log/drone-sim /home/ue4/.config/Epic \
 && chown -R ue4:ue4 /var/log/drone-sim /home/ue4/.config/Epic

EXPOSE 6080
ENTRYPOINT ["/usr/local/bin/drone-sim-interactive-entrypoint"]
