if (NOT CMAKE_Nim_IN_PATH)
    set(CMAKE_Nim_IN_PATH ${CMAKE_ROOT}/Modules CACHE FILEPATH "Nim cmake in file path")
endif()

if (NOT CMAKE_Nim_COMPILER)
    set(Nim_BIN_PATH
        $ENV{NIM_HOME}/bin
        /usr/bin
        /usr/local/bin
    )
    find_program(CMAKE_Nim_COMPILER NAMES nim PATHS ${Nim_BIN_PATH})
endif()
mark_as_advanced(CMAKE_Nim_COMPILER)

if (NOT CMAKE_Nim_RUNTIME)
    set(Nim_INC_PATH
        $ENV{NIM_HOME}/lib
        /usr/include
        /usr/local/include
    )

    find_path(CMAKE_Nim_NIMBASE NAMES nimbase.h PATHS ${Nim_INC_PATH})

    if (NOT CMAKE_Nim_COMPILER)
        message(FATAL_ERROR "Cannot find Nim compiler")
    endif()

    if (NOT CMAKE_Nim_NIMBASE)
        message(FATAL_ERROR "Cannot find nimbase.h")
    endif()

    get_filename_component(CMAKE_Nim_RUNTIME2 ${CMAKE_Nim_NIMBASE} DIRECTORY)
    set(CMAKE_Nim_RUNTIME ${CMAKE_Nim_RUNTIME2}/lib CACHE STRING "Nim runtime")
endif()
mark_as_advanced(CMAKE_Nim_RUNTIME)

# configure variables set in this file for fast reload later on
if (NOT CMAKE_Nim_COMPILER_LOADED)
    configure_file(${CMAKE_Nim_IN_PATH}/CMakeNimCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakeNimCompiler.cmake @ONLY)
    include (${CMAKE_PLATFORM_INFO_DIR}/CMakeNimCompiler.cmake)
endif()
