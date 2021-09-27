##
# @file
# @details Settings for enabling different sanitizers which will be applied to an `INTERFACE`
#          target `sanitizers`. In order to use these settings for other targets those either have
#          to declare a dependency on this `sanitizers` target or must apply the properties
#          `INTERFACE_LINK_OPTIONS` and `INTERFACE_COMPILE_OPTIONS` of this `sanitizers` target
#          directly.
#

include_guard( GLOBAL )


# The target to which either a dependency needs to be declared or whose properties
# `INTERFACE_COMPILE_OPTIONS`, `INTERFACE_LINK_OPTIONS` and `INTERFACE_LINK_LIBRARIES`
# shall be used directly in order to compile with sanitizer support.
add_library( sanitizers INTERFACE )


# Provide options for enabling different sanitizers.
if (CMAKE_C_COMPILER_ID   STREQUAL "GNU" OR
    CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    option( SANITIZER_UBSan "Enable UndefinedBehavior-Sanitizer" OFF)
    option( SANITIZER_ASan  "Enable Address-Sanitizer"           OFF)
    option( SANITIZER_LSan  "Enable Leak-Sanitizer"              OFF)
    option( SANITIZER_TSan  "Enable Thread-Sanitizer"            OFF)
elseif (CMAKE_C_COMPILER_ID   STREQUAL "MSVC" OR
        CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    option( SANITIZER_ASan  "Enable Address-Sanitizer"           OFF)
elseif ((CMAKE_C_COMPILER_ID   STREQUAL "Clang" AND CMAKE_C_SIMULATE_ID   STREQUAL "MSVC") OR
        (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC"))
    option( SANITIZER_UBSan "Enable UndefinedBehavior-Sanitizer" OFF)
    option( SANITIZER_ASan  "Enable Address-Sanitizer"           OFF)
elseif (CMAKE_C_COMPILER_ID   STREQUAL "Clang" OR
        CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    option( SANITIZER_UBSan "Enable UndefinedBehavior-Sanitizer" OFF)
    option( SANITIZER_ASan  "Enable Address-Sanitizer"           OFF)
    option( SANITIZER_LSan  "Enable Leak-Sanitizer"              OFF)
    option( SANITIZER_TSan  "Enable Thread-Sanitizer"            OFF)
    option( SANITIZER_MSan  "Enable Memory-Sanitizer"            OFF)
endif()


##
# @name setup_sanitizers_target()
# @brief Creates a target `sanitizers` which needs to be linked in order to build with sanitizers.
# @note This is a function that will be called instantly. It shall never be called anywhere else
#       except at the bottom of this file.
# @note It just became a function in order to not pollute the current scope with too many
#       variables.
#
function( setup_sanitizers_target )
    # Convenience generator-expressions:
    set( IF_COMPILE_C_WITH_CLANG         "$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_COMPILE_CXX_WITH_CLANG       "$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_COMPILE_C_WITH_CLANGCL       "$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    set( IF_COMPILE_CXX_WITH_CLANGCL     "$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    set( IF_COMPILE_C_GNU_FRONTEND       "$<OR:$<COMPILE_LANG_AND_ID:C,GNU>,${IF_COMPILE_C_WITH_CLANG}>" )
    set( IF_COMPILE_CXX_GNU_FRONTEND     "$<OR:$<COMPILE_LANG_AND_ID:CXX,GNU>,${IF_COMPILE_CXX_WITH_CLANG}>" )
    set( IF_COMPILE_C_MSVC_FRONTEND      "$<OR:$<COMPILE_LANG_AND_ID:C,MSVC>,${IF_COMPILE_C_WITH_CLANGCL}>" )
    set( IF_COMPILE_CXX_MSVC_FRONTEND    "$<OR:$<COMPILE_LANG_AND_ID:CXX,MSVC>,${IF_COMPILE_CXX_WITH_CLANGCL}>" )
    set( IF_LINK_C_WITH_CLANG            "$<AND:$<LINK_LANG_AND_ID:C,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_LINK_CXX_WITH_CLANG          "$<AND:$<LINK_LANG_AND_ID:CXX,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_LINK_C_WITH_CLANGCL          "$<AND:$<LINK_LANG_AND_ID:C,Clang>,$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    set( IF_LINK_CXX_WITH_CLANGCL        "$<AND:$<LINK_LANG_AND_ID:CXX,Clang>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    set( IF_LINK_C_GNU_FRONTEND          "$<OR:$<LINK_LANG_AND_ID:C,GNU>,${IF_LINK_C_WITH_CLANG}>" )
    set( IF_LINK_CXX_GNU_FRONTEND        "$<OR:$<LINK_LANG_AND_ID:CXX,GNU>,${IF_LINK_CXX_WITH_CLANG}>" )
    set( IF_LINK_C_MSVC_FRONTEND         "$<OR:$<LINK_LANG_AND_ID:C,MSVC>,${IF_LINK_C_WITH_CLANGCL}>" )
    set( IF_LINK_CXX_MSVC_FRONTEND       "$<OR:$<LINK_LANG_AND_ID:CXX,MSVC>,${IF_LINK_CXX_WITH_CLANGCL}>" )
    set( IF_MSVC_STATIC_DEBUG_RUNTIME    "$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:MSVC_RUNTIME_LIBRARY>>,MultiThreadedDebug>" )
    set( IF_MSVC_STATIC_RELEASE_RUNTIME  "$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:MSVC_RUNTIME_LIBRARY>>,MultiThreaded>" )
    set( IF_MSVC_STATIC_RUNTIME          "$<OR:${IF_MSVC_STATIC_DEBUG_RUNTIME},${IF_MSVC_STATIC_RELEASE_RUNTIME}>" )
    set( IF_MSVC_DYNAMIC_DEBUG_RUNTIME   "$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:MSVC_RUNTIME_LIBRARY>>,MultiThreadedDebugDLL>" )
    set( IF_MSVC_DYNAMIC_RELEASE_RUNTIME "$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:MSVC_RUNTIME_LIBRARY>>,MultiThreadedDLL>" )
    set( IF_MSVC_DYNAMIC_RUNTIME         "$<OR:${IF_MSVC_DYNAMIC_DEBUG_RUNTIME},${IF_MSVC_DYNAMIC_RELEASE_RUNTIME}>" )
    set( IF_BUILDING_EXECUTABLE          "$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:TYPE>>,EXECUTABLE>" )
    set( IF_BUILDING_SHARED_LIB          "$<OR:$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:TYPE>>,SHARED_LIBRARY>,$<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:TYPE>>,MODULE_LIBRARY>>" )

    # Collect the list of enabled sanitizers.
    set( enabled_sanitizers )
    if (SANITIZER_UBSan)
        list( APPEND enabled_sanitizers "undefined" )
    endif()
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
    if (SANITIZER_MSan AND (SANITIZER_ASan OR SANITIZER_LSan OR SANITIZER_TSan OR SANITIZER_UBSan))
        message( FATAL_ERROR "Cannot enable Memory-Sanitizer together with any other sanitizer!" )
    elseif (SANITIZER_MSan)
        list( APPEND enabled_sanitizers "memory" )
    endif()

    # Add compiler/linker-options for enabling sanitizers.
    if (enabled_sanitizers)
        list( JOIN enabled_sanitizers "," enabled_sanitizers_string )
        target_compile_options( sanitizers INTERFACE
            "$<$<COMPILE_LANG_AND_ID:C,GNU,Clang,MSVC>:-fsanitize=${enabled_sanitizers_string}>"
            "$<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,MSVC>:-fsanitize=${enabled_sanitizers_string}>"
        )
        target_link_options( sanitizers INTERFACE
            "$<${IF_LINK_C_GNU_FRONTEND}:-fsanitize=${enabled_sanitizers_string}>"
            "$<${IF_LINK_CXX_GNU_FRONTEND}:-fsanitize=${enabled_sanitizers_string}>"
        )
    endif()

    # Add compiler/linker-options that are useful for all sanitizers.
    if (enabled_sanitizers)
        target_compile_options( sanitizers INTERFACE
            "$<${IF_COMPILE_C_GNU_FRONTEND}:-fno-omit-frame-pointer>"
            "$<${IF_COMPILE_CXX_GNU_FRONTEND}:-fno-omit-frame-pointer>"
        )
        target_link_options( sanitizers INTERFACE
            "$<${IF_LINK_C_GNU_FRONTEND}:-fno-omit-frame-pointer>"
            "$<${IF_LINK_CXX_GNU_FRONTEND}:-fno-omit-frame-pointer>"
        )
        # Generate debugging-symbols with MSVC/Clang-cl if not already.
        target_compile_options( sanitizers INTERFACE
            "$<$<AND:${IF_COMPILE_C_MSVC_FRONTEND},$<CONFIG:Release,MinSizeRel>>:/Zi>"
            "$<$<AND:${IF_COMPILE_CXX_MSVC_FRONTEND},$<CONFIG:Release,MinSizeRel>>:/Zi>"
        )
    endif()

    # Disable some warnings/errors that are problematic when using sanitizers.
    if (enabled_sanitizers)
        target_link_options( sanitizers INTERFACE
            # Incremental linking is not supported if using sanitizers with MSVC/Clang-cl.
            "$<${IF_LINK_C_MSVC_FRONTEND}:/INCREMENTAL:NO>"
            "$<${IF_LINK_CXX_MSVC_FRONTEND}:/INCREMENTAL:NO>"
            # Ignore warning which suggests to use `/DEBUG` option, if building other configuration than "Debug"!
            "$<$<AND:$<LINK_LANG_AND_ID:C,MSVC>,$<NOT:$<CONFIG:Debug>>>:LINKER:/IGNORE:4302>"
            "$<$<AND:$<LINK_LANG_AND_ID:CXX,MSVC>,$<NOT:$<CONFIG:Debug>>>:LINKER:/IGNORE:4302>"
        )
    endif()

    # Link correct sanitizer support libraries.
    if (enabled_sanitizers)
        # Determine architecture tag for sanitizer support libraries.
        if (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
            set( arch "x86_64" )
        elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "i686" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "i386" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "X86")
            set( arch "i386" )
        else()
            message( FATAL_ERROR "Cannot determine architecture to use for sanitizer support libraries. (Unsupported processor architecture: '${CMAKE_SYSTEM_PROCESSOR}')" )
        endif()

        # Using Clang (but not Clang-cl) with MSVC runtime?
        target_link_options( sanitizers INTERFACE
            # Linking with dynamic MSVC runtime?
            "$<$<AND:${IF_LINK_C_WITH_CLANG},${IF_MSVC_DYNAMIC_RUNTIME}>:-shared-libsan>"
            "$<$<AND:${IF_LINK_CXX_WITH_CLANG},${IF_MSVC_DYNAMIC_RUNTIME}>:-shared-libsan>"
            # Linking with static MSVC runtime?
            "$<$<AND:${IF_LINK_C_WITH_CLANG},${IF_MSVC_STATIC_RUNTIME}>:-static-libsan>"
            "$<$<AND:${IF_LINK_CXX_WITH_CLANG},${IF_MSVC_STATIC_RUNTIME}>:-static-libsan>"
        )
        # Using Clang-cl with MSVC linker (link.exe)?
        if (CMAKE_LINKER MATCHES "^(.*[/\\])?link(.exe)?$")
            # The MSVC linker (link.exe) can automatically link required sanitizer libraries by using
            # linker option `/INFERASANLIBS`. It is used by default if using any of the "Visual Studio"
            # generators. But it needs to be added explicitly for Clang-cl with another generator.
            target_link_options( sanitizers INTERFACE
                "$<${IF_LINK_C_WITH_CLANGCL}:LINKER:/INFERASANLIBS>"
                "$<${IF_LINK_CXX_WITH_CLANGCL}:LINKER:/INFERASANLIBS>"
            )
        # Using Clang-cl with LLVM linker (lld-link.exe)?
        elseif (CMAKE_LINKER MATCHES "^(.*[/\\])?lld-link(.exe)?$")
            # See: https://devblogs.microsoft.com/cppblog/msvc-address-sanitizer-one-dll-for-all-runtime-configurations/
            # Linking with Visual Studio 19.7 or newer is simple!
            if (MSVC_VERSION GREATER_EQUAL "1937")
                target_link_options( sanitizers INTERFACE
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL}>:LINKER:clang_rt.asan_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL}>:LINKER:clang_rt.asan_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dynamic_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dynamic_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_static_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_static_runtime_thunk-${arch}.lib>"
                )
            # Linking before Visual Studio 19.7 is hard!
            else()
                # Clang-cl with dynamic MSVC runtime?
                target_link_options( sanitizers INTERFACE
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_DYNAMIC_DEBUG_RUNTIME}>:LINKER:clang_rt.asan_dbg_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_DYNAMIC_DEBUG_RUNTIME}>:LINKER:clang_rt.asan_dbg_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RELEASE_RUNTIME}>:LINKER:clang_rt.asan_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RELEASE_RUNTIME}>:LINKER:clang_rt.asan_dynamic-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_DYNAMIC_DEBUG_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dbg_dynamic_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_DYNAMIC_DEBUG_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dbg_dynamic_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RELEASE_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dynamic_runtime_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_DYNAMIC_RELEASE_RUNTIME}>:LINKER:/WHOLEARCHIVE:clang_rt.asan_dynamic_runtime_thunk-${arch}.lib>"
                )
                # Clang-cl with static MSVC runtime?
                target_link_options( sanitizers INTERFACE
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME}>:LINKER:clang_rt.asan_dbg_cxx-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME}>:LINKER:clang_rt.asan_dbg_cxx-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME}>:LINKER:clang_rt.asan_cxx-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME}>:LINKER:clang_rt.asan_cxx-${arch}.lib>"
                    # Building a DLL?
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME},${IF_BUILDING_SHARED_LIB}>:LINKER:clang_rt.asan_dbg_dll_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME},${IF_BUILDING_SHARED_LIB}>:LINKER:clang_rt.asan_dbg_dll_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME},${IF_BUILDING_SHARED_LIB}>:LINKER:clang_rt.asan_dll_thunk-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME},${IF_BUILDING_SHARED_LIB}>:LINKER:clang_rt.asan_dll_thunk-${arch}.lib>"
                    # Building an EXE?
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME},${IF_BUILDING_EXECUTABLE}>:LINKER:clang_rt.asan_dbg-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_DEBUG_RUNTIME},${IF_BUILDING_EXECUTABLE}>:LINKER:clang_rt.asan_dbg-${arch}.lib>"
                    "$<$<AND:${IF_LINK_C_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME},${IF_BUILDING_EXECUTABLE}>:LINKER:clang_rt.asan-${arch}.lib>"
                    "$<$<AND:${IF_LINK_CXX_WITH_CLANGCL},${IF_MSVC_STATIC_RELEASE_RUNTIME},${IF_BUILDING_EXECUTABLE}>:LINKER:clang_rt.asan-${arch}.lib>"
                )
            endif()
        elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
            message( WARNING "Possibly missing specific sanitizer linker-flags for the currently chosen linker!" )
        else()
            message( DEBUG "On Linux (probably) no specific sanitizer linker-flags are required." )
        endif()
    endif()
endfunction()


# Directly call the above function.
setup_sanitizers_target()
