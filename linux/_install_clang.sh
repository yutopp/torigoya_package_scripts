#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

# 1
if cd llvm; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/llvm
fi

# 2
cd llvm/tools
if cd clang; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/clang
fi

cd clang
GitClangVersion=`get_git_rev`
cd ../

cd ../..

# 3
cd llvm/tools/clang/tools
if cd extra; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/clang-tools-extra extra
fi
cd ../../../..

# 4
cd llvm/projects
if cd compiler-rt; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/compiler-rt
fi
cd ../..

if [ "$ProgramVersion" == "head" ]; then
    RevedPackageVersion="$PackageVersion.$GitClangVersion"
else
    RevedPackageVersion="$PackageVersion"
    cd llvm
    git checkout release_${ProgramVersion:0:1}${ProgramVersion:2:1}
    cd tools/clang
    git checkout release_${ProgramVersion:0:1}${ProgramVersion:2:1}
    cd tools/extra
    git checkout release_${ProgramVersion:0:1}${ProgramVersion:2:1}
    cd ../../../../projects/compiler-rt
    git checkout release_${ProgramVersion:0:1}${ProgramVersion:2:1}
    cd ../../..
fi
echo "Version => $RevedPackageVersion"

#
IFS="?" read Cur Conf <<< "`make_build_dir clang-build`"
cd $Cur

# This is Edge version, so DO NOT USE RevedPackageVersion
InstallPrefix=$InstallPath/clang.$ProgramVersion

# This is Edge version, so DO NOT USE versioned_deb
$Conf/llvm/configure \
    --prefix=$InstallPrefix \
    --host=$BinarySystem \
    --enable-optimized \
    --enable-assertions=no \
    --enable-targets=host-only \
    && make_edge_deb_from_dir clang $RevedPackageVersion $Cur $InstallPrefix

