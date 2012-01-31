TEMPLATE = lib
TARGET = btobjects
QT += declarative network xml
CONFIG += qt plugin


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

    TARGET = $${TARGET}.x86

    OBJECTS_DIR = obj/x86
    MOC_DIR = moc/x86

} else {
    message(ARM architecture detected.)

    TARGET = $${TARGET}.arm
    OBJECTS_DIR = obj/arm
    MOC_DIR = moc/arm
}


DEFINES += OPENSERVER_ADDR=\\\"openserver\\\"

INCLUDEPATH += ./common_files

TARGET = $$qtLibraryTarget($$TARGET)



# Input
SOURCES += btobjectsplugin.cpp
HEADERS += btobjectsplugin.h


INCLUDEPATH += . ./ts ./devices
DEPENDPATH += . ./ts ./devices

HEADERS += \
    antintrusionsystem.h \
    lightobjects.h \
    objectlistmodel.h \
    objectinterface.h \
    thermalobjects.h \
    thermalprobes.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    antintrusionsystem.cpp \
    lightobjects.cpp \
    objectlistmodel.cpp \
    thermalobjects.cpp \
    thermalprobes.cpp


HEADERS += \
    antintrusion_device.h \
    bttime.h \
    device.h \
    devices_cache.h \
    frame_classes.h \
    frame_functions.h \
    lighting_device.h \
    openclient.h \
    probe_device.h \
    pulldevice.h \
    scaleconversion.h \
    thermal_device.h \
    xml_functions.h

SOURCES += \
    antintrusion_device.cpp \
    bttime.cpp \
    device.cpp \
    devices_cache.cpp \
    frame_classes.cpp \
    frame_functions.cpp \
    lighting_device.cpp \
    openclient.cpp \
    probe_device.cpp \
    pulldevice.cpp \
    scaleconversion.cpp \
    thermal_device.cpp \
    xml_functions.cpp

OTHER_FILES = qmldir

