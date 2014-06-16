#!/bin/bash

# includes
. _import.sh

#
FTPMirror="ftp://mirrors.kernel.org/gnu"

# please set this variable...(example)
#GCC="gcc"
#GCCVersion="4.8.0"
#GCCZipped="tar.bz2"
#
#GMP="gmp"
#GMPVersion="5.1.1"
#GMPZipped="tar.bz2"
#
#MPFR="mpfr"
#MPFRVersion="3.1.2"
#MPFRZipped="tar.bz2"
#
#MPC="mpc"
#MPCVersion="1.0.1"
#MPCZipped="tar.gz"

#svn://gcc.gnu.org/svn/gcc/trunk

#
PackageVersion=`make_package_version $GCCVersion`

# set workspace path
BasePath="gcc"
BuildWorkPath=`buildworkpath $BasePath`
cd $BuildWorkPath

# GCC
expand_data $FTPMirror $GCC $GCCVersion $GCCZipped with_version

# GMP
expand_data $FTPMirror $GMP $GMPVersion $GMPZipped

# MPFR
expand_data $FTPMirror $MPFR $MPFRVersion $MPFRZipped

# MPC
expand_data $FTPMirror $MPC $MPCVersion $MPCZipped

#
cp -r $GMP-$GMPVersion $GCC-$GCCVersion/$GMP
cp -r $MPFR-$MPFRVersion $GCC-$GCCVersion/$MPFR
cp -r $MPC-$MPCVersion $GCC-$GCCVersion/$MPC

#
IFS="?";read Cur Conf <<< "`init_build $GCC $GCCVersion`"
cd $Cur

InstallDir=$InstallPath/$GCC-$PackageVersion

# configure
../$Conf/configure \
    --prefix=$InstallDir \
    --enable-languages=c,c++,fortran,objc,obj-c++ \
    --build=$BinarySystem \
    --host=$BinarySystem \
    --target=$BinarySystem \
    --with-mpfr-include=$BuildWorkPath/$GCC-$GCCVersion/$MPFR/src \
    --with-mpfr-lib=$Cur/$MPFR/src/.libs \
    --program-suffix=-$PackageVersion \
    --disable-nls \
    --disable-multilib \
    --disable-libstdcxx-pch \
    --disable-bootstrap \
&& make_versioned_deb_from_dir $GCC $PackageVersion $Cur $InstallDir
