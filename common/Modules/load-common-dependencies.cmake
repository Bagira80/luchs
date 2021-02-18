##
# @file
# @details Defines functions for loading targets of common dependencies.
#

include_guard()

include( "${CMAKE_CURRENT_LIST_DIR}/find_and_store_associated_runtime_debian_package.cmake" )


##
# @name load_common_dependency( dependency_name )
# @brief Loads the requested common dependency.
# @param dependency_name The name of the common dependency that shall be loaded.
#
function( load_common_dependency ) # dependency_name
    # List of supported dependencies.
    # Note: For each new dependency this list must be updated with its name!
    list( APPEND supported_deps
            Avro
            Boost
            GoogleTest
            Threads
            ZLib
    )

    # Try loading the requested dependency.
    # Note: For each new dependency there must be an additional "elseif" section!
    if (NOT ARGC EQUAL 0)
        set( dependency_name "${ARGV0}" )
        set( options ${ARGV} )
        list( POP_FRONT options )

        cmake_parse_arguments(_
            "GLOBAL;OPTIONAL"  # boolean options
            ""                 # one-value options
            ""                 # multi-value options
            ${options}
        )
        if (NOT __OPTIONAL)
            set( __REQUIRED "REQUIRED" )
        else()
            set( __REQUIRED )  # Set to nothing / unset variable!
        endif()

        if (NOT dependency_name IN_LIST supported_deps)
            message( SEND_ERROR "Function \"load_common_dependency\" does not support the requested dependency: ${dependency_name}" )
        elseif (dependency_name STREQUAL "Avro")
            load_common_avro( ${__GLOBAL} "${__REQUIRED}" ${__UNPARSED_ARGUMENTS} )
            return()
        elseif (dependency_name STREQUAL "Boost")
            load_common_boost( ${__GLOBAL} "${__REQUIRED}" ${__UNPARSED_ARGUMENTS} )
            return()
        elseif (dependency_name STREQUAL "GoogleTest")
            load_common_googletest( ${__GLOBAL} "${__REQUIRED}" ${__UNPARSED_ARGUMENTS} )
            return()
        elseif (dependency_name STREQUAL "Threads")
            load_common_threads( ${__GLOBAL} "${__REQUIRED}" ${__UNPARSED_ARGUMENTS} )
            return()
        elseif (dependency_name STREQUAL "ZLib")
            load_common_zlib( ${__GLOBAL} "${__REQUIRED}" ${__UNPARSED_ARGUMENTS} )
            return()
        else()
            message( SEND_ERROR "Function \"load_common_dependency\" is missing section for loading supported dependency: ${dependency_name}" )
        endif()
    else()
            message( SEND_ERROR "Function \"load_common_dependency\" is missing a parameter." )
    endif()

    # Print list of supported common dependencies.
    list( JOIN supported_deps "\n  " supported_deps_string )
    list( APPEND CMAKE_MESSAGE_INDENT "  " )
    message( NOTICE "Note: Function \"load_common_dependency\" supports the following dependencies:\n  ${supported_deps_string}\n")
    list( POP_BACK CMAKE_MESSAGE_INDENT )

    # Stop cmaking.
    message( FATAL_ERROR "Stopping due to errors!")
endfunction()


##
# @brief Searches and makes globally available: GoogleTest/GoogleMock
#
function(load_common_googletest GLOBAL)
    if (NOT TARGET GoogleTest::gtest)
        if (NOT GLOBAL)
            message( WARNING "The common dependency \"GoogleTest\" cannot be loaded locally, only globally!" )
        endif()
        include( FetchContent )
        endif()
        FetchContent_Declare(
            googletest-1.11
            GIT_REPOSITORY "https://github.com/google/googletest.git" )
            GIT_TAG        origin/release-1.11.0
        )
        # Fetch source-code and make its CMakeLists.txt available.
        FetchContent_MakeAvailable( googletest-1.11 )

        # Create alias targets with proper namespace.
        add_library( GoogleTest::gtest ALIAS gtest )
        add_library( GoogleTest::gtest_main ALIAS gtest_main )
        add_library( GoogleTest::gmock ALIAS gmock )
        add_library( GoogleTest::gmock_main ALIAS gmock_main )
    endif()
endfunction()


##
# @brief Searches and makes globally available: Avro
#
function(load_common_avro GLOBAL REQUIRED)
    if (NOT TARGET Avro::shared)
        # Search for shared library, include directory and version.
        find_library( Avro_SHARED_LIBRARY NAMES avrocpp libavrocpp ${REQUIRED} NO_DEFAULT_PATH
            PATHS /opt/ORGANIZATION/${ORGANIZATION_COMPILER_TAG}
            PATH_SUFFIXES lib lib/x86_64-linux-gnu
        )
        find_path( Avro_INCLUDE_DIR NAMES avro/version.h ${REQUIRED} NO_DEFAULT_PATH
            PATHS /opt/ORGANIZATION/${ORGANIZATION_COMPILER_TAG}
            PATH_SUFFIXES include
        )
        if (Avro_INCLUDE_DIR AND Avro_SHARED_LIBRARY)
            file( STRINGS "${Avro_INCLUDE_DIR}/avro/version.h" Avro_VERSION_MAJOR REGEX "^#[\t ]*define[\t ]+AVRO_MAJOR_VERSION[\t ]+.*" )
            string( REGEX REPLACE "#[\t ]*define[\t ]+AVRO_MAJOR_VERSION[\t ]+(.*)" "\\1" Avro_VERSION_MAJOR "${Avro_VERSION_MAJOR}" )
            file( STRINGS "${Avro_INCLUDE_DIR}/avro/version.h" Avro_VERSION_MINOR REGEX "^#[\t ]*define[\t ]+AVRO_MINOR_VERSION[\t ]+.*" )
            string( REGEX REPLACE "#[\t ]*define[\t ]+AVRO_MINOR_VERSION[\t ]+(.*)" "\\1" Avro_VERSION_MINOR "${Avro_VERSION_MINOR}" )
            file( STRINGS "${Avro_INCLUDE_DIR}/avro/version.h" Avro_VERSION_PATCH REGEX "^#[\t ]*define[\t ]+AVRO_PATCH_VERSION[\t ]+.*" )
            string( REGEX REPLACE "#[\t ]*define[\t ]+AVRO_PATCH_VERSION[\t ]+(.*)" "\\1" Avro_VERSION_PATCH "${Avro_VERSION_PATCH}" )
            # Create (imported) target and set appropriate properties.
            add_library( Avro::shared SHARED IMPORTED )
            target_include_directories( Avro::shared INTERFACE ${Avro_INCLUDE_DIR} )
            set_target_properties( Avro::shared PROPERTIES
                IMPORTED_LOCATION ${Avro_SHARED_LIBRARY}
                VERSION ${Avro_VERSION_MAJOR}.${Avro_VERSION_MINOR}.${Avro_VERSION_PATCH}
                SOVERSION ${Avro_VERSION_MAJOR}
            )
            if (GLOBAL)
                set_target_properties( Avro::shared PROPERTIES IMPORTED_GLOBAL TRUE )
            endif()
        endif()
        # Cleanup cache.
        unset( Avro_INCLUDE_DIR CACHE )
        unset( Avro_SHARED_LIBRARY CACHE )
    endif()
endfunction()


##
# @brief Searches and makes globally available: Boost
#
function(load_common_boost GLOBAL REQUIRED)
    if (NOT TARGET Boost::headers)
        find_package( Boost 1.70 ${REQUIRED} ALL CONFIG PATHS /opt/ORGANIZATION/${ORGANIZATION_COMPILER_TAG} )
        if (Boost_ALL_TARGETS)
            if (GLOBAL)
                set_target_properties( ${Boost_ALL_TARGETS} PROPERTIES IMPORTED_GLOBAL TRUE )
            endif()
        endif()
    endif()
endfunction()


##
# @brief Searches and makes globally available: Threads
#
function(load_common_threads GLOBAL REQUIRED)
    if (NOT TARGET Threads::Threads)
        set( THREADS_PREFER_PTHREAD_FLAG ON )
        find_package( Threads ${REQUIRED} )
        if (TARGET Threads::Threads)
            if (GLOBAL)
                set_target_properties( Threads::Threads PROPERTIES IMPORTED_GLOBAL TRUE )
                # Note: Possibly, the following is not required because instead of a package we
                #       are preferably using the compiler/linker flag -pthread instead.
                find_and_store_associated_runtime_debian_package(
                    TARGETS Threads::Threads
                    GROUP_NAME Threads
                    TIMEOUT 10
                )
            endif()
        endif()
    endif()
endfunction()


##
# @brief Searches and makes globally available: ZLib
#
function(load_common_zlib GLOBAL REQUIRED)
    if (NOT TARGET ZLib::ZLib)
        # Use CMake's FindZLIB script to find ZLib.
        find_package( ZLIB ${REQUIRED} )
        if (TARGET ZLIB::ZLIB)
            # Create custom imported target and copy properties from the found ZLIB.
            add_library( ZLib::ZLib UNKNOWN IMPORTED )
            set_target_properties( ZLib::ZLib PROPERTIES
                VERSION ${ZLIB_VERSION_MAJOR}.${ZLIB_VERSION_MINOR}.${ZLIB_VERSION_PATCH}
                SOVERSION ${ZLIB_VERSION_MAJOR}
            )
            get_target_property( include_dirs              ZLIB::ZLIB INTERFACE_INCLUDE_DIRECTORIES )
            get_target_property( imported_configurations   ZLIB::ZLIB IMPORTED_CONFIGURATIONS )
            get_target_property( imported_location_release ZLIB::ZLIB IMPORTED_LOCATION_RELEASE )
            get_target_property( imported_location_debug   ZLIB::ZLIB IMPORTED_LOCATION_DEBUG )
            get_target_property( imported_location         ZLIB::ZLIB IMPORTED_LOCATION )
            if (include_dirs)
                set_target_properties( ZLib::ZLib PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${include_dirs} )
            endif()
            if (imported_configurations)
                set_target_properties( ZLib::ZLib PROPERTIES IMPORTED_CONFIGURATIONS ${imported_configurations} )
            endif()
            if (imported_location_release)
                set_target_properties( ZLib::ZLib PROPERTIES IMPORTED_LOCATION_RELEASE ${imported_location_release} )
            endif()
            if (imported_location_debug)
                set_target_properties( ZLib::ZLib PROPERTIES IMPORTED_LOCATION_DEBUG ${imported_location_debug} )
            endif()
            if (imported_location_release AND NOT imported_location_debug AND imported_location)
                set_target_properties( ZLib::ZLib PROPERTIES IMPORTED_LOCATION ${imported_location} )
            endif()
            if (GLOBAL)
                set_target_properties( ZLib::ZLib PROPERTIES IMPORTED_GLOBAL TRUE )
            endif()
        endif()
        # Cleanup cache.
        unset( ZLIB_INCLUDE_DIR CACHE )
        unset( ZLIB_LIBRARY_RELEASE CACHE )
        unset( ZLIB_LIBRARY_DEBUG CACHE )
    endif()
endfunction()
