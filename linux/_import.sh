#!/bin/bash

# 1. read config
. _config.sh

# 2. read parameter
. _param.sh

# 3. do init
. _init.sh

#
# functions
#
_script_dir=`pwd`


#
function tar_option() {
    case $1 in
        "tar.bz2")
            echo "xvjf"
            ;;
        "tar.gz")
            echo "xvzf"
            ;;
        *)
            echo "Un supported tar_option " $1
            exit -1
            ;;
    esac
}


#
function buildworkpath() {
    cd $BuildWorkspaceBasePath
    if [ ! -e $1 ]; then
        mkdir $1
    fi
    cd $1

    WorkPath="_work"
    if [ ! -e $WorkPath ]; then
        mkdir $WorkPath
    fi
    cd $WorkPath

    pwd
}


#
function expand_data() {
    Mirror=$1
    DataName=$2
    DataVersion=$3
    DataZipped=$4

    if [ ! -e $DataName-$DataVersion.$DataZipped ]; then
        case $5 in
            "with_version")
                wget $Mirror/$DataName/$DataName-$DataVersion/$DataName-$DataVersion.$DataZipped
                ;;
            "simple")
                wget $Mirror/$DataName-$DataVersion.$DataZipped
                ;;
            *)
                wget $Mirror/$DataName/$DataName-$DataVersion.$DataZipped
                ;;
        esac
    fi

    if [ ! -e $DataName-$DataVersion ]; then
        tar $(tar_option $DataZipped) $DataName-$DataVersion.$DataZipped
    fi
}


# deprecated
function init_build() {
    DataName=$1
    DataVersion=$2

    BuildPath=$DataName-$DataVersion-build

    if [ "$ReuseBuildDir" == "0" ]; then
        if [ -e $BuildPath ]; then
            sudo rm -rf $BuildPath
        fi
    fi
    if [ ! -e $BuildPath ]; then
        mkdir $BuildPath
    fi
    cd $BuildPath

    echo `pwd`"?"$DataName-$DataVersion
}

#
function make_build_dir() {
    BaseName=$1
    BuildPath=$BaseName-build
    Conf=`pwd`

    if [ "$ReuseBuildDir" == "0" ]; then
        if [ -e $BuildPath ]; then
            sudo rm -rf $BuildPath
        fi
    fi
    if [ ! -e $BuildPath ]; then
        mkdir $BuildPath
    fi
    cd $BuildPath
    Cur=`pwd`

    echo $Cur"?"$Conf
}


function make_package_version() {
    target_version=$1

    case $target_version in
        'head')
            # edge version
            echo "999.$Year.$Month.$Day"
            ;;

        'dev')
            # edge version
            echo "888.$Year.$Month.$Day"
            ;;

        'stable')
            # edge version
            echo "777.$Year.$Month.$Day"
            ;;

        *)
            # normal version
            echo "$target_version" | sed -s 's/(_|-)/\./g'
            ;;
    esac
}

function get_git_rev() {
    echo `git log --pretty=format:"%H" -1 | cut -c 1-10`
}

function get_svn_rev() {
    echo `svn info | grep '^Revision:' | sed 's/^Revision: \([0-9]\+\)/\1/'`
}

function copy_deb_to_holder() {
    current_dir=$1
    cp -v $current_dir/*.deb $PlaceholderResultPath/.
}

function make_versioned_deb_from_dir() {
    # $1 = package name
    # $2 = version
    # $3 = current directory
    # $4 = installed path
    # $5 = fpm option
    # $6 = exec after install
    make_edge_deb_from_dir $1-$2 $2 $3 $4 "$5" "$6"
}

function pack_versioned_deb_from_dir() {
    # $1 = package name
    # $2 = version
    # $3 = current directory
    # $4 = installed path
    # $5 = fpm option
    pack_edge_deb_from_dir $1-$2 $2 $3 $4 "$5"
}


function make_edge_deb_from_dir() {
    # --force option of FPM means, overwrites if package existed
    ( make all -j$CPUCore || make -j$CPUCore ) \
        && make install \
        && eval "$6" \
        && pack_edge_deb_from_dir $1 $2 $3 $4 "$5"
}

function pack_edge_deb_from_dir() {
    # Ex,
    # fpm -s dir -t rpm -n "slashbin" -v 1.0 /bin /sbin
    # makes "slashbin_1.0.x86_64.rpm"

    # with package name prefix
    package_name=$PackageNamePrefix$1
    package_version=$2
    current_dir=$3
    installed_dir=$4
    fpm_options="$5"

    #
    expected_pkg_name=$package_name"_"$package_version"_"$Arch".deb"

    # --force option of FPM means, overwrites if package existed

    if [[ ! -z $fpm_options ]]; then
        (eval fpm "--force -s dir -t deb -n $package_name -v $package_version --deb-compression xz $fpm_options $installed_dir") \
            && copy_deb_to_holder $current_dir
    else
        fpm --force -s dir -t deb -n $package_name -v $package_version --deb-compression xz $installed_dir \
            && copy_deb_to_holder $current_dir
    fi
}
