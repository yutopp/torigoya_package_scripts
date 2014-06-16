#!/bin/bash

# includes
. _import.sh

#
PackageVersion=`make_package_version $TargetVersion`

# set workspace path
BasePath=$TargetName
BuildWorkPath=`buildworkpath $BasePath`
cd $BuildWorkPath



if [ "$TargetVersion" == "trunk" ]; then
    #
    svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx

    #
    IFS="?";read Cur Conf <<< "`init_build $TargetName $TargetVersion`"
    cd $Cur

    InstallDir=$InstallPath/$TargetName

    #
    echo | g++ -Wp,-v -x c++ - -fsyntax-only

    # FIXME
    CC=clang CXX=clang++ \
        cmake -G "Unix Makefiles" \
        -DLIBCXX_CXX_ABI=libsupc++ \
        -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.8;/usr/include/x86_64-linux-gnu/c++/4.8" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$InstallDir \
        ./../libcxx \
    && make_deb_from_dir $TargetName $PackageVersion $Cur $InstallDir

else
    echo "Not supported"
    exit -1
fi
