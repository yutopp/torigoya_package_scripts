#!/bin/bash

# include
. _import.sh

#
FTPMirror="http://ftp.gnu.org/gnu"

# please set this variable...
#GLIBC
#GLIBCVersion
#GLIBCZipped
# glibc is able to be conpiled by GCC <= 4.6
if [ -x "`which gcc-4.6`" ]; then
    GLIBCC="gcc-4.6"
elif [ -x "`which gcc46`" ]; then
    GLIBCC="gcc46"
else
    exit 10
fi


#
GLIBCPath="glibc"
PackageVersion=`make_package_version $GLIBCVersion`

# set workspace path
BuildWorkPath=`buildworkpath $GLIBCPath`
cd $BuildWorkPath

# GLIBC
expand_data $FTPMirror $GLIBC $GLIBCVersion $GLIBCZipped

#
IFS="?";read Cur Conf <<< "`init_build $GLIBC $GLIBCVersion`"
cd $Cur

# configure
../$Conf/configure \
    --prefix=/home/yutopp/chroot-test/torigoya \
    --libexecdir=/home/yutopp/chroot-test/torigoya/lib64/glibc \
    --libdir=/home/yutopp/chroot-test/torigoya/lib64 \
    --build=$BinarySystem \
    --host=$BinarySystem \
    --disable-profile \
    "CC=$GLIBCC" \
&& make_rpm_package $GLIBC $PackageVersion
