#!/bin/bash

source init.sh

# Default to 'bash' if no arguments are provided
args="$@"
if [ -z "$args" ]; then
  sudo -u $(id -un $VUID) "/opt/android/android-studio/bin/studio.sh"
else
  echo $@
  "$@"
fi
