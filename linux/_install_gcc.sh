#!/bin/bash

# includes
. _import.sh

GMPDir="${GMPVersion%a}"

case "$ProgramVersion" in
    "head")
        BranchName="master" ;;
    "4.7.0")
        BranchName="93c5ebd"
        export MAKEINFO=missing
        ;;
    "4.7.1")
        BranchName="0e3097e" ;;
    "4.7.2")
        BranchName="c9b304a" ;;
    "4.7.3")
        BranchName="f22940c" ;;
    "4.7.4")
        BranchName="ae10eb8" ;;
    "4.7")
        BranchName="ae10eb8" ;;
    "4.8.0")
        BranchName="e9c762e" ;;
    "4.8.1")
        BranchName="caa62b4" ;;
    "4.8.2")
        BranchName="9bcca88" ;;
    "4.8.3")
        BranchName="6bbf0de" ;;
    "4.8")
        BranchName="6bbf0de" ;;
    "4.9.0")
        BranchName="a7aa383" ;;
    "4.9.1")
        BranchName="c6fa1b4" ;;
    "4.9.2")
        BranchName="c1283af" ;;
    "4.9")
        BranchName="c6fa1b4" ;;
    *)
        echo "GCC $ProgramVersion is not registered."
        exit -1
        ;;
esac

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

if [ -e gcc ]; then
    cd gcc
    rm -rf gmp
    rm -rf mpfr
    rm -rf mpc
    git checkout master
    git pull
    git checkout $BranchName
    cd ..
else
    git clone git://gcc.gnu.org/git/gcc.git gcc
    cd gcc
    git checkout $BranchName
    cd ..
fi

#
if [ ! -e gmp-$GMPDir ]; then
    wget https://ftp.gnu.org/gnu/gmp/gmp-$GMPVersion.tar.xz -O gmp-$GMPVersion.tar.xz
    expand_tar gmp-$GMPVersion.tar.xz || exit -1
fi
cp gmp-$GMPDir gcc/gmp || exit -1

#
if [ ! -e mpfr-$MPFRVersion ]; then
    wget http://www.mpfr.org/mpfr-$MPFRVersion/mpfr-$MPFRVersion.tar.xz -O mpfr-$MPFRVersion.tar.xz
    expand_tar mpfr-$MPFRVersion.tar.xz || exit -1
fi
cp mpfr-$MPFRVersion gcc/mpfr || exit -1

#
if [ ! -e mpc-$MPCVersion ]; then
    wget http://www.multiprecision.org/mpc/download/mpc-$MPCVersion.tar.gz -O mpc-$MPCVersion.tar.gz
    expand_tar mpc-$MPCVersion.tar.gz || exit -1
fi
cp mpc-$MPCVersion gcc/mpc || exit -1


if [ "$ProgramVersion" == "head" ]; then
    cd gcc
    Rev=`get_git_rev`
    RevedPackageVersion="$PackageVersion.$Rev"
    echo "Version => $RevedPackageVersion"
    cd ..
else
    echo "Version => $PackageVersion"
fi

#
IFS="?" read Cur Conf <<< "`make_build_dir gcc-build`"
cd $Cur

InstallPrefix=$InstallPath/gcc.$ProgramVersion

# configure
$Conf/gcc/configure \
    --prefix=$InstallPrefix \
    --enable-languages=c,c++,fortran,objc,obj-c++ \
    --build=$BinarySystem \
    --host=$BinarySystem \
    --target=$BinarySystem \
    --disable-nls \
    --disable-multilib \
    --disable-libstdcxx-pch \
    --disable-bootstrap \
    --with-mpfr-include=$Conf/gcc/mpfr/src \
    --with-mpfr-lib=$Cur/mpfr/src/.libs

if [ "$ProgramVersion" == "head" ]; then
    C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/x86_64-linux-gnu
    CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/x86_64-linux-gnu
    make_edge_deb_from_dir gcc $RevedPackageVersion $Cur $InstallPrefix
else
    C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/x86_64-linux-gnu
    CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/x86_64-linux-gnu
    make_versioned_deb_from_dir gcc $PackageVersion $Cur $InstallPrefix
fi
