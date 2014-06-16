#!/bin/bash

# include
. _import.sh


# please set this variable...
#BOOST
#BOOSTVersion
#BOOSTZipped

#
BOOSTPath="boost"
PackageVersion=`make_package_version $BOOSTVersion`

# set workspace path
BuildWorkPath=`buildworkpath $BOOSTPath`
cd $BuildWorkPath

#
IFS="?";read Cur Conf <<< "`init_build $BOOST $BOOSTVersion`"
cd $Cur

#
if [ "$BOOSTVersion" == "trunk" ]; then
    echo "not supported"
    exit -1

else
    # BOOST
    BoostFileName=boost_`echo "$BOOSTVersion" | sed -s 's/\./_/g'`
    if [ "$ReuseBuildDir" == "0" ]; then
        wget -c "http://sourceforge.net/projects/boost/files/boost/$BOOSTVersion/$BoostFileName.$BOOSTZipped/download"
        tar -xvf download
    fi

    #
    cd $BoostFileName

    # configure
    ./bootstrap.sh

    InstallDir=$InstallPath/boost-$PackageVersion
    rm -rf $InstallDir

cat <<EOF > Makefile
dummy:
	echo dummy

install:
	mkdir $InstallDir
	./b2 install -j8 --prefix=$InstallDir link=static,shared variant=release --with-system --with-program_options
EOF

    # make install
    make_versioned_deb_from_dir $BOOST $PackageVersion $Cur/$BoostFileName $InstallDir
fi
