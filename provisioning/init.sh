#!/bin/bash

if [ ! -d /studio-data ]; then
	exit
fi

export VUID=`stat -c '%u' /studio-data`
export VGID=`stat -c '%g' /studio-data`
export USER=android

if [ "$VUID" != "0" ]; then
	export HOME=/home/android
else
	export HOME=/root
fi

if [ "$VUID" != "0" ]; then
	groupadd -g $VGID -r $USER
	useradd -u $VUID -g $VGID -s /bin/bash --create-home -r $USER

	adduser $USER libvirt
	adduser $USER kvm
	#Change password
	usermod -aG sudo $USER
	usermod -aG plugdev $USER
	chmod 777 /dev/kvm > /dev/null
fi

su $USER <<'EOF'
cd $HOME
mkdir -p .config/Google
mkdir -p Android
ln -s /studio-data/profile/AndroidStudio2023.3 .config/Google/AndroidStudio2023.3
ln -s /studio-data/profile/android .android
ln -s /studio-data/profile/java .java
ln -s /studio-data/profile/gradle .gradle
ln -s /studio-data/Android Android/Sdk
ln -s /studio-data/AndroidStudioProjects AndroidStudioProjects

mkdir -p /studio-data/Android || exit
mkdir -p /studio-data/profile/android || exit
mkdir -p /studio-data/profile/gradle || exit
mkdir -p /studio-data/profile/java || exit
mkdir -p /studio-data/profile/AndroidStudio2023.3 || exit
mkdir -p /studio-data/AndroidStudioProjects || exit

yes | /opt/android/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
    	"cmake;$CMAKE_VERSION" \
        "ndk;${NDK_VERSION}" || exit
EOF
