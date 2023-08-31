!equals(OVERLAY_PATH, "") {
    TRANSLATIONS += $$files($${OVERLAY_PATH}/translations/*ts, true)
}
