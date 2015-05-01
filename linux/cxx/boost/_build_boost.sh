#!/bin/bash

# include
. _import.sh


# please set this variable...
#Program
#ProgramVersion
#Toolset
#ToolsetVersion

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ -e boost ]; then
    cd boost
    git checkout master
    git pull
    git submodule update
else
    git clone --recursive https://github.com/boostorg/boost
    cd boost
fi

if [ "$ProgramVersion" == "head" ]; then
    git checkout develop
    git submodule update
    GitBoostVersion=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$GitBoostVersion"
    echo "Version => $RevedPackageVersion"
else
    git checkout $Program-$ProgramVersion
    git submodule update
    cd tools/build
    git checkout develop
    cd ../..
    echo "Version => $PackageVersion"
fi
rm -rf project-config.jam*

cd ..
IFS="?" read Cur Conf <<< "`make_build_dir boost-package`"
cd $Conf/boost

if [ "$ReuseBuildDir" == "0" ]; then
    if [ -e bin.v2 ]; then
        sudo rm -rf bin.v2
    fi
fi

InstallPrefix=${InstallPath}/${Program}.${ProgramVersion}/${Toolset}.${ToolsetVersion}
set_toolset_environment "c++" $Toolset $ToolsetVersion
./bootstrap.sh --prefix=$InstallPrefix --with-toolset=$Toolset
./b2 headers
./b2 install -j$CPUCore --prefix=$InstallPrefix --toolset=$Toolset link=static,shared variant=release --without-mpi --without-iostreams --without-python $ToolsetBjamOption
