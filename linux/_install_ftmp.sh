#!/bin/bash

# include
. _import.sh

# please set this variable...
#PackageName

#
PackageName="ftmp"
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
    if [ ! -e Sprout ]; then
        git clone https://github.com/minamiyama1994/FTMP.git
    fi
    cd FTMP
    git pull origin master
    cd ..


    # header only
    # This is Edge version, so USE RawPackageVersion
    InstallDir=$InstallPath/ftmp-$RawPackageVersion

    IncludePath=$InstallDir/include

    # remove previous file
    rm -rf $InstallDir

cat <<EOF > Makefile
dummy:
	echo dummy

all:
	echo DO NOTHING

install:
	mkdir $InstallDir
	cp -r FTMP/* $InstallDir/.
EOF

    # DO NOT contain package version to name
    # This is Edge version, so DO NOT USE versioned_deb
    make_deb_from_dir $PackageName $PackageVersion $Cur $InstallDir

else
    echo "not supported"
    exit -1
fi
