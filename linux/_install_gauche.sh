#!/bin/bash

# include
. _import.sh

# please set this variable...
#Program
#ProgramVersion

#
PackageVersion=`make_package_version $ProgramVersion`

#
ProgramPath="gauche"
BuildWorkPath=`buildworkpath $ProgramPath`
cd $BuildWorkPath


#
if [ "$ProgramVersion" == "head" ]; then
    if [ ! -e Gauche ]; then
        git clone https://github.com/shirok/Gauche.git
    fi
    cd Gauche
    git pull

    GitVersion=`git log --pretty=format:"%H" -1 | cut -c 1-10`
    echo $GitVersion

    RevedPackageVersion="$PackageVersion.GitVersion"

    ./DIST gen

    ./configure \
        --prefix=$InstallPath/$Program-$RevedPackageVersion \
    && make_deb_package $Program-$RevedPackageVersion $RevedPackageVersion `pwd`

else
    # from package
    wget http://prdownloads.sourceforge.net/gauche/Gauche-$ProgramVersion.tgz
    tar zxvf Gauche-$ProgramVersion.tgz
    cd Gauche-$ProgramVersion

    ./configure \
        --prefix=$InstallPath/$Program-$PackageVersion \
    && make_deb_package $Program-$PackageVersion $PackageVersion `pwd`

    echo "NONONONOON"
    exit -1
fi
