#!/bin/bash

# includes
. _import.sh

case "$ProgramVersion" in
    "5.1.0")
        BranchName="d5ad84b309d0d97d3955fb1f62a96fc262df2b76" ;;
    "head")
        BranchName="master" ;;
    *)
        BranchName="gcc-${ProgramVersion:0:1}_${ProgramVersion:2:1}_${ProgramVersion:4:1}-release" ;;
esac

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath
if [ -e prerequisites ]; then
    cd prerequisites
    rm -rf gmp_src
    rm -rf mpfr_src
    rm -rf mpc_src
    cd ..
else
    mkdir prerequisites
fi

if [ -e gcc ]; then
    cd gcc
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
if [ -e gmp ]; then
    cd gmp
    hg pull -u
    cd ..
else
    hg clone https://gmplib.org/repo/gmp/
fi
cp -r gmp -T prerequisites/gmp_src || exit -1
cd prerequisites/gmp_src
case "$GMPVersion" in
    "head")
        GMPBranchName="default" ;;
    "6.0.0" | "6.0.0a")
        GMPBranchName="301ce2788826" ;;
    "5.1.1")
        GMPBranchName="rel-5.1.1" ;;
    *)
        echo "cannot catch GNU MP $GMPVersion by _install_gcc scripts" && exit -1
esac
hg up $GMPBranchName
autoreconf -i
automake
./.bootstrap
./configure --prefix=`pwd`/../gmp/$GMPVersion
(make -j$CPUCore && make install) || exit -1
cd ../..

#
if [ ! -e mpfr ]; then
    mkdir mpfr
    mkdir mpfr/tags
fi
if [ $MPFRVersion == "head" ]; then
    cd mpfr
    if [ -e trunk ]; then
        cd trunk
        svn up
        cd ..
    else
        svn co svn://scm.gforge.inria.fr/svn/mpfr/trunk trunk
    fi
    cp -r trunk -T ../prerequisites/mpfr_src || exit -1
    cd ../prerequisites/mpfr_src
    ./autogen.sh
    ./configure --prefix=`pwd`/../mpfr/$MPFRVersion --with-gmp=`pwd`/../gmp/$GMPVersion
    (make -j$CPUCore && make install) || exit -1
    cd ../..
else
    cd mpfr/tags
    if [ ! -e $MPFRVersion ]; then
        svn co svn://scm.gforge.inria.fr/svn/mpfr/tags/$MPFRVersion $MPFRVersion
    fi
    cp -r $MPFRVersion -T ../../prerequisites/mpfr_src || exit -1
    cd ../../prerequisites/mpfr_src
    autoreconf -i
    ./configure --prefix=`pwd`/../mpfr/$MPFRVersion --with-gmp=`pwd`/../gmp/$GMPVersion
    (make -j$CPUCore && make install) || exit -1
    cd ../..
fi

#
if [ -e mpc ]; then
    cd mpc
    git pull
    cd ..
else
    git clone https://gforge.inria.fr/git/mpc/mpc.git
fi
cp -r mpc -T prerequisites/mpc_src || exit -1
cd prerequisites/mpc_src
if [ "$MPCVersion" != "head" ]; then
    git checkout $MPCVersion
fi
autoreconf -i
./configure --prefix=`pwd`/../mpc/$MPCVersion --with-gmp=`pwd`/../gmp/$GMPVersion --with-mpfr=`pwd`/../mpfr/$MPFRVersion
(make -j$CPUCore && make install) || exit -1
cd ../..

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
IFS="?" read Cur Conf <<< "`make_build_dir gcc`"
cd $Cur

InstallPrefix=$InstallPath/gcc.$ProgramVersion

case "$ProgramVersion" in
    "4.7.0" | "4.7.1" | "4.7.2")
        export MAKEINFO=missing ;;
esac

if [ "$ProgramVersion" == "head" ]; then
    Bootstrap=disable
else
    Bootstrap=enable
fi

mkdir -p $InstallPrefix

cp -r $Conf/prerequisites/gmp/$GMPVersion/* $InstallPrefix/
cp -r $Conf/prerequisites/mpfr/$MPFRVersion/* $InstallPrefix/
cp -r $Conf/prerequisites/mpc/$MPCVersion/* $InstallPrefix/


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
    --${Bootstrap}-bootstrap \
    --with-gmp=$InstallPrefix \
    --with-mpfr=$InstallPrefix \
    --with-mpc=$InstallPrefix \

export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

if [ "$ProgramVersion" == "head" ]; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$InstallPrefix/lib
    make_edge_deb_from_dir gcc $RevedPackageVersion $Cur $InstallPrefix
else
    make_versioned_deb_from_dir gcc $PackageVersion $Cur $InstallPrefix
fi

regenerate_proc_profiles
