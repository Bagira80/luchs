##
# @file
# @brief Load dependency GoogleTest/GoogleMock
# @details Required variables:
#            * LOAD_DEPENDENCY_GLOBAL
# @note This dependency may only be loaded globally!
#

include( "${CMAKE_CURRENT_LIST_DIR}/FetchDependencyHelper.cmake" )

if (NOT TARGET GoogleTest::gtest)
    if (NOT "${LOAD_DEPENDENCY_GLOBAL}")
        message( SEND_ERROR "The common dependency \"GoogleTest\" cannot be loaded locally, only globally!" )
    endif()

    # Prepare fetching and patching the source-code.
    FetchDependency_prepare( GoogleTest
        LOCAL_PATH     "${CMAKE_SOURCE_DIR}/3rd-party/googletest"
        GIT_REPOSITORY "https://github.com/google/googletest.git"
        GIT_TAG        "b796f7d44681514f58a683a3a71ff17c94edb0c1"  # tag v1.13.0
        PATCH
    )

    # Override some settings from GoogleTest!
    set( INSTALL_GTEST "OFF" CACHE INTERNAL "No, we do not want to install GoogleTest!" FORCE )  # Do not install GoogleTest.
    set( BUILD_SHARED_LIBS "OFF" )  # Do generate static GoogleTest libraries.

    # Fetch source-code and make its CMakeLists.txt available.
    FetchDependency_now( GoogleTest )

    # Create alias targets and change accordingly how these are displayed in IDEs.
    set( unicodeProportionChar "∷" )  # A fixed double-colon (U+2237) that does not collide with the drive-separator on Windows systems.
    if (NOT TARGET GoogleTest::gtest AND TARGET gtest)
        if (TARGET sanitizers)
            target_link_libraries( gtest PUBLIC $<BUILD_INTERFACE:sanitizers> )
        endif()
        add_library( GoogleTest::gtest ALIAS gtest )
        set_target_properties( gtest PROPERTIES
            PROJECT_LABEL "GoogleTest${unicodeProportionChar}gtest"
            FOLDER "ExternalDependenciesTargets"
        )
    endif()
    if (NOT TARGET GoogleTest::gtest_main AND TARGET gtest_main)
        if (TARGET sanitizers)
            target_link_libraries( gtest_main PUBLIC $<BUILD_INTERFACE:sanitizers> )
        endif()
        add_library( GoogleTest::gtest_main ALIAS gtest_main )
        set_target_properties( gtest_main PROPERTIES
            PROJECT_LABEL "GoogleTest${unicodeProportionChar}gtest_main"
            FOLDER "ExternalDependenciesTargets"
        )
    endif()
    if (NOT TARGET GoogleTest::gmock AND TARGET gmock)
        if (TARGET sanitizers)
            target_link_libraries( gmock PUBLIC $<BUILD_INTERFACE:sanitizers> )
        endif()
        add_library( GoogleTest::gmock ALIAS gmock )
        set_target_properties( gmock PROPERTIES
            PROJECT_LABEL "GoogleTest${unicodeProportionChar}gmock"
            FOLDER "ExternalDependenciesTargets"
        )
    endif()
    if (NOT TARGET GoogleTest::gmock_main AND TARGET gmock_main)
        if (TARGET sanitizers)
            target_link_libraries( gmock_main PUBLIC $<BUILD_INTERFACE:sanitizers> )
        endif()
        add_library( GoogleTest::gmock_main ALIAS gmock_main )
        set_target_properties( gmock_main PROPERTIES
            PROJECT_LABEL "GoogleTest${unicodeProportionChar}gmock_main"
            FOLDER "ExternalDependenciesTargets"
        )
    endif()
endif()
