#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $Program $PackageVersion`"
cd $Cur

#
if [ "$ProgramVersion" == "head" ]; then
    if [ "$ReuseBuildDir" == "0" ]; then
        if [ -e dmd ]; then
            rm -rf dmd
        fi

        if [ -e druntime ]; then
            rm -rf druntime
        fi

        if [ -e phobos ]; then
            rm -rf druntime
        fi
    fi

    if [ ! -e dmd ]; then
        git clone https://github.com/D-Programming-Language/dmd.git
    else
        cd dmd
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    if [ ! -e druntime ]; then
        git clone https://github.com/D-Programming-Language/druntime.git
    else
        cd druntime
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    if [ ! -e phobos ]; then
        git clone https://github.com/D-Programming-Language/phobos.git
    else
        cd phobos
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    #
    cd dmd
    Rev=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$Rev"
    echo "Version => $RevedPackageVersion"
    cd ../

    # build
    cd dmd/src
    make -f posix.mak -j$CPUCore MODEL=64
    cd ../../druntime
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd
    cd ../phobos
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd
    cd ../

    echo "DMD: build finished"

    # install
    InstallPrefix=$InstallPath/dmd.head

    #
    cd dmd/src
    mkdir -p $InstallPrefix/bin
    cp dmd $InstallPrefix/bin

    cd ../../druntime
    mkdir -p $InstallPrefix/include/d2
    cp -r import/* $InstallPrefix/include/d2

    cd ../phobos
    mkdir -p $InstallPrefix/lib
    cp generated/linux/release/64/libphobos2.a $InstallPrefix/lib    # for 64-bit version
#   cp generated/linux/release/32/libphobos2.a $InstallPrefix/lib    # for 32-bit version
    cp -r std $InstallPrefix/include/d2
    cp -r etc $InstallPrefix/include/d2
    cd ../

    Cur=`pwd`
    pack_edge_deb_from_dir dmd $RevedPackageVersion $Cur $InstallPrefix

else
    ##################################################
    # install VERSIONED package
    ##################################################

    #
    if [ "$ReuseBuildDir" == "0" ]; then
        # "dmd2" will be created on this path
        wget http://downloads.dlang.org/releases/$DMDReleaseYear/dmd.$PackageVersion.zip
        unzip -o dmd.$PackageVersion.zip
    fi

    # header only
    InstallDir=$InstallPath/dmd.$PackageVersion

    #
    if [ -e $InstallDir ]; then
        rm -rf $InstallDir
    fi

cat <<EOF > Makefile
dummy:
	echo dummy

all:
	echo dummy

install:
	mkdir $InstallDir
	mkdir $InstallDir/bin
	mkdir $InstallDir/src
	mkdir $InstallDir/lib64
	mkdir $InstallDir/bin64

	cp dmd2/linux/bin64/dmd $InstallDir/bin64/.
	cp dmd2/linux/lib64/libphobos2.a $InstallDir/lib64/.

	cp -r dmd2/src/phobos $InstallDir/src/.
	cp -r dmd2/src/druntime $InstallDir/src/.

EOF

    # package name: Ex. dmd.2.065.0_2.065.0_amd64.deb
    make_versioned_deb_from_dir $Program $PackageVersion $Cur $InstallDir
fi
