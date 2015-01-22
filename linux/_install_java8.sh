#!/bin/bash

# include
. _import.sh

# regargs "openjdk-7-jdk" is already installed
# saku of kuniku
# packages for bootstrap
sudo apt-get -y update
sudo apt-get -y install openjdk-7-jdk
sudo apt-get -y install libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev
sudo apt-get -y install libcups2-dev
sudo apt-get -y install libfreetype6-dev
sudo apt-get -y install libasound2-dev
sudo apt-get -y install ccache

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
if [ "$ProgramVersion" == "head" ]; then
    ##################################################
    # install HEAD package
    ##################################################

    #
    if [ ! -e java8 ]; then
        hg clone http://hg.openjdk.java.net/jdk8/jdk8 java8
    else
        cd java8
        hg paths default
        hg pull -u || exit -1
        cd ../
    fi

    cd java8
    bash ./get_source.sh

    HgVersion=`hg id -i`

    RevedPackageVersion="$PackageVersion.$HgVersion"
    echo "Version => $RevedPackageVersion"

    InstallPrefix=$InstallPath/java8.head

    echo $InstallDir


    if [ -e test_build ]; then
        if [ "$ReuseBuildDir" == "0" ]; then
            rm -rf test_build
        fi
    else
        mkdir test_build
    fi
    cd test_build
    Cur=`pwd`

    export LANG=C

    # This is Edge version, so DO NOT USE versioned_deb
    bash ../configure \
         --prefix=$InstallPrefix \
        && make all JOBS=4 \
        && make install \
        && bash -c "find $InstallPrefix -perm 600 | xargs --no-run-if-empty chmod 644" \
        && pack_edge_deb_from_dir java8 \
                                  $RevedPackageVersion \
                                  $Cur \
                                  $InstallPrefix \
                                  ""

else
    echo 'not supported'
    exit -1
fi
