#!/bin/bash

# include
. _import.sh

#
PackageVersion=`make_package_version $ProgramVersion`

# set workspace path
BuildWorkPath=`buildworkpath $Program`
cd $BuildWorkPath

#
if [ "$ProgramVersion" == "head" ]; then
    if [ ! -e ruby ]; then
        git clone git://github.com/ruby/ruby.git
    else
        cd ruby
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi
    cd ruby

    Rev=`get_git_rev`
    echo $Rev

    RevedPackageVersion="$PackageVersion.$Rev"

    InstallPrefix=$InstallPath/ruby.head

    autoconf && \
        ./configure --prefix=$InstallPrefix && \
        make_edge_deb_from_dir $Program $RevedPackageVersion `pwd` $InstallPrefix

else
    ##################################################
    # install VERSIONED package
    ##################################################

    g_ver=`echo "$ProgramVersion" | sed 's/^\([0-9]\+\)\.\([0-9]\+\).*/\1.\2/'`
    echo $g_ver

    if [ -e ruby-$ProgramVersion ]; then
        rm -rf ruby-$ProgramVersion
    fi
    wget http://cache.ruby-lang.org/pub/ruby/$g_ver/ruby-$ProgramVersion.tar.bz2 -O ruby-$ProgramVersion.tar.bz2
    tar jxf ruby-$ProgramVersion.tar.bz2

    cd ruby-$ProgramVersion

    Cur=`pwd`
    InstallPrefix=$InstallPath/ruby.$ProgramVersion

    autoconf && \
        ./configure --prefix=$InstallPrefix && \
        make_versioned_deb_from_dir ruby $ProgramVersion $Cur $InstallPrefix
fi
