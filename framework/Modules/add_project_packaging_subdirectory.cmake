##
# @file
# @details Defines a function which uses `add_subdirectory` for processing a subdirectory "packaging"
#          that possibly might be generated on-the-fly with some useful default settings.
# @note This function should be used by each CMakeLists.txt that wants to package its targets.
#

include_guard()


##
# @name add_project_packaging_subdirectory() )
# @brief Changes into the subdirectory "packaging" if it exists or creates one from a template and changes into that.
#
macro( add_project_packaging_subdirectory )
    # Load CMakeLists.txt for packaging.
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/packaging/CMakeLists.txt")
        add_subdirectory( "packaging" )
    elseif (EXISTS "${LUCHS_TEMPLATES_DIR}/Packaging_CMakeLists.txt.in")
        configure_file( "${LUCHS_TEMPLATES_DIR}/Packaging_CMakeLists.txt.in"
                        "${CMAKE_CURRENT_BINARY_DIR}/packaging/CMakeLists.txt"
                        COPYONLY )
        add_subdirectory( "${CMAKE_CURRENT_BINARY_DIR}/packaging" "packaging" )
    endif()
endmacro()
