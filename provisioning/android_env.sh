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

export ANDROID_HOME=/studio-data/Android
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export CMAKE_BIN_PATH=$ANDROID_HOME/cmake/$CMAKE_VERSION/bin
export PATH=$CMAKE_BIN_PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH

