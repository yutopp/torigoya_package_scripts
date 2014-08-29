#!/bin/bash

# include
. _import.sh

# regargs "openjdk-7-jdk" is already installed

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
if [ "$ProgramVersion" == "head" ]; then
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

    InstallPrefix=$InstallPath/java9.head

    echo $InstallDir

    mkdir test_build
    cd test_build
    export LANG=C

    # This is Edge version, so DO NOT USE versioned_deb
    bash ../configure \
        --prefix=$InstallPrefix \
    && make \
    && make_deb_from_dir_simple $PackageName $RevedPackageVersion $Cur/java9/test_build $InstallPrefix "" "bash -c 'find $InstallPrefix -perm 600 | xargs chmod 644'"

else
    echo 'not supported'
    exit -1
fi
