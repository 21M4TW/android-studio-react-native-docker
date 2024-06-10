FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
# https://developer.android.com/studio#command-tools
ARG SDK_VERSION=commandlinetools-linux-9477386_latest.zip
ENV ANDROID_BUILD_VERSION=34
ENV ANDROID_TOOLS_VERSION=34.0.0
ENV NDK_VERSION=26.1.10909125
ARG NODE_VERSION=18
ARG WATCHMAN_VERSION=4.9.0
ENV CMAKE_VERSION=3.22.1

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION}

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}

# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        file \
        gcc \
        git \
        g++ \
        gnupg2 \
        libc++1-11 \
        libgl1 \
        libtcmalloc-minimal4 \
        make \
        openjdk-17-jdk-headless \
        openssh-client \
        patch \
        python3 \
        python3-distutils \
        rsync \
        ruby \
        ruby-dev \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
        # Dev libraries requested by Hermes
        libicu-dev \
        # Dev dependencies required by linters
        jq \
        shellcheck \
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# install nodejs using n
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n \
    && bash n $NODE_VERSION \
    && rm n \
    && npm install -g n \
    && npm install -g yarn

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && rm -rf ${ANDROID_HOME}/.android

#RUN dpkg --add-architecture i386
#RUN apt-get update && apt-get install -y \
#        build-essential git neovim wget unzip sudo \
#        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
#        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim\
#        qemu qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils libnotify4 libglu1 libqt5widgets5 openjdk-8-jdk openjdk-11-jdk xvfb \
#        && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
        build-essential neovim wget \
        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
	libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils \
	qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libnotify4 libglu1 libqt5widgets5 xvfb \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Install Flutter
#ARG FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.6-stable.tar.xz
#ARG FLUTTER_VERSION=3.13.6

#RUN wget "$FLUTTER_URL" -O flutter.tar.xz
#RUN tar -xvf flutter.tar.xz
#RUN rm flutter.tar.xz

#Android Studio
#ARG ANDROID_STUDIO_VERSION=2022.3.1.20
#ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz
ARG ANDROID_STUDIO_VERSION=2023.3.1.19
ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/"$ANDROID_STUDIO_VERSION"/android-studio-"$ANDROID_STUDIO_VERSION"-linux.tar.gz

RUN cd ${ANDROID_HOME} && wget "$ANDROID_STUDIO_URL" -O android_studio.tar.gz && tar xzvf android_studio.tar.gz && rm android_studio.tar.gz

ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

COPY provisioning/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY provisioning/android_env.sh ${ANDROID_HOME}/android_env.sh
COPY provisioning/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/*
COPY provisioning/51-android.rules /etc/udev/rules.d/51-android.rules

ENTRYPOINT [ "/usr/local/bin/docker_entrypoint.sh" ]
