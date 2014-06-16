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


# package name: Ex. dmd-2.065.0_2.065.0_amd64.deb
make_versioned_deb_from_dir $Program $PackageVersion $Cur $InstallDir
