#!/bin/bash

#
Program="boost"
ProgramVersion="head"
Toolset="gcc"
ToolsetVersion="4.8.0"
ToolsetBjamOption='cxxflags="-std=c++11"'

# call
. ./cxx/boost/_build_boost.sh
