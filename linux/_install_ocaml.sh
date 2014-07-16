#!/bin/bash

# include
. _import.sh


#
PackageName='ocaml'
PackageVersion=`make_package_version $RawPackageVersion`

# set workspace path
BuildWorkPath=`buildworkpath $PackageName`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $PackageName $RawPackageVersion`"
cd $Cur


if [ "$RawPackageVersion" == "trunk" ]; then
    echo "not supported"
    exit -1
else

    top_version=`echo $RawPackageVersion | sed 's/^\([0-9]\+\)\.\([0-9]\+\)\(.*\)/\1\.\2/'`

    wget http://caml.inria.fr/pub/distrib/ocaml-$top_version/ocaml-$PackageVersion.tar.gz

    tar zxvf ocaml-$PackageVersion.tar.gz

    cd ocaml-$PackageVersion

    #
    InstallDir=$InstallPath/$PackageName-$PackageVersion

    #
    ./configure \
        -prefix $InstallDir \
        -no-curses \
    && make world.opt \
    && make_versioned_deb_from_dir_simple $PackageName $PackageVersion $Cur/ocaml-$PackageVersion $InstallDir "--depends libncurses5-dev"
fi
