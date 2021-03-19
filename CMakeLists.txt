cmake_minimum_required(VERSION 3.16)
project(FBX2glTF)

set(CMAKE_CXX_STANDARD 17)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
  message("Not define CMAKE_BUILD_TYPE var, define as 'Debug'")
  set(CMAKE_BUILD_TYPE Debug)
  set(DEBUG_BUILD TRUE)
endif()

# TODO: maybe std::thread can replace this
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_BINARY_DIR}")

# create a compilation database for e.g. clang-tidy
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(3RD_DIR "${CMAKE_SOURCE_DIR}/third_party")
set(3RD_BINARY_DIR "${CMAKE_BINARY_DIR}/third_party")

message("3RD_DIR:" ${3RD_DIR})
message("3RD_BINARY_DIR:" ${3RD_BINARY_DIR})

macro (gen_lib_name BASENAME LIBNAME)
  if (WIN32)
    set(${LIBNAME} ${BASENAME}.lib)
  else()
    set(${LIBNAME} lib${BASENAME}.a)
  endif()
endmacro()

# FBX
find_package(FBX)

if (FBX-NOTFOUND)
  message(FATAL_ERROR "not found FBX")
else()
  message(STATUS "FBX found!")
endif()

# draco
add_subdirectory(${3RD_DIR}/draco)
set(DRACO_INCLUDE_DIR "${3RD_DIR}/draco/src" "${CMAKE_BINARY_DIR}")
gen_lib_name(draco DRACO_LIB_NAME)
set(DRACO_LIB "${3RD_BINARY_DIR}/draco/${CMAKE_BUILD_TYPE}/${DRACO_LIB_NAME}")

#CPPCODEC
set(CPPCODEC_INCLUDE_DIR "${3RD_DIR}/cppcodec")

#FIFO_MAP
set(FIFO_MAP_INCLUDE_DIR "${3RD_DIR}/fifo_map/src")
#fmt
set(FMT_INCLUDE_DIR "${3RD_DIR}/fmt/include")

#stb
set(STB_INCLUDE_DIR "${3RD_DIR}/stb")

#tinygltf
set(TINYGLTF_INCLUDE_DIR "${3RD_DIR}/tinygltf")

#json
set(JSON_INCLUDE_DIR "${3RD_DIR}/json/single_include/nlohmann")

# MATHFU
set(MATHFU_INCLUDE_DIR "${3RD_DIR}/mathfu/include")

if (APPLE)
    find_library(CF_FRAMEWORK CoreFoundation)
    message("CoreFoundation Framework: ${CF_FRAMEWORK}")
    set(FRAMEWORKS ${CF_FRAMEWORK})
endif()

set(LIB_SOURCE_FILES
        src/FBX2glTF.h
        src/fbx/materials/3dsMaxPhysicalMaterial.cpp
        src/fbx/materials/FbxMaterials.cpp
        src/fbx/materials/FbxMaterials.hpp
        src/fbx/materials/RoughnessMetallicMaterials.hpp
        src/fbx/materials/StingrayPBSMaterial.cpp
        src/fbx/materials/TraditionalMaterials.cpp
        src/fbx/materials/TraditionalMaterials.hpp
        src/fbx/Fbx2Raw.cpp
        src/fbx/Fbx2Raw.hpp
        src/fbx/FbxBlendShapesAccess.cpp
        src/fbx/FbxBlendShapesAccess.hpp
        src/fbx/FbxLayerElementAccess.hpp
        src/fbx/FbxSkinningAccess.cpp
        src/fbx/FbxSkinningAccess.hpp
        src/gltf/Raw2Gltf.cpp
        src/gltf/Raw2Gltf.hpp
        src/gltf/GltfModel.cpp
        src/gltf/GltfModel.hpp
        src/gltf/TextureBuilder.cpp
        src/gltf/TextureBuilder.hpp
        src/gltf/properties/AccessorData.cpp
        src/gltf/properties/AccessorData.hpp
        src/gltf/properties/AnimationData.cpp
        src/gltf/properties/AnimationData.hpp
        src/gltf/properties/BufferData.cpp
        src/gltf/properties/BufferData.hpp
        src/gltf/properties/BufferViewData.cpp
        src/gltf/properties/BufferViewData.hpp
        src/gltf/properties/CameraData.cpp
        src/gltf/properties/CameraData.hpp
        src/gltf/properties/ImageData.cpp
        src/gltf/properties/ImageData.hpp
        src/gltf/properties/LightData.cpp
        src/gltf/properties/LightData.hpp
        src/gltf/properties/MaterialData.cpp
        src/gltf/properties/MaterialData.hpp
        src/gltf/properties/MeshData.cpp
        src/gltf/properties/MeshData.hpp
        src/gltf/properties/NodeData.cpp
        src/gltf/properties/NodeData.hpp
        src/gltf/properties/PrimitiveData.cpp
        src/gltf/properties/PrimitiveData.hpp
        src/gltf/properties/SamplerData.hpp
        src/gltf/properties/SceneData.cpp
        src/gltf/properties/SceneData.hpp
        src/gltf/properties/SkinData.cpp
        src/gltf/properties/SkinData.hpp
        src/gltf/properties/TextureData.cpp
        src/gltf/properties/TextureData.hpp
        src/mathfu.hpp
        src/raw/RawModel.cpp
        src/raw/RawModel.hpp
        src/utils/File_Utils.cpp
        src/utils/File_Utils.hpp
        src/utils/Image_Utils.cpp
        src/utils/Image_Utils.hpp
        src/utils/String_Utils.hpp
        third_party/CLI11/CLI11.hpp
)

add_library(libFBX2glTF STATIC ${LIB_SOURCE_FILES})
set_target_properties(libFBX2glTF PROPERTIES OUTPUT_NAME "FBX2glTF")
add_executable(appFBX2glTF src/FBX2glTF.cpp)
set_target_properties(appFBX2glTF PROPERTIES OUTPUT_NAME "FBX2glTF")

target_compile_definitions(libFBX2glTF PRIVATE "FMT_HEADER_ONLY=1")
target_compile_definitions(appFBX2glTF PRIVATE "FMT_HEADER_ONLY=1")

if (NOT MSVC)
  # Disable annoying & spammy warning from FBX SDK header file
  target_compile_options(libFBX2glTF PRIVATE
    "-Wno-null-dereference"
    "-Wunused"
    )
  target_compile_options(appFBX2glTF PRIVATE
    "-Wno-null-dereference"
    "-Wunused"
    )
endif()

target_link_libraries(libFBX2glTF
  ${FRAMEWORKS}
  ${FBXSDK_LIBS}
  ${DRACO_LIB}
  ${CMAKE_DL_LIBS}
  ${CMAKE_THREAD_LIBS_INIT}
)

# remove libiconv depend
# if (APPLE)
#  find_package(Iconv MODULE REQUIRED)
#  target_link_libraries(libFBX2glTF Iconv)
# else()
#  find_package(libiconv MODULE REQUIRED)
#  target_link_libraries(libFBX2glTF libiconv::libiconv)
# endif()

target_include_directories(libFBX2glTF PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_precompile_headers(libFBX2glTF PRIVATE ${CMAKE_SOURCE_DIR}/src/pch.h)

target_include_directories(libFBX2glTF PUBLIC
  ${STB_INCLUDE_DIR}
  ${TINYGLTF_INCLUDE_DIR}
  ${FBXSDK_INCLUDE_DIR}
  ${DRACO_INCLUDE_DIR}
  ${JSON_INCLUDE_DIR}
  ${MATHFU_INCLUDE_DIR}
  ${FIFO_MAP_INCLUDE_DIR}
  ${FMT_INCLUDE_DIR}
  ${CPPCODEC_INCLUDE_DIR}
)

#CLI11
set(CLI11_INCLUDE_DIR "${3RD_DIR}/CLI11")
target_include_directories(appFBX2glTF PUBLIC
  ${CLI11_INCLUDE_DIR}
)
target_link_libraries(appFBX2glTF libFBX2glTF)

target_precompile_headers(appFBX2glTF REUSE_FROM libFBX2glTF)

install (TARGETS libFBX2glTF appFBX2glTF
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
)
