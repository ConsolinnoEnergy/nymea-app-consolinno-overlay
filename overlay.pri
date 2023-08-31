message("Resource overlay enabled. Will be using overlay from $${OVERLAY_PATH}")
RESOURCES += $${OVERLAY_PATH}/overlay.qrc
exists($${OVERLAY_PATH}/src/src.pri) {
        message("Including sources from overlay")
        include($${OVERLAY_PATH}/src/src.pri)
        DEFINES += OVERLAY_PATH=\\\"$${OVERLAY_PATH}\\\"
        DEFINES += OVERLAY_QMLTYPES=\\\"$${OVERLAY_PATH}/src/qmltypes.h\\\"
}
