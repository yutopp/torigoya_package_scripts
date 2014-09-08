#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if cd llvm; then
    cd tools
    if [ -e clang ]; then
        rm -rf clang
    fi
    cd ..
    cd projects
    if [ -e compiler-rt ]; then
        rm -rf compiler-rt
    fi
    cd ..
    cd ..
fi


# 1
if cd llvm; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/llvm
fi

# 2
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
# 3
if cd extra; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/clang-tools-extra extra
fi
# 4
if cd compiler-rt; then
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/compiler-rt
fi

if [ "$ProgramVersion" == "head" ]; then
    RevedPackageVersion="$PackageVersion.$GitClangVersion"
    cd extra
    ExtraPath=`pwd`
    cd ..
    cd llvm/tools
    cp -r ../../clang clang
    cd ../..
    cd llvm/tools/clang/tools
    cp -r $ExtraPath extra
    cd ../../../..
    cd compiler-rt
    CompilerRTPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $CompilerRTPath compiler-rt
    cd ../..
    echo "Version => $RevedPackageVersion"
else
    IntegerPackageVersion=${ProgramVersion:0:1}${ProgramVersion:2:1}
    cd llvm
    git checkout release_$IntegerPackageVersion
    cd ..
    cd clang
    git checkout release_$IntegerPackageVersion
    cd ..
    if [ $IntegerPackageVersion -gt 32 ]; then
        cd extra
        git checkout release_$IntegerPackageVersion
        cd ..
        cd compiler-rt
        git checkout release_$IntegerPackageVersion
        cd ..
        cd extra
        ExtraPath=`pwd`
        cd ..
        cd llvm/tools
        cp -r ../../clang clang
        cd ../..
        cd llvm/tools/clang/tools
        cp -r $ExtraPath extra
        cd ../../../..
        cd compiler-rt
        CompilerRTPath=`pwd`
        cd ..
        cd llvm/projects
        cp -r $CompilerRTPath compiler-rt
        cd ../..
    fi
    echo "Version => $PackageVersion"
fi

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
    --enable-targets=host-only
if [ "$ProgramVersion" == "head" ]; then
    make_edge_deb_from_dir clang $RevedPackageVersion $Cur $InstallPrefix
else
    make_versioned_deb_from_dir clang $PackageVersion $Cur $InstallPrefix
fi
