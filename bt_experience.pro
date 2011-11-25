# Add more folders to ship with the application, here
folder_01.source = qml/bt_experience
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

RESOURCES +=

TARGET = BtExperience

OBJECTS_DIR = obj
MOC_DIR = moc

QT += opengl network

# x86
DEFINES += OPENSERVER_ADDR=\\\"btouch_10\\\"
LIBS += -L./common_files/lib/x86 -lcommon
INCLUDEPATH += ./common_files

INCLUDEPATH += . ./ts ./devices
DEPENDPATH += . ./ts ./devices

HEADERS += \
    objectlistmodel.h \
    lightobjects.h \
    thermalobjects.h \
    objectinterface.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    objectlistmodel.cpp \
    lightobjects.cpp \
    thermalobjects.cpp


HEADERS += \
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
    thermal_device.h

SOURCES += \
    bttime.cpp \
    definitions.cpp \
    device.cpp \
    devices_cache.cpp \
    frame_classes.cpp \
    frame_functions.cpp \
    lighting_device.cpp \
    openclient.cpp \
    probe_device.cpp \
    pulldevice.cpp \
    scaleconversion.cpp \
    thermal_device.cpp

