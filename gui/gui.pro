# Add more folders to ship with the application, here
folder_01.source = skins/default
folder_01.target = skins
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

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

    TARGET = BtExperience.x86
    OBJECTS_DIR = obj/x86
    MOC_DIR = moc/x86

    LIBS += -L./common_files/lib/x86 -lcommon -lexpat

} else {
    message(ARM architecture detected.)

    TARGET = BtExperience.arm
    OBJECTS_DIR = obj/arm
    MOC_DIR = moc/arm

    LIBS += -L./common_files -lcommon -lexpat
}

INCLUDEPATH += ./common_files
LIBS += -lssl

maliit {
    CONFIG += link_pkgconfig
    PKGCONFIG += maliit-1.0
    DEFINES += BT_MALIIT
}

QT += opengl


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    main.cpp \
    eventfilters.cpp \
    globalproperties.cpp \
    inputcontextwrapper.cpp

DESTDIR = ..

HEADERS += \
    eventfilters.h \
    globalproperties.h \
    inputcontextwrapper.h

TRANSLATIONS += linguist-ts/bt_experience_it.ts
