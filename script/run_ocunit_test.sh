#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR/.."

##
## Configuration Variables
##

# The build configuration to use.
if [ -z "$XCCONFIGURATION" ]
then
    XCCONFIGURATION="Debug"
fi

# The workspace to build.
#
# If not set and no workspace is found, the -workspace flag will not be passed
# to xcodebuild.
if [ -z "$XCWORKSPACE" ]
then
    XCWORKSPACE=$(ls -d *.xcworkspace 2>/dev/null | head -n 1)
fi

# A bootstrap script to run before building.
#
# If this file does not exist, it is not considered an error.
BOOTSTRAP="$SCRIPT_DIR/bootstrap"

# A whitespace-separated list of default targets or schemes to build, if none
# are specified on the command line.
#
# Individual names can be quoted to avoid word splitting.
DEFAULT_TARGETS=

# Extra build settings to pass to xcodebuild.
XCODEBUILD_SETTINGS="ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES"

##
## Build Process
##

if [ -z "$*" ]
then
    # lol recursive shell script
    if [ -n "$DEFAULT_TARGETS" ]
    then
        echo "$DEFAULT_TARGETS" | xargs "$SCRIPT_DIR/cibuild"
    else
        xcodebuild -list | awk -f "$SCRIPT_DIR/targets.awk" | xargs "$SCRIPT_DIR/cibuild"
    fi

    exit $?
fi

if [ -f "$BOOTSTRAP" ]
then
    echo "*** Bootstrapping..."
    bash "$BOOTSTRAP" || exit $?
fi

echo "*** The following targets will be built:"

for target in "$@"
do
    echo "$target"
done

echo "*** Cleaning all targets..."
xcodebuild -alltargets clean OBJROOT="$PWD/build" SYMROOT="$PWD/build" $XCODEBUILD_SETTINGS

run_xcodebuild ()
{
    local scheme=$1

    if [ -n "$XCWORKSPACE" ]
    then
        xcodebuild -workspace "$XCWORKSPACE" -scheme "$scheme" -configuration "$XCCONFIGURATION" -sdk iphonesimulator build OBJROOT="$PWD/build" SYMROOT="$PWD/build" $XCODEBUILD_SETTINGS
    else
        xcodebuild -scheme "$scheme" -configuration "$XCCONFIGURATION" build OBJROOT="$PWD/build" SYMROOT="$PWD/build" -sdk iphonesimulator $XCODEBUILD_SETTINGS
    fi

    local status=$?

    return $status
}

build_scheme ()
{
    local scheme=$1

    run_xcodebuild "$scheme" 2>&1 | awk -f "$SCRIPT_DIR/xcodebuild.awk"

    local awkstatus=$?
    local xcstatus=${PIPESTATUS[0]}

    if [ "$xcstatus" -eq "65" ]
    then
        # This probably means that there's no scheme by that name. Give up.
        echo "*** Error building scheme $scheme -- perhaps it doesn't exist"
    elif [ "$awkstatus" -eq "1" ]
    then
        return $awkstatus
    fi

    return $xcstatus
}

echo "*** Building..."

for scheme in "$@"
do
    build_scheme "$scheme" || exit $?
done
