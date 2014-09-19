#!/bin/bash

########################################
# WorkspacePath(Ex. /tmp)
if [ "$PARAM_WORKSPACEPATH" == "" ]; then
    echo "please specify the path of build workspace base path.[1]"
    exit -1
fi
BuildWorkspaceBasePath=$PARAM_WORKSPACEPATH

########################################
# SystemName(Ex. x86_64-linux-gnu)
if [ "$PARAM_TARGETSYSTEM" == "" ]; then
    echo "please specify the binary system(ex. x86_64-linux-gnu).[2]"
    exit -1
fi
BinarySystem=$PARAM_TARGETSYSTEM

########################################
# Arch(Ex. x86_64)
if [ "$PARAM_TARGETARCH" == "" ]; then
    echo "please specify the binary system(ex. x86_64).[3]"
    exit -1
fi
Arch=$PARAM_TARGETARCH

########################################
# InstallPath. aka.--prefix(Ex. /usr)
if [ "$PARAM_INSTALLPATH" == "" ]; then
    echo "please specify the install path(ex. /usr).[4]"
    exit -1
fi
InstallPath=$PARAM_INSTALLPATH


########################################
# Year
if [ "$PARAM_TIMESTAMP_YEAR" == "" ]; then
    echo "[ts.1]"
    exit -1
fi
Year=$PARAM_TIMESTAMP_YEAR

########################################
# Month
if [ "$PARAM_TIMESTAMP_MONTH" == "" ]; then
    echo "[ts.2]"
    exit -1
fi
Month=$PARAM_TIMESTAMP_MONTH

########################################
# Day
if [ "$PARAM_TIMESTAMP_DAY" == "" ]; then
    echo "[ts.3]"
    exit -1
fi
Day=$PARAM_TIMESTAMP_DAY

########################################
# Hour
if [ "$PARAM_TIMESTAMP_HOUR" == "" ]; then
    echo "[ts.4]"
    exit -1
fi
Hour=$PARAM_TIMESTAMP_HOUR

########################################
# Minute
if [ "$PARAM_TIMESTAMP_MIN" == "" ]; then
    echo "[ts.5]"
    exit -1
fi
Min=$PARAM_TIMESTAMP_MIN

########################################
# Second
if [ "$PARAM_TIMESTAMP_SEC" == "" ]; then
    echo "[ts.6]"
    exit -1
fi
Sec=$PARAM_TIMESTAMP_SEC


########################################
# PlaceholderResultPath
if [ "$PARAM_PLACEHOLDER_PATH" == "" ]; then
    echo "please specify the placeholder result path. [8]"
    exit -1
fi
PlaceholderResultPath=$PARAM_PLACEHOLDER_PATH

########################################
# ReuseBuildDir
if [ "$PARAM_REUSE_BUILDDIR" == "" ]; then
    ReuseBuildDir="0"
    echo "ReuseBuildDir is default setting[0]. [9]"
else
    ReuseBuildDir=$PARAM_REUSE_BUILDDIR
fi

########################################
# ReuseBuildDir
if [ "$PARAM_PACKAGE_PREFIX" == "" ]; then
    PackageNamePrefix=""
    echo "PackageNamePrefix is default setting[]. [10]"
else
    PackageNamePrefix=$PARAM_PACKAGE_PREFIX
fi
