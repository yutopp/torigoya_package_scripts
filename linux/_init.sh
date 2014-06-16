#!/bin/bash

#
echo "========================================"
echo "====== Linux Bunchou Build System ======"
echo "========================================"
echo "build workspace base path is "$BuildWorkspaceBasePath
if [ ! -e $BuildWorkspaceBasePath ]; then
    echo $BuildWorkspaceBasePath " was not found."
    exit -1
fi

#
echo "(build|host|target) system is "$BinarySystem
echo "arch is "$Arch
echo "========================================"
echo "========================================"
