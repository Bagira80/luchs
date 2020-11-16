##
# @file
# @details Overrides some CMake defaults for platform information when using language C++.
# @note This will be automatically loaded by CMake when language C++ was selected.
#


##
# Change the default for some CMAKE_CXX_FLAGS variables.
#
set( CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O3 -DNDEBUG -g" )
if (${CMAKE_GENERATOR} MATCHES "Ninja" )
    set( CMAKE_CXX_FLAGS_INIT "-fdiagnostics-color=always" )
endif()
