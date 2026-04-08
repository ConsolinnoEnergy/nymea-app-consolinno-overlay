# CMake overlay configuration for Consolinno-HEMS
# Equivalent to overlay-config.pri

set(APPLICATION_NAME "consolinno-energy" CACHE STRING "Application name" FORCE)
set(ORGANISATION_NAME "consolinno" CACHE STRING "Organisation name" FORCE)
set(PACKAGE_URN "hems.consolinno.energy" CACHE STRING "Package URN" FORCE)
set(PACKAGE_NAME "consolinno-energy" CACHE STRING "Package name" FORCE)

# iOS settings
set(IOS_BUNDLE_PREFIX "consolinno.hems" CACHE STRING "iOS bundle prefix" FORCE)
set(IOS_BUNDLE_NAME "energy" CACHE STRING "iOS bundle name" FORCE)
set(IOS_DEVELOPMENT_TEAM "J757FFDWU9" CACHE STRING "iOS development team" FORCE)

# Read version from overlay's version.txt
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
