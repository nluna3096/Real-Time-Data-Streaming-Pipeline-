# Generates the .so library file
# @author Nerea Luna (CERN)

cmake_minimum_required(VERSION 3.1)

project(KafkaStream)

# WinCC-OA environment variable
set(API_ROOT "$ENV{API_ROOT}" CACHE FILEPATH "directory of the WinCC_OA API installation")

include(${API_ROOT}/CMakeDefines.txt)

# We set the name of the target library file (which we will need to execute the CTRL Extension inside WinCC-OA)
set(TARGET VacKafkaStream)

set(SOURCES
KafkaStream_ExternHdl.cxx
)
add_ctrlext(${TARGET} ${SOURCES})

# Target Library
target_link_libraries(${TARGET} cppkafka)

# Point to cppkafka header files
# Change ${CMAKE_CURRENT_SOURCE_DIR} by your corresponding path
include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libs/cppkafka/include)

