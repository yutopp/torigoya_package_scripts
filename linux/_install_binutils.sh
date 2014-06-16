#!/bin/bash

# include
. _import.sh

#
FTPMirror="http://ftp.gnu.org/gnu"

# please set this variable...
#BINUTILS
#BINUTILSVersion
#BINUTILSZipped

#
BINUTILSPath="binutils"
PackageVersion=`make_package_version $BINUTILSVersion`

# set workspace path
BuildWorkPath=`buildworkpath $BINUTILSPath`
cd $BuildWorkPath

# BINUTILS
expand_data $FTPMirror $BINUTILS $BINUTILSVersion $BINUTILSZipped

#
IFS="?";read Cur Conf <<< "`init_build $BINUTILS $BINUTILSVersion`"
cd $Cur

# configure
../$Conf/configure \
    --build=$BinarySystem \
    --host=$BinarySystem \
    --disable-nls \
    --disable-multilib \
&& make_rpm_package $BINUTILS $BINUTILSVersion
