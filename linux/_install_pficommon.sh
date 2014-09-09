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

#
if cd pficommon; then
    git checkout master
    git pull
else
    git clone https://github.com/pfi/pficommon
    cd pficommon
fi

if [ "$ProgramVersion" == "head" ]; then
    GitRev=`get_git_rev`
    echo "Git rev => $GitRev"
    RevedPackageVersion="$PackageVersion.$GitRev"
    echo "Version => $RevedPackageVersion"
fi

#
cd ..
IFS="?" read Cur Conf <<< "`make_build_dir $Program`"
cd $Conf

# header only
# This is Edge version, so USE RawPackageVersion
InstallPrefix=$InstallPath/$Program-$ProgramVersion

# remove previous file
rm -rf $InstallPrefix

#
if [ "$ProgramVersion" == "head" ]; then
    mkdir $InstallPrefix
    cd pficommon
    ./waf configure --prefix=$InstallPrefix
    ./waf build
    ./waf install
    cd ..

    # DO NOT contain package version to name
    cd $Cur
    pack_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    echo "not supported"
    exit -1
fi
