#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ -e llvm ]; then
    cd llvm
    cd tools
    if [ -e clang ]; then
        rm -rf clang
    fi
    cd ..
    cd projects
    if [ -e compiler-rt ]; then
        rm -rf compiler-rt
    fi
    if [ -e libcxx ]; then
        rm -rf libcxx
    fi
    if [ -e libcxxabi ]; then
        rm -rf libcxxabi
    fi
    cd ..
    cd ..
fi


# 1
if [ -e llvm ]; then
    cd llvm
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/llvm
fi

# 2
if [ -e clang ]; then
    cd clang
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
if [ -e extra ]; then
    cd extra
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/clang-tools-extra extra
fi

# 4
if [ -e compiler-rt ]; then
    cd compiler-rt
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/compiler-rt
fi

# 5
if [ -e libcxx ]; then
    cd libcxx
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/libcxx
fi

# 6
if [ -e libcxxabi ]; then
    cd libcxxabi
    git checkout master
    git pull
    cd ..
else
    git clone http://llvm.org/git/libcxxabi
fi

if [ "$ProgramVersion" == "head" ]; then
    RevedPackageVersion="$PackageVersion.$GitClangVersion"
    cd extra
    ExtraPath=`pwd`
    cd ..
    cd llvm/tools
    cp -r ../../clang clang || exit -1
    cd ../..
    cd llvm/tools/clang/tools
    cp -r $ExtraPath extra || exit -1
    cd ../../../..
    cd compiler-rt
    CompilerRTPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $CompilerRTPath compiler-rt || exit -1
    cd ../..
    cd libcxx
    LibCXXPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $LibCXXPath libcxx || exit -1
    cd ../..
    cd libcxxabi
    LIBCXXABIPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $LIBCXXABIPath libcxxabi || exit -1
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
    if [ $IntegerPackageVersion -ge 32 ]; then
        cd extra
        git checkout release_$IntegerPackageVersion
        ExtraPath=`pwd`
        cd ..
        cd llvm/tools
        cp -r ../../clang clang || exit -1
        cd ../..
        cd llvm/tools/clang/tools
        cp -r $ExtraPath extra || exit -1
        cd ../../../..
        cd compiler-rt
        git checkout release_$IntegerPackageVersion
        CompilerRTPath=`pwd`
        cd ..
        cd llvm/projects
        cp -r $CompilerRTPath compiler-rt || exit -1
        cd ../..
    fi
    cd libcxx
    git checkout release_$IntegerPackageVersion
    LibCXXPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $LibCXXPath libcxx || exit -1
    cd ../..
    cd libcxxabi
    if [ $IntegerPackageVersion -ge 32 -a $IntegerPackageVersion -le 35 ]; then
      git checkout release_32
    else
      git checkout release_$IntegerPackageVersion
    fi
    LIBCXXABIPath=`pwd`
    cd ..
    cd llvm/projects
    cp -r $LIBCXXABIPath libcxxabi || exit -1
    cd ../..
    echo "Version => $PackageVersion"
fi

#
IFS="?" read Cur Conf <<< "`make_build_dir clang`"
cd $Cur

# This is Edge version, so DO NOT USE RevedPackageVersion
InstallPrefix=$InstallPath/$Program.$ProgramVersion

########

# This is Edge version, so DO NOT USE versioned_deb
cmake -G "Unix Makefiles" \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_INSTALL_PREFIX=$InstallPrefix \
    -DLLVM_LIBDIR_SUFFIX=64 \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O3" \
    -DCMAKE_CXX_FLAGS="-O3 -std=c++11" \
    -DLLVM_INCLUDE_EXAMPLES=Off \
    $Conf/llvm
if [ "$ProgramVersion" == "head" ]; then
    make_edge_deb_from_dir $Program $RevedPackageVersion $Cur $InstallPrefix
else
    make_versioned_deb_from_dir $Program $PackageVersion $Cur $InstallPrefix
fi
