#!/bin/bash

# include
. _import.sh

# please set this variable...
#LLVM
#LLVMVersion

#
PackageVersion=`make_package_version $LLVMVersion`

#
LLVMPath="llvm"
BuildWorkPath=`buildworkpath $LLVMPath`
cd $BuildWorkPath


#
if [ "$LLVMVersion" == "head" ]; then
    #
    svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm-trunk

    cd llvm-trunk
    SVNLLVMVersion=`svn info | grep '^Revision:' | sed 's/^Revision: \([0-9]\+\)/\1/'`
    cd ../


    RevedPackageVersion="$PackageVersion.$SVNLLVMVersion"
    echo "Version => $RevedPackageVersion"

    #
    IFS="?";read Cur Conf <<< "`init_build llvm trunk`"
    cd $Cur

    # This is Edge version, so DO NOT USE RevedPackageVersion
    InstallPrefix=$InstallPath/$LLVM-$LLVMVersion

    # Configure and build LLVM and Clang
    # This is Edge version, so DO NOT USE versioned_deb
    cmake \
        -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DCMAKE_INSTALL_PREFIX=$InstallPrefix \
        ../$Conf \
    && make_deb_from_dir $LLVM $RevedPackageVersion $Cur $InstallPrefix

else
    #########################################
    if [ "$ReuseBuildDir" == "0" ]; then
        wget http://llvm.org/releases/3.4/llvm-3.4.src.tar.gz
        tar zxvf llvm-3.4.src.tar.gz
    fi

    #
    IFS="?";read Cur Conf <<< "`init_build $LLVM $LLVMVersion`"
    cd $Cur

    InstallPrefix=$InstallPath/$LLVM-$LLVMVersion

    # Configure and build LLVM and Clang
    # This is Edge version, so DO NOT USE versioned_deb
    cmake \
        -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DCMAKE_INSTALL_PREFIX=$InstallPrefix \
        ../$Conf \
    && make_versioned_deb_from_dir $LLVM $LLVMVersion $Cur $InstallPrefix
fi
