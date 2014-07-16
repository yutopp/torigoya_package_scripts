#!/bin/bash

# include
. _import.sh

# regargs "openjdk-6-jdk" is already installed

#
PackageName='java9'
PackageVersion=`make_package_version $RawPackageVersion`

# set workspace path
BuildWorkPath=`buildworkpath $PackageName`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $PackageName $PackageVersion`"
cd $Cur

#
if [ "$RawPackageVersion" == "trunk" ]; then
    #
    if [ ! -e java9 ]; then
        hg clone http://hg.openjdk.java.net/jdk9/jdk9 java9
    fi

    cd java9

    if [ -e ./make/scripts/hgforest.sh ]; then
        sh ./make/scripts/hgforest.sh pull -u
    else
        sh ./get_source.sh
    fi


    HgVersion=`hg id -i`

    RevedPackageVersion="$PackageVersion.$HgVersion"
    echo "Version => $RevedPackageVersion"


    # This is Edge version, so USE RawPackageVersion
    InstallDir=$InstallPath/$PackageName-$RawPackageVersion

    echo $InstallDir

    mkdir test_build
    cd test_build
    export LANG=C

    # This is Edge version, so DO NOT USE versioned_deb
    bash ../configure \
        --prefix=$InstallDir \
    && make \
    && make_deb_from_dir_simple $PackageName $RevedPackageVersion $Cur/java9/test_build $InstallDir "" "bash -c 'find $InstallDir -perm 600 | xargs chmod 644'"

else
    echo 'not supported'
    exit -1
fi
