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
if cd BoostConnect; then
    git checkout master
    git pull
else
    git clone https://github.com/godai0519/BoostConnect
    cd BoostConnect
fi
cd ..
if cd twit-library; then
    git checkout master
    git pull
else
    git clone https://github.com/godai0519/twit-library
    cd twit-library
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
IncludePath=$InstallPrefix/include
#LibPath=$InstallPrefix/lib

# remove previous file
rm -rf $InstallPrefix

#
if [ "$ProgramVersion" == "head" ]; then
    mkdir $InstallPrefix
    mkdir --parents $IncludePath
#    mkdir --parents $LibPath
    cd BoostConnect
#    make target
    cp -r include/* $IncludePath/.
#    cp -r lib/* $LibPath/.
    cd ..
    cd twit-library
#    make target
    cp -r include/* $IncludePath/.
#    cp -r lib/* $LibPath/.
#    make clean
    cd ..
#    cd BoostConnect
#    make clean
#    cd ..

    # DO NOT contain package version to name
    cd $Cur
    pack_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    echo "not supported"
    exit -1
fi
