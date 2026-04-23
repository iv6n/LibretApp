cmake_minimum_required(VERSION 3.22)
project(libret_core LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(libret_core STATIC
  src/libret_secure_api.cc
)

target_include_directories(libret_core PUBLIC include)

if(NOT MSVC)
  target_compile_options(libret_core PRIVATE -fvisibility=hidden)
endif()
