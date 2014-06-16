#!/bin/bash

# include
. _import.sh

# please set this variable...
#Dart
#DartVersion

RawPackageVersion=$DartVersion
#
PackageName="dart"
PackageVersion=`make_package_version $DartVersion`

# set workspace path
BuildWorkPath=`buildworkpath $PackageName`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $PackageName $PackageVersion`"
cd $Cur

#
if [ "$DartVersion" == "stable" ]; then
    #
    if [ "$ReuseBuildDir" == "0" ]; then
        #
        wget http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
        unzip dartsdk-linux-x64-release.zip
    fi

    # This is Edge(un NUMBERED stable) version, so USE RawPackageVersion
    InstallDir=$InstallPath/$PackageName-$RawPackageVersion

cat <<EOF > Makefile
dummy:
	echo dummy

all:
	echo DO NOTHING

install:
	mkdir $InstallDir

	chmod 755 dart-sdk
	find dart-sdk -perm 700 | xargs chmod 755
	find dart-sdk -perm 600 | xargs chmod 644

	cp -r dart-sdk/* $InstallDir/.
EOF

    # This is Edge version, so DO NOT USE versioned_deb
    make_deb_from_dir $PackageName $PackageVersion $Cur $InstallDir

else
    echo "NONONONOON"
    exit -1
fi
