#!/bin/bash

# include
. _import.sh

# please set this variable...
#CLANG
#CLANGVersion
#CLANGZipped


#
PackageVersion=`make_package_version $CLANGVersion`

# set workspace path
CLANGPath="clang"
BuildWorkPath=`buildworkpath $CLANGPath`
cd $BuildWorkPath

if [ "$CLANGVersion" == "trunk" ]; then
    # 1
    svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm

    cd llvm
    SVNLLVMVersion=`svn info | grep '^Revision:' | sed 's/^Revision: \([0-9]\+\)/\1/'`
    cd ../

    # 2
    cd llvm/tools
    svn co http://llvm.org/svn/llvm-project/cfe/trunk clang

    cd clang
    SVNClangVersion=`svn info | grep '^Revision:' | sed 's/^Revision: \([0-9]\+\)/\1/'`
    cd ../

    cd ../..

    # 3
    cd llvm/tools/clang/tools
    svn co http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
    cd ../../../..

    # 4
    cd llvm/projects
    svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
    cd ../..

    RevedPackageVersion="$PackageVersion.$SVNClangVersion"
    echo "Version => $RevedPackageVersion"

    #
    IFS="?";read Cur Conf <<< "`init_build $CLANG $CLANGVersion`"
    cd $Cur

    # This is Edge version, so DO NOT USE RevedPackageVersion
    InstallDir=$InstallPath/$CLANG-$CLANGVersion

    # This is Edge version, so DO NOT USE versioned_deb
    ../$conf/llvm/configure \
        --prefix=$InstallDir \
        --host=$BinarySystem \
        --enable-optimized \
        --enable-assertions=no \
        --enable-targets=host-only \
    && make_deb_from_dir $CLANG $RevedPackageVersion $Cur $InstallDir

else
    echo "Not supported"
    exit -1
fi
