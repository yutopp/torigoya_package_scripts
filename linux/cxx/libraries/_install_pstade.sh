#!/bin/bash

# include
. _import.sh

# please set this variable...
#Program
#ProgramVersion

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
if cd p-stade; then
    svn up
else
    svn co https://svn.code.sf.net/p/p-stade/code/trunk ./p-stade
    cd p-stade
fi

if [ "$ProgramVersion" == "head" ]; then
    SVNRev=`get_svn_rev`
    echo "SVN rev => $SVNRev"
    RevedPackageVersion="$PackageVersion.$SVNRev"
    echo "Version => $RevedPackageVersion"
fi

#
cd ..
IFS="?" read Cur Conf <<< "`make_build_dir $Program`"
cd $Conf

InstallPrefix=$InstallPath/$Program.$ProgramVersion
IncludePath=$InstallPrefix/include

# remove previous file
rm -rf $InstallPrefix

#
if [ "$ProgramVersion" == "head" ]; then
    mkdir $InstallPrefix
    mkdir --parents $IncludePath
    cp -r p-stade/boost/boost $IncludePath/.
    cp -r p-stade/pstade/pstade $IncludePath/.


    # DO NOT contain package version to name
    cd $Cur
    pack_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    echo "not supported"
    exit -1
fi
