APPLICATION_NAME=consolinno-energy
ORGANISATION_NAME=consolinno

PACKAGE_URN=hems.consolinno.energy
PACKAGE_NAME=consolinno-energy

IOS_BUNDLE_PREFIX=hems.consolinno
IOS_BUNDLE_NAME=energy
IOS_DEVELOPMENT_TEAM.name=Consolinno Energy GmbH
IOS_DEVELOPMENT_TEAM.value=J757FFDWU9

VERSION_INFO=$$cat(version.txt)
APP_VERSION=$$member(VERSION_INFO, 0)
APP_REVISION=$$member(VERSION_INFO, 1)
