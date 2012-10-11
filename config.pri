include(hwtest.pri)

!isArm() {
    message(x86 architecture detected.)

    HARDWARE = x86

    OBJECTS_DIR = obj/x86
    MOC_DIR = moc/x86
    DEFINES += BT_HARDWARE_X11

    LIBS += -L$${_PRO_FILE_PWD_}/common_files/lib/x86 -lcommon -lexpat
} else {
    message(ARM architecture detected.)

    HARDWARE = arm

    OBJECTS_DIR = obj/arm
    MOC_DIR = moc/arm
    DEFINES += BT_HARDWARE_DM3730

    LIBS += -L$${_PRO_FILE_PWD_}/common_files -lcommon -lexpat
}

CONFIG(debug,debug|release) {
	message(*** Debug build)
	DEFINES += DEBUG
}

CONFIG(release,debug|release) {
	message(*** Release build)
	DEFINES += NO_QT_DEBUG_OUTPUT
}

#INSTALL_CMD = cp -LR
INSTALL_CMD = ln -sf
