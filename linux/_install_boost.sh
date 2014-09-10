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

if cd boost; then
    git checkout master
    git pull
    git submodule update
else
    git clone --recursive https://github.com/boostorg/boost
    cd boost
    ./bootstrap.sh
    ./b2 headers
fi

if [ "$ProgramVersion" == "head" ]; then
    GitBoostVersion=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$GitBoostVersion"
    echo "Version => $RevedPackageVersion"
else
    git checkout $Program-$ProgramVersion
    git submodule update
    echo "Version => $PackageVersion"
fi

cd ..
IFS="?" read Cur Conf <<< "`make_build_dir boost-package`"
cd $Conf/boost

if [ "$ReuseBuildDir" == "0" ]; then
    if [ -e bin.v2 ]; then
        sudo rm -rf bin.v2
    fi
fi

InstallPrefix=$InstallPath/boost.$ProgramVersion
./b2 install -j$CPUCore --prefix=$InstallPrefix link=static,shared variant=release --without-mpi --without-iostreams --without-python
cd $Cur
if [ "$ProgramVersion" == "head" ]; then
    pack_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    pack_versioned_deb_from_dir $Program $PackageVersion $Cur $InstallPrefix
fi

