# CMake overlay configuration for Consolinno-HEMS
#
# Only list values here that CMake actually reads (APPLICATION_NAME,
# ORGANISATION_NAME and NYMEA_APP_BINARY_NAME, consumed via config.h.in and
# the nymea-app executable target). Windows installer packaging
# (PACKAGE_URN/PACKAGE_NAME) and iOS bundle/signing settings
# (IOS_BUNDLE_PREFIX/IOS_BUNDLE_NAME/IOS_DEVELOPMENT_TEAM) are not read by
# CMake at all; those are the sole responsibility of build_windows.ps1 and
# build_ios.sh respectively. Keeping unused duplicates of those values here
# previously caused them to silently drift out of sync - see ESUI-1682.

set(APPLICATION_NAME "consolinno-energy" CACHE STRING "Application name" FORCE)

# The compiled executable's output filename always matches APPLICATION_NAME.
# Derived here (with FORCE) so build scripts no longer need to pass
# -DNYMEA_APP_BINARY_NAME themselves - any such flag would silently be
# overridden by this FORCE anyway.
set(NYMEA_APP_BINARY_NAME "${APPLICATION_NAME}" CACHE STRING "Compiled executable output name" FORCE)

set(ORGANISATION_NAME "consolinno" CACHE STRING "Organisation name" FORCE)

# Version handling is identical for every variant, so it lives in a shared
# file in the overlay itself rather than being duplicated here.
include("${NYMEA_OVERLAY_PATH}/overlay-version.cmake")
