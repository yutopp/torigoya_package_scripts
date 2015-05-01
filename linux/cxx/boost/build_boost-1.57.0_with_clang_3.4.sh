#!/bin/bash

#
Program="boost"
ProgramVersion="1.57.0"
Toolset="clang"
ToolsetVersion="3.4"
ToolsetBjamOption='cxxflags="-std=c++11" cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++" linkflags="-lc++" linkflags="-lc++abi"'

# call
. ./cxx/boost/_build_boost.sh
