#!/bin/bash

#
Program="boost"
ProgramVersion="1.56.0"
Toolset="gcc"
ToolsetVersion="head"
ToolsetBjamOption='cxxflags="-std=c++11"'

# call
. ./cxx/boost/_build_boost.sh
