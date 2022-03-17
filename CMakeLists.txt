cmake_minimum_required(VERSION 3.10)

# Nim setup
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CMAKE_Nim_IN_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake CACHE PATH "Nim cmake in file path")
enable_language(Nim)

project(Ciao)
add_executable(Ciao backend.nim)
