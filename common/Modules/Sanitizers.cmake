##
# @file
# @details Settings for enabling different sanitizers which will be applied to an INTERFACE target
#          `sanitizers`. In order to use these settings for other targets this `sanitizers` target
#          either needs to be linked into other targets or its properties `INTERFACE_LINK_OPTIONS"
#          and `INTERFACE_COMPILE_OPTIONS` need to be applied directly.
#

include_guard( GLOBAL )


# Sanitizers are only supported by GCC and Clang.
if (NOT (ORGANIZATION_COMPILER_TAG MATCHES "gcc.*" OR
         ORGANIZATION_COMPILER_TAG MATCHES "clang.*"))
    return()
endif()

# Provide options for different sanitizers.
option( SANITIZER_ASan  "Enable Address-Sanitizer" OFF)
option( SANITIZER_LSan  "Enable Leak-Sanitizer" OFF)
option( SANITIZER_TSan  "Enable Thread-Sanitizer" OFF)
option( SANITIZER_UBSan "Enable UndefiniedBehavior-Sanitizer" OFF)
if (ORGANIZATION_COMPILER_TAG MATCHES "clang.*")
    option( SANITIZER_MSan  "Enable Memory-Sanitizer" OFF)
endif()

# If any sanitizer is enabled, create specific target for its settings.
if (SANITIZER_ASan  OR
    SANITIZER_LSan  OR
    SANITIZER_TSan  OR
    SANITIZER_UBSan OR
    SANITIZER_MSan)
    # The target which either needs to be linked in order to compile with sanitizer support
    # or whose properties `INTERFACE_COMPILE_OPTIONS` and `INTERFACE_LINK_OPTIONS` shall be
    # used directly.
    add_library( sanitizers INTERFACE )

    # Compiler-option which is useful for all sanitizers.
    target_compile_options( sanitizers INTERFACE $<$<C_COMPILER_ID:GNU,Clang>:-fno-omit-frame-pointer> )
    target_link_options(    sanitizers INTERFACE $<$<C_COMPILER_ID:GNU,Clang>:-fno-omit-frame-pointer> )
    target_compile_options( sanitizers INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang>:-fno-omit-frame-pointer> )
    target_link_options(    sanitizers INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang>:-fno-omit-frame-pointer> )

    # Compiler-options for enabling sanitizers.
    if (SANITIZER_ASan)
        list( APPEND enabled_sanitizers "address" )
    endif()
    # Note: LSan is integrated in ASan and does not need to be enabled explicitly if ASan is enabled!
    if (SANITIZER_LSan AND NOT SANITIZER_ASan)
        list( APPEND enabled_sanitizers "leak" )
    endif()
    if (SANITIZER_TSan AND (SANITIZER_ASan OR SANITIZER_LSan))
        message( FATAL_ERROR "Cannot enable Thread-Sanitizer together with Address- or Leak-Sanitizer!" )
    elseif (SANITIZER_TSan)
        list( APPEND enabled_sanitizers "thread" )
    endif()
    if (SANITIZER_UBSan)
        list( APPEND enabled_sanitizers "undefined" )
    endif()
    if (enabled_sanitizers)
        list( JOIN enabled_sanitizers "," enabled_sanitizers )
        target_compile_options( sanitizers INTERFACE $<$<C_COMPILER_ID:GNU,Clang>:-fsanitize=${enabled_sanitizers}> )
        target_link_options(    sanitizers INTERFACE $<$<C_COMPILER_ID:GNU,Clang>:-fsanitize=${enabled_sanitizers}> )
        target_compile_options( sanitizers INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang>:-fsanitize=${enabled_sanitizers}> )
        target_link_options(    sanitizers INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang>:-fsanitize=${enabled_sanitizers}> )
        unset( enabled_sanitizers )
    endif()

    # Compiler-options for enabling sanitizers (available only on Clang).
    if (SANITIZER_MSan AND (SANITIZER_ASan OR SANITIZER_LSan OR SANITIZER_TSan OR SANITIZER_UBSan))
        message( FATAL_ERROR "Cannot enable Memory-Sanitizer together with any other sanitizer!" )
    elseif (SANITIZER_MSan)
        target_compile_options( sanitizers INTERFACE $<$<C_COMPILER_ID:Clang>:-fsanitize=memory> )
        target_link_options(    sanitizers INTERFACE $<$<C_COMPILER_ID:Clang>:-fsanitize=memory> )
        target_compile_options( sanitizers INTERFACE $<$<CXX_COMPILER_ID:Clang>:-fsanitize=memory> )
        target_link_options(    sanitizers INTERFACE $<$<CXX_COMPILER_ID:Clang>:-fsanitize=memory> )
    endif()
endif()
