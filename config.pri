# We use an empirical test to recognize the platform.
defineTest(isArm) {
    # In this case we are searching for the substring 'arm' in the QMAKE_CXX
    # predefined variable, which usually contains the compiler name
    TEST_QMAKE_CXX = $$find(QMAKE_CXX,arm)
    !isEmpty(TEST_QMAKE_CXX) {
        return(true)
    }
    # With Open Embedded builds, QMAKE_CXX is only a reference to the OE_QMAKE_CXX
    # environment variable, so we cannot use the above test, but we have to extract
    # the value from OE_QMAKE_CXX and test it.
    OECXX = $$(OE_QMAKE_CXX)
    TEST_OE_QMAKE_CXX = $$find(OECXX,arm)
    !isEmpty(TEST_OE_QMAKE_CXX) {
        return(true)
    }
    return (false)
}

!isArm() {
    message(x86 architecture detected.)

    HARDWARE = x86

    OBJECTS_DIR = obj/x86
    MOC_DIR = moc/x86

    LIBS += -L$${_PRO_FILE_PWD_}/common_files/lib/x86 -lcommon -lexpat
} else {
    message(ARM architecture detected.)

    HARDWARE = arm

    OBJECTS_DIR = obj/arm
    MOC_DIR = moc/arm

    LIBS += -L$${_PRO_FILE_PWD_}/common_files -lcommon -lexpat
}

#INSTALL_CMD = cp -LR
INSTALL_CMD = ln -sf
