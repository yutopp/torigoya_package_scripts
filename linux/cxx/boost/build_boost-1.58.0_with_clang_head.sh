#!/bin/bash

#
Program="boost"
ProgramVersion="1.58.0"
Toolset="clang"
ToolsetVersion="head"
ToolsetBjamOption='cxxflags="-std=c++11" cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++" linkflags="-lc++" linkflags="-lc++abi"'

# call
. ./cxx/boost/_build_boost.sh
