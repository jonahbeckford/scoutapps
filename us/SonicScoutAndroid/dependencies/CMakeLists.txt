include(DkSDKFetchContent)
include(DkSDKProject)
include(DkSDKVersion)
DkSDKProject_AddDependencies()

# --- Set dksdk-ffi-c_REPOSITORY and dksdk-ffi-java_REPOSITORY

get_property(dksdk-ffi-c_REPOSITORY GLOBAL PROPERTY DKSDK_FFI_C_REPOSITORY)
get_property(dksdk-ffi-java_REPOSITORY GLOBAL PROPERTY DKSDK_FFI_JAVA_REPOSITORY)

# --- Fetch dksdk-ffi-c and dksdk-ffi-java

set(DKSDK_FFI_JAVA_EMBEDDER_LIBRARY data_foreground) # dksdk-ffi-java will use this

DkSDKVersion_GetVersion(OUTPUT_VERSION DKSDK_VERSION
        OUTPUT_VERSION_MAJOR v_major
        OUTPUT_VERSION_MINOR v_minor)
DkSDKFetchContent_DeclareSecondParty(NAME dksdk-ffi-c
        ALLOW_OUTSIDE_SOURCE_TREE
        GIT_REPOSITORY "${dksdk-ffi-c_REPOSITORY}"
        GIT_TAG ${v_major}.${v_minor})
DkSDKFetchContent_DeclareSecondParty(NAME dksdk-ffi-java
        ALLOW_OUTSIDE_SOURCE_TREE
        GIT_REPOSITORY "${dksdk-ffi-java_REPOSITORY}"
        GIT_TAG ${v_major}.${v_minor})

if(NOT GENERATE_CAPNP_ONLY)
    DkSDKFetchContent_MakeAvailableNoInstall(dksdk-ffi-c dksdk-ffi-java)
endif()

# --- Fetch ocaml-backend for its Schema.java file

set(SONIC_SCOUT_BACKEND_FEATURES Objs) # Legacy alternative to SONIC_SCOUT_FEATURE_COM
set(SONIC_SCOUT_FEATURE_COM)

# We only fetch if [SonicScoutBackend_SOURCE_DIR] not already supplied
DkSDKFetchContent_DeclareSecondParty(
        NAME SonicScoutBackend
        GIT_REPOSITORY "https://github.com/SquirrelScout/ocaml-backend.git"
        GIT_TAG teamNamesTable)
if(NOT GENERATE_CAPNP_ONLY AND NOT SonicScoutBackend_SOURCE_DIR)
    DkSDKFetchContent_MakeAvailableToDune(SonicScoutBackend)
endif()
