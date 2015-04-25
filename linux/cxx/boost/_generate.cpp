#include<fstream>
#include<string>

void output(const std::string& boost_version, const std::string& toolset_name, const std::string& toolset_version){
  std::ofstream ofs(("build_boost-"+boost_version+"_with_"+toolset_name+"_"+toolset_version+".sh").c_str());
  ofs << R"(#!/bin/bash

#
Program="boost"
ProgramVersion=")" << boost_version << R"("
Toolset=")" << toolset_name << R"("
ToolsetVersion=")" << toolset_version << R"("
)";
  if(toolset_name == "clang")
    ofs << R"(ToolsetBjamOption='cxxflags="-std=c++11" cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++" linkflags="-lc++" linkflags="-lc++abi"'
)";
  else
    ofs << R"(ToolsetBjamOption='cxxflags="-std=c++11"'
)";
  ofs << R"(
# call
. ./cxx/boost/_build_boost.sh)" << std::endl;
}

void generate(const std::string& toolset_name, const std::string& toolset_version){
  for(int i = 6; i <= 8; ++i)
    output("1.5"+std::to_string(i)+".0", toolset_name, toolset_version);
  output("head", toolset_name, toolset_version);
}

int main(){
  for(int i = 7; i <= 9; ++i)
    for(int j = 0; j <= 4; ++j)
      if(i == 9 && j >= 3)
        break;
      else
        generate("gcc", "4."+std::to_string(i)+"."+std::to_string(j));
  for(int i = 1; i <= 1; ++i)
    for(int j = 0; j <= 0; ++j)
      generate("gcc", "5."+std::to_string(i)+"."+std::to_string(j));
  generate("gcc", "head");
  for(int i = 2; i <= 6; ++i)
    generate("clang", "3."+std::to_string(i));
  generate("clang", "head");
}
