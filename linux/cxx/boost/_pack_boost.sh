#!/bin/bash

# include
. _import.sh


# please set this variable...
#Program
#ProgramVersion

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

cd boost
if [ "$ProgramVersion" == "head" ]; then
    git checkout develop
    git submodule update
    ./bootstrap.sh
    ./b2 headers
    GitBoostVersion=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$GitBoostVersion"
    echo "Version => $RevedPackageVersion"
else
    echo "Version => $PackageVersion"
fi
cd ..

InstallPrefix=$InstallPath/$Program.$ProgramVersion
cd boost-package-build
if [ "$ProgramVersion" == "head" ]; then
    pack_edge_deb_from_dir $Program $RevedPackageVersion `pwd` $InstallPrefix
else
    pack_versioned_deb_from_dir $Program $PackageVersion `pwd` $InstallPrefix
fi

