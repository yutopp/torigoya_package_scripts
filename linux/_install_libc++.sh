#!/bin/bash

# includes
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
if cd libcxx; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/libcxx
fi
if [ "$ProgramVersion" == "head" ]; then
    cd libcxx
    GitLibCXXVersion=`get_git_rev`
    cd ../

    RevedPackageVersion="$PackageVersion.$GitLibCXXVersion"
    echo "Version => $RevedPackageVersion"
else
    IntegerPackageVersion=${ProgramVersion:0:1}${ProgramVersion:2:1}
    if [ $IntegerPackageVersion -lt 32 ]; then
        echo "Not supported"
        exit -1
    fi
    cd libcxx
    git checkout release_$IntegerPackageVersion
    cd ..
    echo "Version => $PackageVersion"
fi

#
IFS="?" read Cur Conf <<< "`make_build_dir libcxx-build`"
cd $Cur

InstallPrefix=$InstallPath/$Program.$ProgramVersion

#
CC=clang CXX=clang++ \
    cmake -G "Unix Makefiles" \
    -DLIBCXX_CXX_ABI=libsupc++ \
    -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.8;/usr/include/x86_64-linux-gnu/c++/4.8" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$InstallPrefix \
    ../libcxx
if [ "$ProgramVersion" == "head" ]; then
    make_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    make_versioned_deb_from_dir $Program $PackageVersion $Cur $InstallPrefix
fi

