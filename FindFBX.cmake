# Copyright (c) 2014-present, Facebook, Inc.
# All rights reserved.
#
# Helper function for finding the FBX SDK.
# Cribbed & tweaked from https://github.com/floooh/fbxc/
#
# params:
#         FBXSDK_ROOT         //it specify where sdk root, for window: ${FBXSDK_INSTALL_FOLDER}/2019.2
#
# sets:   FBXSDK_FOUND        //will set to TRUE at the last of this file
#         FBXSDK_INCLUDE_DIR  //where fbxsdk.h file folder
#         FBXSDK_LIBS         //include libfbxsdk, libxml2, zib
#
# only support ARCH_64
set(ARCH_32 OFF)

if (NOT DEFINED FBXSDK_ROOT)
  message(STATUS "FBXSDK_SDKS is not define, make it as: ${CMAKE_CURRENT_SOURCE_DIR}/sdk" )
  set(FBXSDK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/sdk")
endif()

message(STATUS "FBXSDK_ROOT: ${FBXSDK_ROOT}")

if (NOT EXISTS ${FBXSDK_ROOT})
  message(FATAL_ERROR "FBXSDK_ROOT:${FBXSDK_ROOT} path is not exists!")
endif()

set(FBXSDK_INCLUDE_DIR "${FBXSDK_ROOT}/include")
message(STATUS "FBXSDK_INCLUDE_DIR: ${FBXSDK_INCLUDE_DIR}")

if (APPLE)
  message(FATAL_ERROR "Not implement macOS")
  # set(DEBUG_DIR "lib/clang/debug")
  # set(RELEASE_DIR "lib/clang/release")
  # set(DEBUG_BASENAME "libfbxsdk.a")
  # set(RELEASE_BASENAME "libfbxsdk.a")
elseif (WIN32)
  set(VS_VERSION "vs2017")
  set(FBXSDK_LIBNAME "libfbxsdk-md.lib")
  set(FBXSDK_XML2_LIBNAME "libxml2-md.lib")
  set(FBXSDK_ZIB_LIBNAME "zlib-md.lib")

  set(FBXSDK_LIB_DIR "${FBXSDK_ROOT}/lib/vs2017/x64/${CMAKE_BUILD_TYPE}")
else()
  message(FATAL_ERROR "not support platform!")
endif()

message(STATUS "FBXSDK_LIB_DIR:${FBXSDK_LIB_DIR}")

set(FBX_LIB "${FBXSDK_LIB_DIR}/${FBXSDK_LIBNAME}")
set(XML2_LIB "${FBXSDK_LIB_DIR}/${FBXSDK_XML2_LIBNAME}")
set(ZIB_LIB "${FBXSDK_LIB_DIR}/${FBXSDK_ZIB_LIBNAME}")

set(FBXSDK_LIBS ${FBX_LIB} ${XML2_LIB} ${ZIB_LIB})
message(STATUS "FBXSDK_LIBS:${FBXSDK_LIBS}")

foreach(x IN LISTS FBXSDK_LIBS)
  if (NOT EXISTS ${x})
    message(FATAL_ERROR "lib:${x} is not exist!")
  endif()
endforeach()

set(FBXSDK_FOUND YES)
