enable_language(C) # for backend generation

set(CMAKE_C_BASE_NAME)
get_filename_component(CMAKE_C_BASE_NAME "${CMAKE_C_COMPILER}" NAME_WE)
if(CMAKE_COMPILER_IS_GNUCC)
  set(CMAKE_C_BASE_NAME gcc)
endif()

if (NOT CMAKE_Nim_C_CACHE)
    set(CMAKE_Nim_C_CACHE ${CMAKE_BINARY_DIR}/nimcmake)
endif()

set(CMAKE_Nim_FLAGS_INIT "cc --nimcache:${CMAKE_Nim_C_CACHE} --noLinking --gc:orc -o:dummy")

set(CMAKE_Nim_FLAGS_DEBUG_INIT "-d:debug --debuginfo:on")
set(CMAKE_Nim_FLAGS_RELEASE_INIT "-d:release")

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") # is this actually ok? documentation on Modules files is not really good
  set(CMAKE_Nim_FLAGS "${CMAKE_Nim_FLAGS_INIT} ${CMAKE_Nim_FLAGS_DEBUG_INIT}")
else()
  set(CMAKE_Nim_FLAGS "${CMAKE_Nim_FLAGS_INIT} ${CMAKE_Nim_FLAGS_RELEASE_INIT}")
endif()


if(UNIX OR MINGW OR CYGWIN OR CMAKE_COMPILER_IS_GNUCC) # We need to pass CMAKE_COMPILER_IS_GNUCC or under MinGW64 it will use .obj for some reason
  set(CMAKE_Nim_OUTPUT_EXTENSION .c.o)
else()
  set(CMAKE_Nim_OUTPUT_EXTENSION .c.obj)
endif()

if (NOT CMAKE_Nim_CC_COMPILER)
    if ("${CMAKE_C_BASE_NAME}" STREQUAL "gcc")
        set(CMAKE_Nim_CC_COMPILER "gcc" CACHE STRING "Nim C backend" FORCE)
    elseif ("${CMAKE_C_BASE_NAME}" STREQUAL "cl")
        set(CMAKE_Nim_CC_COMPILER "vcc" CACHE STRING "Nim C backend" FORCE)
    else()
        # We need to do this because --cc:env doesn't properly detect the compiler if we are under msys and so on (It actually failed to autodetect VCC even on a normal execution on Windows)
        message(FATAL_ERROR "Unsupported C compiler ${CMAKE_C_BASE_NAME}")
    endif()
endif()

# compile a Nim file into an object file
if(NOT CMAKE_Nim_COMPILE_OBJECT)
  set(CMAKE_Nim_COMPILE_OBJECT
    # Is there a way to make this in a sane way? Can we actually manipulate strings directly like with ${substring a b}? Can we actually get a better nimc that has single files?
    # Does this even work on Windows MSVC at all?

    "<CMAKE_Nim_COMPILER> <FLAGS> --header --cc:${CMAKE_Nim_CC_COMPILER} \"<SOURCE>\"" # Step 1: Generate C source/header files from nim
    "<CMAKE_COMMAND> -E copy <SOURCE> ${CMAKE_CURRENT_BIN_DIR}/CMAKETEMP.nim" # Step 2: Copy current source to cmakeTemp
    "<CMAKE_Nim_COMPILER> <FLAGS> --cc:${CMAKE_Nim_CC_COMPILER} ${CMAKE_CURRENT_BIN_DIR}/CMAKETEMP.nim" # Step 3: Actually C generate our file
    "<CMAKE_COMMAND> -E copy ${CMAKE_Nim_C_CACHE}/@mCMAKETEMP.nim${CMAKE_Nim_OUTPUT_EXTENSION} <OBJECT>" # Step 4: Copy our hardcoded file to the cmake object directory
  )
endif()

if(NOT CMAKE_Nim_LINK_EXECUTABLE)
  set(CMAKE_Nim_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> ${CMAKE_C_LINK_FLAGS} <LINK_FLAGS> -o <TARGET> <LINK_LIBRARIES> <OBJECTS> ${CMAKE_Nim_C_CACHE}/stdlib*${CMAKE_Nim_OUTPUT_EXTENSION}") # Pass to the C linker with nim specific objects
endif()

set(CMAKE_Nim_COMPILER_FORCED 1) # I didn't had enough patience to fix this

include_directories(${CMAKE_Nim_RUNTIME}) # include nim runtime to standard C compiler
