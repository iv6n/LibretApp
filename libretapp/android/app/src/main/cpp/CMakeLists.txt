cmake_minimum_required(VERSION 3.22)
project(libret_core LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(LIBRET_CORE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../native/libret_core)

add_library(libret_core SHARED
    ${LIBRET_CORE_DIR}/src/libret_secure_api.cc
)

target_include_directories(libret_core
    PUBLIC
        ${LIBRET_CORE_DIR}/include
)

if(ANDROID)
    target_link_libraries(libret_core log)
endif()

# Keep native export surface minimal for easier audits.
if(NOT MSVC)
    target_compile_options(libret_core PRIVATE -fvisibility=hidden)
endif()
