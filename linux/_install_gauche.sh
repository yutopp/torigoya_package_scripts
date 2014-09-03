#!/bin/bash

# include
. _import.sh

# please set this variable...
#Program
#ProgramVersion

#
PackageVersion=`make_package_version $ProgramVersion`

#
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath


#
if [ "$ProgramVersion" == "head" ]; then
    if [ ! -e Gauche ]; then
        git clone https://github.com/shirok/Gauche.git
    else
        cd Gauche
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi
    cd Gauche

    Rev=`get_git_rev`
    echo $Rev

    RevedPackageVersion="$PackageVersion.$Rev"

    InstallPrefix=$InstallPath/gauche.head

    ./DIST gen

    ./configure \
        --prefix=$InstallPrefix \
    && make_edge_deb_from_dir $Program $RevedPackageVersion `pwd` $InstallPrefix

else
    # from package
    wget http://prdownloads.sourceforge.net/gauche/Gauche-$ProgramVersion.tgz
    tar zxvf Gauche-$ProgramVersion.tgz
    cd Gauche-$ProgramVersion

    InstallDir=$InstallPath/gauche.$PackageVersion

    ./configure \
        --prefix=$InstallDir \
    && make_versioned_deb_from_dir $Program $PackageVersion `pwd` $InstallDir
fi
