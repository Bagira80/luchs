##
# @file
# @details This file defines functions/macros which make programming language specific settings.
#          * A macro that sets the required minimal C++ standard to be used.
#


##
# @name set_minimum_required_cxx_standard()
# @brief Sets the minimal required C++ standard (and disables extensions).
#
macro( set_minimum_required_cxx_standard )
    # Require at least C++20 (and turn off non-standard compiler extensions).
    set( CMAKE_CXX_STANDARD          20 )
    set( CMAKE_CXX_STANDARD_REQUIRED ON )
    set( CMAKE_CXX_EXTENSIONS        OFF )
    # Fix value of __cplusplus on MSVC and Clang-Cl.
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR
       (CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
       add_compile_options( "/Zc:__cplusplus" )
   endif()
endmacro()
