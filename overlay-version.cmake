# Shared (non-whitelabel-specific) overlay CMake logic.
#
# Reads the overlay's own version.txt (if present) and uses it to override
# APP_VERSION/APP_REVISION, which nymea-app/CMakeLists.txt otherwise derives
# from its own version.txt. This lets the overlay ship an independent app
# version without needing to touch nymea-app itself.
#
# This file is identical for every whitelabel variant, so it lives here
# (in the overlay itself) instead of being duplicated in each variant's
# overlay-config.cmake in the main repo. Included from there via:
#   include("${NYMEA_OVERLAY_PATH}/overlay-version.cmake")

if(EXISTS "${NYMEA_OVERLAY_PATH}/version.txt")
    file(STRINGS "${NYMEA_OVERLAY_PATH}/version.txt" _OVERLAY_VERSION_LINES)
    list(LENGTH _OVERLAY_VERSION_LINES _OVERLAY_VERSION_COUNT)
    if(_OVERLAY_VERSION_COUNT GREATER_EQUAL 1)
        list(GET _OVERLAY_VERSION_LINES 0 APP_VERSION)
    endif()
    if(_OVERLAY_VERSION_COUNT GREATER_EQUAL 2)
        list(GET _OVERLAY_VERSION_LINES 1 APP_REVISION)
    endif()
endif()
