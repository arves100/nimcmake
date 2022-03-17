if(CMAKE_Nim_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  set(CMAKE_Nim_COMPILER_WORKS TRUE)
  return()
endif()

include(CMakeTestCompilerCommon)

unset(CMAKE_Nim_COMPILER_WORKS CACHE)

set(test_compile_file "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testNimCompiler.nim")

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that the selected Nim compiler can actually compile
# and link the most basic of programs. If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.
if(NOT CMAKE_Nim_COMPILER_WORKS)
  # Don't call PrintTestCompilerStatus() because the "Nim" we want to pass
  # as the LANG doesn't match with the variable name "CMAKE_Nim_COMPILER"
  message(CHECK_START "Check for working Nim compiler: ${CMAKE_Nim_COMPILER}")
  file(WRITE "${test_compile_file}"
    "echo \"Hello World\""
    )
  # Clear result from normal variable.
  unset(CMAKE_Nim_COMPILER_WORKS)
  # Puts test result in cache variable.
  try_compile(CMAKE_Nim_COMPILER_WORKS ${CMAKE_BINARY_DIR} "${test_compile_file}"
    OUTPUT_VARIABLE __CMAKE_Nim_COMPILER_OUTPUT
    )
  # Move result from cache to normal variable.
  set(CMAKE_Nim_COMPILER_WORKS ${CMAKE_Nim_COMPILER_WORKS})
  unset(CMAKE_Nim_COMPILER_WORKS CACHE)
  set(Nim_TEST_WAS_RUN 1)
endif()

if(NOT CMAKE_Nim_COMPILER_WORKS)
  PrintTestCompilerResult(CHECK_FAIL "broken")
  file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if the Nim compiler works failed with "
    "the following output:\n${__CMAKE_Nim_COMPILER_OUTPUT}\n\n")
  string(REPLACE "\n" "\n  " _output "${__CMAKE_Nim_COMPILER_OUTPUT}")
  message(FATAL_ERROR "The Nim compiler\n  \"${CMAKE_Nim_COMPILER}\"\n"
    "is not able to compile a simple test program.\nIt fails "
    "with the following output:\n  ${_output}\n\n"
    "CMake will not be able to correctly generate this project.")
else()
  if(Nim_TEST_WAS_RUN)
    PrintTestCompilerResult(CHECK_PASS "works")
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the Nim compiler works passed with "
      "the following output:\n${__CMAKE_Nim_COMPILER_OUTPUT}\n\n")
  endif()

  # Re-configure to save learned information.
  configure_file(
    ${CMAKE_Nim_IN_PATH}/CMakeNimCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakeNimCompiler.cmake
    @ONLY
    )
  include(${CMAKE_PLATFORM_INFO_DIR}/CMakeNimCompiler.cmake)
endif()
