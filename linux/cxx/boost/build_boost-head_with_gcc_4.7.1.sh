#!/bin/bash

#
Program="boost"
ProgramVersion="head"
Toolset="gcc"
ToolsetVersion="4.7.1"
ToolsetBjamOption='cxxflags="-std=c++11"'

export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# call
. ./cxx/boost/_build_boost.sh
