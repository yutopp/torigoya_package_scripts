#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ "$ProgramVersion" == "head" ]; then
    # 1
    svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm

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
    IFS="?";read Cur Conf <<< "`make_build_dir clang-build`"
    cd $Cur

    # This is Edge version, so DO NOT USE RevedPackageVersion
    InstallPrefix=$InstallPath/clang.head

    # This is Edge version, so DO NOT USE versioned_deb
    $Conf/llvm/configure \
        --prefix=$InstallPrefix \
        --host=$BinarySystem \
        --enable-optimized \
        --enable-assertions=no \
        --enable-targets=host-only \
        && make_edge_deb_from_dir clang $RevedPackageVersion $Cur $InstallPrefix

else
    echo "Not supported"
    exit -1
fi
