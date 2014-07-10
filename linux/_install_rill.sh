#!/bin/bash

# include
. _import.sh

# please set this variable...
# TargetName
# TargetVersion

#
PackageName='rill'
PackageVersion=`make_package_version $RawPackageVersion`

# set workspace path
BuildWorkPath=`buildworkpath $PackageName`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $PackageName $PackageVersion`"
cd $Cur

#
if [ "$RawPackageVersion" == "head" ]; then
    #
    if [ ! -e rill ]; then
        git clone https://github.com/yutopp/rill.git
    fi

    cd rill
    branch_name="m@ster"
    git checkout $branch_name
    git pull origin $branch_name

    GitVersion=`git log --pretty=format:"%H" -1 | cut -c 1-10`

    RevedPackageVersion="$PackageVersion.$GitVersion"
    echo "Version => $RevedPackageVersion"

    #
    if [ "$ReuseBuildDir" == "0" ]; then
        test -e test_build && rm -rf test_build
    fi
    ! test -e test_build && mkdir test_build
    cd test_build

    # This is Edge version, so USE RawPackageVersion
    InstallDir=$InstallPath/$PackageName-$RawPackageVersion

    echo $InstallDir

    # remove previous file
    test -e $InstallDir && rm -rf $InstallDir

    # DO NOT contain package version to name
    # This is Edge version, so DO NOT USE versioned_deb
    cmake ../. \
        -DBOOST_ROOT=$InstallPath/boost-1.55.0 \
        -DCMAKE_PREFIX_PATH=$InstallPath/llvm-3.4/ \
        -DLLVM_DIR=$InstallPath/llvm-3.4/ \
        -DCMAKE_MODULE_PATH=$InstallPath/llvm-3.4/share/llvm/cmake \
        -DCMAKE_INSTALL_PREFIX=$InstallDir \
    && make_deb_from_dir $PackageName $RevedPackageVersion $Cur/rill/test_build $InstallDir

else
    echo "not supported"
    exit -1
fi
