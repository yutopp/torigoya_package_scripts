#!/bin/bash

# include
. _import.sh

# regargs "openjdk-7-jdk" is already installed
# saku of kuniku
# packages for bootstrap
sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev
sudo apt-get install -y libcups2-dev
sudo apt-get install -y libfreetype6-dev
sudo apt-get install -y libasound2-dev
sudo apt-get install -y ccache

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
        rm -rf test_build
    fi
    mkdir test_build
    cd test_build
    export LANG=C

    # This is Edge version, so DO NOT USE versioned_deb
    bash ../configure \
         --prefix=$InstallPrefix \
        && make all JOBS=4 \
        && make install \
        && bash -c 'find $InstallPrefix -perm 600 | xargs chmod 644' \
        && pack_edge_deb_from_dir java8 \
                                  $RevedPackageVersion \
                                  $Cur/java8/test_build \
                                  $InstallPrefix \
                                  ""

else
    echo 'not supported'
    exit -1
fi
