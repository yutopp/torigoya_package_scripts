#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ "$ProgramVersion" == "head" ]; then
    ##################################################
    # install HEAD package
    ##################################################
    echo "not supported"
    exit -1

else
    ##################################################
    # install VERSIONED package
    ##################################################
    top_version=`echo $ProgramVersion | sed 's/^\([0-9]\+\)\.\([0-9]\+\)\(.*\)/\1\.\2/'`

    wget http://caml.inria.fr/pub/distrib/ocaml-$top_version/ocaml-$ProgramVersion.tar.gz -O ocaml-$ProgramVersion.tar.gz

    tar zxvf ocaml-$ProgramVersion.tar.gz

    cd ocaml-$ProgramVersion
    Cur=`pwd`

    #
    InstallPrefix=$InstallPath/ocaml.$PackageVersion

    #
    ./configure \
        -prefix $InstallPrefix \
        -no-curses \
        && make world.opt \
        && make install \
        && pack_versioned_deb_from_dir ocaml $PackageVersion $Cur $InstallPrefix "--depends libncurses5-dev"
fi
