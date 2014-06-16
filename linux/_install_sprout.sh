#!/bin/bash

# include
. _import.sh

# please set this variable...
#SPROUT
#SPROUTVersion

RawPackageVersion=$SPROUTVersion
#
PackageName="sprout"
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
        git clone https://github.com/bolero-MURAKAMI/Sprout.git
    fi
    cd Sprout
    git pull origin master
    cd ..


    # header only
    # This is Edge version, so USE RawPackageVersion
    InstallDir=$InstallPath/sprout-$RawPackageVersion

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
	mkdir --parents $IncludePath
	cp -r Sprout/sprout $IncludePath/.
EOF

    # DO NOT contain package version to name
    # This is Edge version, so DO NOT USE versioned_deb
    make_deb_from_dir $PackageName $PackageVersion $Cur $InstallDir

else
    echo "NONONONOON"
    exit -1
fi
