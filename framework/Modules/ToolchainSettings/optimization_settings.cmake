##
# @file
# @details This file defines functions which enable different optimizations.
#          * A function that enables link-time optimization.
#


##
# @name enable_link_time_optimization()
# @brief Enables setting compiler-flags for link-time optimization.
#
function( enable_link_time_optimization )
    include( CheckIPOSupported )
    check_ipo_supported( RESULT is_supported OUTPUT error_reason LANGUAGES CXX C )
    if (is_supported)
        set( CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE PARENT_SCOPE )
    else()
        message( SEND_ERROR "Link-time optimization (LTO/IPO) is not supported: ${error_reason}" )
    endif()
endfunction()
