#!/bin/bash

# include
. _import.sh

#
Mirror="http:/zlib.net"

# please set this variable...
#ZLIB
#ZLIBVersion
#ZLIBZipped

#
ZLIBPath="zlib"
PackageVersion=`make_package_version $ZLIBVersion`

# set workspace path
BuildWorkPath=`buildworkpath $ZLIBPath`
cd $BuildWorkPath

# BINUTILS
expand_data $Mirror $ZLIB $ZLIBVersion $ZLIBZipped "simple"

#
IFS="?";read Cur Conf <<< "`init_build $ZLIB $ZLIBVersion`"
cd $Conf
pwd

make distclean

# configure
../$Conf/configure \
&& make_rpm_package $ZLIB $PackageVersion
