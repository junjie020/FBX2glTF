#include <climits>
#include <string>

#if defined(_WIN32)
// Tell Windows not to define min() and max() macros
#define NOMINMAX
#include <Windows.h>
#endif

#define FBX2GLTF_VERSION std::string("0.9.7")

#include <fmt/printf.h>

#include <fbxsdk.h>

#if defined(_WIN32)
// this is defined in fbxmath.h
#undef isnan
#undef snprintf
#endif

#include "mathfu.hpp"

// give all modules access to our tweaked JSON
#include <fifo_map.hpp>
#include <json.hpp>