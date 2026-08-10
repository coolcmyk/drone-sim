# ==============================================================================
# Fern / Runpod runtime
#
# One process-supervised image for a standard Runpod Pod.
#
# Base:
#   Epic Ubuntu 22.04 / UE 5.8 image.
#
# ROS 2 Jazzy:
#   Built from source because official Jazzy Ubuntu packages target Noble 24.04,
#   while the UE runtime is Jammy 22.04.
#
# Useful debug targets:
#
#   docker buildx build --target fern-base --load -t fern:base .
#   docker buildx build --target ros2-source --load -t fern:ros2-source .
#   docker buildx build --target ros2-deps --load -t fern:ros2-deps .
#   docker buildx build --target ros2-build --load -t fern:ros2 .
#   docker buildx build --target px4-build --load -t fern:px4 .
#   docker buildx build --target drone-ros-build --load -t fern:drone-ros .
#
# Shell into a checkpoint:
#
#   docker run --rm -it fern:ros2-deps bash
#
# ==============================================================================


ARG UE_BASE_IMAGE=ghcr.io/coolcmyk/drone-sim-unreal-base:5.8-daac02628ea8


# ==============================================================================
# Base system
# ==============================================================================

FROM ${UE_BASE_IMAGE} AS fern-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root


# ------------------------------------------------------------------------------
# Pinned revisions
# ------------------------------------------------------------------------------

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


# ------------------------------------------------------------------------------
# Runtime environment
# ------------------------------------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=jazzy \
    PX4_DIR=/opt/px4 \
    FASTDDS_BUILTIN_TRANSPORTS=UDPv4


# ------------------------------------------------------------------------------
# Core system/build dependencies
# ------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gnupg \
        locales \
        sudo \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        patch \
        rsync \
        wget \
        unzip \
        zip \
        python3 \
        python3-pip \
        python3-venv \
        python3-argcomplete \
        python3-empy \
        python3-msgpack \
        lsb-release \
        software-properties-common \
        libeigen3-dev \
        liburdfdom-headers-dev \
        protobuf-compiler \
        libxml2-utils \
        bc \
        xvfb \
        libfuse2 \
        fonts-dejavu-core \
        openbox \
        x11-utils \
        xterm \
        libopengl0 \
        libegl1 \
        libwayland-client0 \
        libxkbcommon-x11-0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libpulse0 \
        libspeechd2 \
        x11vnc \
        novnc \
        websockify \
        supervisor \
    && rm -rf /var/lib/apt/lists/*


# Keep pip separate so changing an apt dependency doesn't unnecessarily rerun it.
RUN --mount=type=cache,id=fern-pip,target=/root/.cache/pip \
    python3 -m pip install \
        rosdep \
        vcstool \
        colcon-common-extensions \
        catkin_pkg \
        rosdistro


RUN locale-gen C.UTF-8


RUN if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then \
        rosdep init; \
    fi


# ==============================================================================
# ROS 2 source acquisition
#
# Debug checkpoint:
#
#   docker buildx build \
#       --target ros2-source \
#       --progress=plain \
#       --load \
#       -t fern:ros2-source .
#
# ==============================================================================

FROM fern-base AS ros2-source

WORKDIR /opt/ros2-src


# Clone the exact ROS 2 source revision.
RUN git clone https://github.com/ros2/ros2.git . \
    && git checkout --detach "${ROS2_REF}" \
    && test "$(git rev-parse HEAD)" = "${ROS2_REF}"


# Keep vcs import as its own checkpoint.
RUN vcs import src < ros2.repos


# ------------------------------------------------------------------------------
# Additional ROS packages required by Fern
# ------------------------------------------------------------------------------

RUN git clone \
        https://github.com/ros-perception/vision_opencv.git \
        src/vision_opencv \
    && git -C src/vision_opencv checkout --detach "${VISION_OPENCV_SHA}" \
    && test \
        "$(git -C src/vision_opencv rev-parse HEAD)" \
        = "${VISION_OPENCV_SHA}"


RUN git clone \
        https://github.com/ros-perception/perception_pcl.git \
        src/perception_pcl \
    && git -C src/perception_pcl checkout --detach "${PERCEPTION_PCL_SHA}" \
    && test \
        "$(git -C src/perception_pcl rev-parse HEAD)" \
        = "${PERCEPTION_PCL_SHA}"


RUN git clone \
        https://github.com/ros-perception/pcl_msgs.git \
        src/pcl_msgs \
    && git -C src/pcl_msgs checkout --detach "${PCL_MSGS_SHA}" \
    && test \
        "$(git -C src/pcl_msgs rev-parse HEAD)" \
        = "${PCL_MSGS_SHA}"


# ==============================================================================
# ROS 2 dependency installation
#
# This is the best stage to shell into when debugging the ROS source build.
#
#   docker buildx build \
#       --target ros2-deps \
#       --load \
#       -t fern:ros2-deps .
#
#   docker run --rm -it fern:ros2-deps bash
#
# Then manually:
#
#   cd /opt/ros2-src
#
#   colcon build \
#       --merge-install \
#       --install-base /opt/ros/jazzy \
#       --packages-up-to rclcpp
#
# ==============================================================================

FROM ros2-source AS ros2-deps

WORKDIR /opt/ros2-src


RUN rosdep update


RUN apt-get update \
    && rosdep install \
        --from-paths src \
        --ignore-src \
        --rosdistro jazzy \
        -r \
        -y \
        --skip-keys \
        "urdfdom_headers rti-connext-dds-6.0.1 python3-catkin-pkg-modules python3-vcstool python3-rosdistro-modules" \
    && rm -rf /var/lib/apt/lists/*


# ==============================================================================
# ROS 2 build
#
# IMPORTANT:
#
# build/ and log/ are BuildKit cache mounts.
#
# If colcon dies after 30 minutes, the Docker layer itself is discarded,
# but compiled CMake/Ninja objects in the cache mount can survive.
#
# /opt/ros/jazzy is NOT a cache mount because it must become part of the image.
# ==============================================================================

FROM ros2-deps AS ros2-build

WORKDIR /opt/ros2-src


RUN \
    --mount=type=cache,id=fern-ros2-jazzy-build,target=/opt/ros2-src/build,sharing=locked \
    --mount=type=cache,id=fern-ros2-jazzy-log,target=/opt/ros2-src/log,sharing=locked \
    colcon build \
        --merge-install \
        --install-base /opt/ros/jazzy \
        --event-handlers console_cohesion+ \
        --packages-up-to \
            rclcpp \
            rclpy \
            launch_ros \
            ros2topic \
            ros2bag \
            rosbag2_storage_mcap \
            rmw_fastrtps_cpp \
            tf2_ros \
            tf2_geometry_msgs \
            tf2_sensor_msgs \
            image_transport \
            cv_bridge \
            pcl_conversions


# Keep validation separate from the expensive compilation.
RUN test -x /opt/ros/jazzy/bin/ros2


RUN source /opt/ros/jazzy/setup.bash \
    && ros2 --help >/dev/null


# ==============================================================================
# PX4 source
# ==============================================================================

FROM ros2-build AS px4-source

WORKDIR /opt/px4


RUN git clone \
        --recursive \
        --branch "${PX4_TAG}" \
        https://github.com/PX4/PX4-Autopilot.git \
        . \
    && test "$(git rev-parse HEAD)" = "${PX4_SHA}"


# ==============================================================================
# PX4 dependencies
# ==============================================================================

FROM px4-source AS px4-deps

WORKDIR /opt/px4


# PX4's own Ubuntu setup is intentionally isolated from compilation so a failed
# make does not cause this setup to run again.
RUN bash Tools/setup/ubuntu.sh --no-sim-tools


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        libeigen3-dev \
        protobuf-compiler \
        pkg-config \
        libxml2-utils \
    && rm -rf /var/lib/apt/lists/*


# ==============================================================================
# PX4 build
# ==============================================================================

FROM px4-deps AS px4-build

WORKDIR /opt/px4


RUN make px4_sitl_default


RUN test -x build/px4_sitl_default/bin/px4


# ==============================================================================
# Micro XRCE-DDS Agent source
# ==============================================================================

FROM px4-build AS xrce-source

WORKDIR /opt/xrce


RUN git clone \
        --branch "${XRCE_TAG}" \
        https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
        . \
    && test "$(git rev-parse HEAD)" = "${XRCE_SHA}"


# ==============================================================================
# Micro XRCE-DDS Agent build
#
# The CMake build directory is disposable and therefore safe as a BuildKit
# cache mount. /usr/local/bin/MicroXRCEAgent remains part of the image.
# ==============================================================================

FROM xrce-source AS xrce-build

WORKDIR /opt/xrce


RUN \
    --mount=type=cache,id=fern-xrce-build,target=/opt/xrce/build,sharing=locked \
    source /opt/ros/jazzy/setup.bash \
    && cmake \
        -B build \
        -DUAGENT_USE_SYSTEM_FASTDDS=ON \
        -DCMAKE_PREFIX_PATH=/opt/ros/jazzy \
    && cmake --build build -j"$(nproc)" \
    && cmake --install build \
    && ldconfig


RUN test -x /usr/local/bin/MicroXRCEAgent


# ==============================================================================
# Fern ROS external dependencies
#
# Clone these BEFORE copying local source.
#
# This means editing:
#
#   ros2/src/control/...
#
# does not force Docker to clone MAVROS/PX4 repositories again.
# ==============================================================================

FROM xrce-build AS drone-ros-deps

WORKDIR /opt/drone-sim/ros2


RUN mkdir -p src


RUN git clone \
        https://github.com/PX4/px4_msgs.git \
        src/px4_msgs \
    && git -C src/px4_msgs checkout --detach "${PX4_MSGS_SHA}" \
    && test \
        "$(git -C src/px4_msgs rev-parse HEAD)" \
        = "${PX4_MSGS_SHA}"


RUN git clone \
        https://github.com/PX4/px4_ros_com.git \
        src/px4_ros_com \
    && git -C src/px4_ros_com checkout --detach "${PX4_ROS_COM_SHA}" \
    && test \
        "$(git -C src/px4_ros_com rev-parse HEAD)" \
        = "${PX4_ROS_COM_SHA}"


RUN git clone \
        https://github.com/ros-geographic-info/geographic_info.git \
        src/geographic_info \
    && git -C src/geographic_info checkout --detach "${GEOGRAPHIC_INFO_SHA}" \
    && test \
        "$(git -C src/geographic_info rev-parse HEAD)" \
        = "${GEOGRAPHIC_INFO_SHA}"


RUN git clone \
        https://github.com/mavlink/mavros.git \
        src/mavros \
    && git -C src/mavros checkout --detach "${MAVROS_SHA}" \
    && test \
        "$(git -C src/mavros rev-parse HEAD)" \
        = "${MAVROS_SHA}"


# Install external repository dependencies while this layer is still independent
# of Fern's frequently changing local source.
RUN source /opt/ros/jazzy/setup.bash \
    && apt-get update \
    && rosdep install \
        --from-paths \
            src/px4_msgs \
            src/px4_ros_com \
            src/geographic_info \
            src/mavros \
        --ignore-src \
        --rosdistro jazzy \
        -r \
        -y \
    && rm -rf /var/lib/apt/lists/*


# ==============================================================================
# Fern ROS local source
# ==============================================================================

FROM drone-ros-deps AS drone-ros-source

WORKDIR /opt/drone-sim/ros2


COPY ros2/src/interfaces src/interfaces
COPY ros2/src/control src/control
COPY ros2/src/bringup src/bringup


# Only this smaller dependency layer is invalidated when local package metadata
# changes.
RUN source /opt/ros/jazzy/setup.bash \
    && apt-get update \
    && rosdep install \
        --from-paths \
            src/interfaces \
            src/control \
            src/bringup \
        --ignore-src \
        --rosdistro jazzy \
        -r \
        -y \
    && rm -rf /var/lib/apt/lists/*


# ==============================================================================
# Fern ROS workspace build
# ==============================================================================

FROM drone-ros-source AS drone-ros-build

WORKDIR /opt/drone-sim/ros2


RUN \
    --mount=type=cache,id=fern-drone-ros-build,target=/opt/drone-sim/ros2/build,sharing=locked \
    --mount=type=cache,id=fern-drone-ros-log,target=/opt/drone-sim/ros2/log,sharing=locked \
    source /opt/ros/jazzy/setup.bash \
    && colcon build \
        --merge-install \
        --event-handlers console_cohesion+ \
        --packages-up-to \
            px4_msgs \
            px4_ros_com \
            geographic_msgs \
            mavros_msgs \
            interfaces \
            control \
            bringup


RUN test -x install/control/lib/control/offboard_control


RUN test -f install/bringup/share/bringup/launch/perception.launch.py


# ==============================================================================
# Cosys-AirSim source
# ==============================================================================

FROM drone-ros-build AS cosys-source

WORKDIR /opt/Cosys-AirSim


RUN git clone \
        --recursive \
        https://github.com/Cosys-Lab/Cosys-AirSim.git \
        . \
    && git checkout --detach "${COSYS_SHA}" \
    && test "$(git rev-parse HEAD)" = "${COSYS_SHA}"


# Keep patches separate from the upstream clone.
COPY simulator/unreal/patches/cosys-airsim \
    /opt/drone-sim/simulator/unreal/patches/cosys-airsim


# ==============================================================================
# Cosys-AirSim ROS workspace preparation
# ==============================================================================

FROM cosys-source AS cosys-ros-source

WORKDIR /opt/Cosys-AirSim


RUN mkdir -p /airsim_root \
    && for d in cmake AirLib MavLinkCom; do \
        ln -s "/opt/Cosys-AirSim/${d}" "/airsim_root/${d}"; \
    done \
    && cp -r external /airsim_root/external \
    && cp -r ros2 /airsim_root/ros2


RUN for patch_file in \
        /opt/drone-sim/simulator/unreal/patches/cosys-airsim/*.patch; \
    do \
        if ! grep -qE '^+++ b/Unreal/' "${patch_file}"; then \
            patch \
                -d /airsim_root \
                -p1 \
                --forward \
                --batch \
                < "${patch_file}"; \
        fi; \
    done


# ==============================================================================
# Cosys-AirSim ROS wrapper build
# ==============================================================================

FROM cosys-ros-source AS cosys-ros-build

WORKDIR /airsim_root/ros2


RUN \
    --mount=type=cache,id=fern-cosys-ros-build,target=/airsim_root/ros2/build,sharing=locked \
    --mount=type=cache,id=fern-cosys-ros-log,target=/airsim_root/ros2/log,sharing=locked \
    source /opt/ros/jazzy/setup.bash \
    && source /opt/drone-sim/ros2/install/setup.bash \
    && colcon build \
        --merge-install \
        --event-handlers console_cohesion+


RUN test -x \
    install/airsim_ros_pkgs/lib/airsim_ros_pkgs/airsim_node


# ==============================================================================
# Unreal Engine / Cosys-AirSim plugin
#
# UE's own Clang toolchain must be used.
# ==============================================================================

FROM cosys-ros-build AS cosys-ue-build

USER root


RUN if ! id -u ue4 >/dev/null 2>&1; then \
        useradd -m -s /bin/bash ue4; \
    fi


RUN chown -R \
    ue4:ue4 \
    /opt/Cosys-AirSim \
    /airsim_root \
    /opt/drone-sim


USER ue4

WORKDIR /opt/Cosys-AirSim


RUN ./build.sh --ue-root /home/ue4/UnrealEngine


# ==============================================================================
# Final runtime
# ==============================================================================

FROM cosys-ue-build AS runtime

USER root


# ------------------------------------------------------------------------------
# QGroundControl
#
# QGC is baked into the image and checksum verified. Fern therefore does not
# require a mutable QGC download at runtime.
# ------------------------------------------------------------------------------

RUN curl \
        -fL \
        --retry 3 \
        -o /tmp/qgc.AppImage \
        "${QGC_URL}" \
    && echo \
        "${QGC_SHA256}  /tmp/qgc.AppImage" \
        | sha256sum --check - \
    && chmod 0755 /tmp/qgc.AppImage \
    && mkdir -p /opt/qgc \
    && cd /opt/qgc \
    && /tmp/qgc.AppImage --appimage-extract >/dev/null \
    && rm -f /tmp/qgc.AppImage \
    && test -x /opt/qgc/squashfs-root/AppRun


RUN if ! id -u qgcuser >/dev/null 2>&1; then \
        useradd -m -s /bin/bash qgcuser; \
    fi \
    && mkdir -p /home/qgcuser/tmp \
    && chown -R \
        qgcuser:qgcuser \
        /home/qgcuser \
        /opt/qgc


# ------------------------------------------------------------------------------
# Runtime scripts/configuration
# ------------------------------------------------------------------------------

COPY runtime/local/qgc-entrypoint.sh \
    /usr/local/bin/qgc-entrypoint.sh

COPY runtime/runpod/interactive-entrypoint.sh \
    /usr/local/bin/drone-sim-interactive-entrypoint

COPY runtime/runpod/vnc-desktop.sh \
    /usr/local/bin/drone-sim-vnc-desktop

COPY runtime/runpod/start-px4.sh \
    /usr/local/bin/drone-sim-start-px4

COPY runtime/runpod/readiness.sh \
    /usr/local/bin/drone-sim-readiness

COPY runtime/runpod/sim_up_local.sh \
    /opt/drone-sim/runtime/runpod/sim_up_local.sh

COPY runtime/local/airsim_rpc_client.py \
    /opt/drone-sim/runtime/local/airsim_rpc_client.py

COPY simulator/unreal/settings.json \
    /opt/drone-sim/settings.json


RUN chmod 0755 \
        /usr/local/bin/qgc-entrypoint.sh \
        /usr/local/bin/drone-sim-interactive-entrypoint \
        /usr/local/bin/drone-sim-vnc-desktop \
        /usr/local/bin/drone-sim-start-px4 \
        /usr/local/bin/drone-sim-readiness \
        /opt/drone-sim/runtime/runpod/sim_up_local.sh \
    && mkdir -p \
        /var/log/drone-sim \
        /home/ue4/.config/Epic \
    && chown -R \
        ue4:ue4 \
        /var/log/drone-sim \
        /home/ue4/.config/Epic


EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/drone-sim-interactive-entrypoint"]
