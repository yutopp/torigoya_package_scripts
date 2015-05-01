#!/bin/bash

#
Program="boost"
ProgramVersion="head"
Toolset="clang"
ToolsetVersion="3.2"
ToolsetBjamOption='cxxflags="-std=c++11" cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++" linkflags="-lc++" linkflags="-lc++abi"'

# call
. ./cxx/boost/_build_boost.sh
