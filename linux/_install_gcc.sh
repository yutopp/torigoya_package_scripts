#!/bin/bash

# includes
. _import.sh

#
FTPMirror="ftp://mirrors.kernel.org/gnu"

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ "$ProgramVersion" == "head" ]; then
    ##################################################
    # install HEAD package
    ##################################################
    if [ -e gcc ]; then
        rm -rf gcc
    fi
    git clone --depth 1 git://gcc.gnu.org/git/gcc.git gcc

    #
    wget $FTPMirror/gmp/gmp-$GMPVersion.tar.bz2 -O gmp-$GMPVersion.tar.bz2
    tar jxf gmp-$GMPVersion.tar.bz2

    #
    wget $FTPMirror/mpfr/mpfr-$MPFRVersion.tar.bz2 -O mpfr-$MPFRVersion.tar.bz2
    tar jxf mpfr-$MPFRVersion.tar.bz2

    #
    wget $FTPMirror/mpc/mpc-$MPCVersion.tar.gz -O mpc-$MPCVersion.tar.gz
    tar xzvf mpc-$MPCVersion.tar.gz

    ls -al

    #
    cp -r gmp-$GMPVersion gcc/gmp
    cp -r mpfr-$MPFRVersion gcc/mpfr
    cp -r mpc-$MPCVersion gcc/mpc

    #
    cd gcc

    Rev=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$Rev"
    echo "Version => $RevedPackageVersion"

    #
    IFS="?";read Cur Conf <<< "`make_build_dir gcc-build`"
    cd $Cur

    InstallPrefix=$InstallPath/gcc.head

    # configure
    $Conf/configure \
        --prefix=$InstallPrefix \
        --enable-languages=c,c++,fortran,objc,obj-c++ \
        --build=$BinarySystem \
        --host=$BinarySystem \
        --target=$BinarySystem \
        --with-mpfr-include=$BuildWorkPath/gcc/mpfr/src \
        --with-mpfr-lib=$Cur/mpfr/src/.libs \
        --disable-nls \
        --disable-multilib \
        --disable-libstdcxx-pch \
        --disable-bootstrap \
        && make_edge_deb_from_dir gcc $RevedPackageVersion $Cur $InstallPrefix

else
    ##################################################
    # install VERSIONED package
    ##################################################
    wget $FTPMirror/gcc/gcc-$ProgramVersion/gcc-$ProgramVersion.tar.bz2 -O gcc-$ProgramVersion.tar.bz2
    tar jxf gcc-$ProgramVersion.tar.bz2

    #
    wget $FTPMirror/gmp/gmp-$GMPVersion.tar.bz2 -O gmp-$GMPVersion.tar.bz2
    tar jxf gmp-$GMPVersion.tar.bz2

    #
    wget $FTPMirror/mpfr/mpfr-$MPFRVersion.tar.bz2 -O mpfr-$MPFRVersion.tar.bz2
    tar jxf mpfr-$MPFRVersion.tar.bz2

    #
    wget $FTPMirror/mpc/mpc-$MPCVersion.tar.gz -O mpc-$MPCVersion.tar.gz
    tar xzvf mpc-$MPCVersion.tar.gz

    ls -al

    #
    cp -r gmp-$GMPVersion gcc-$ProgramVersion/gmp
    cp -r mpfr-$MPFRVersion gcc-$ProgramVersion/mpfr
    cp -r mpc-$MPCVersion gcc-$ProgramVersion/mpc

    #
    cd gcc-$ProgramVersion

    #
    IFS="?";read Cur Conf <<< "`make_build_dir gcc-build`"
    cd $Cur

    InstallPrefix=$InstallPath/gcc.$PackageVersion

    # configure
    $Conf/configure \
        --prefix=$InstallPrefix \
        --enable-languages=c,c++,fortran,objc,obj-c++ \
        --build=$BinarySystem \
        --host=$BinarySystem \
        --target=$BinarySystem \
        --with-mpfr-include=$BuildWorkPath/gcc-$ProgramVersion/mpfr/src \
        --with-mpfr-lib=$Cur/mpfr/src/.libs \
        --disable-nls \
        --disable-multilib \
        --disable-libstdcxx-pch \
        --disable-bootstrap \
        && make_versioned_deb_from_dir gcc $PackageVersion $Cur $InstallPrefix
fi
