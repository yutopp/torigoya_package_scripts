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
if cd etude; then
    git checkout master
    git pull
else
    git clone https://github.com/gintenlabo/etude
    cd etude
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

InstallPrefix=$InstallPath/$Program.$ProgramVersion
IncludePath=$InstallPrefix/include

# remove previous file
rm -rf $InstallPrefix

#
if [ "$ProgramVersion" == "head" ]; then
    mkdir $InstallPrefix
    mkdir --parents $IncludePath
    cp -r etude/etude $IncludePath/.

    # DO NOT contain package version to name
    cd $Cur
    pack_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    echo "not supported"
    exit -1
fi
