#!/bin/bash

# include
. _import.sh

# please set this variable...
#Node
#NodeVersion

RawPackageVersion=$NodeVersion
#
PackageName="node"
PackageVersion=`make_package_version $RawPackageVersion`

# set workspace path
BuildWorkPath=`buildworkpath $PackageName`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $PackageName $PackageVersion`"
cd $Cur

#
if [ "$RawPackageVersion" == "head" ]; then

    #
    if [ ! -e node ]; then
        git clone https://github.com/joyent/node.git
    fi

    cd node
    git checkout master
    git pull origin master

    GitVersion=`git log --pretty=format:"%H" -1 | cut -c 1-10`

    RevedPackageVersion="$PackageVersion.$GitVersion"
    echo "Version => $RevedPackageVersion"

    # This is Edge version, so USE RawPackageVersion
    InstallDir=$InstallPath/$PackageName-$RawPackageVersion

    # This is Edge version, so DO NOT USE versioned_deb
    # configure
    ./configure \
        --prefix=$InstallDir \
    && make_deb_from_dir $PackageName $RevedPackageVersion $Cur/node $InstallDir

else
    echo "not supported"
    exit -1
fi
