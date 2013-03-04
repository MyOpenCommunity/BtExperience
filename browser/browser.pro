QT += declarative opengl xml

# Please do not modify the following two lines. Required for deployment.
include(../gui/qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

include(../config.pri)

QT += network declarative webkit

!mac {
    # '\$\$' outputs $$ to the Makefile, make transforms $$ into a single $, then you need a backslash for the shell
    LIBS += -Wl,-rpath=\\'\$\$'ORIGIN:\\'\$\$'ORIGIN/BtObjects
}

maliit {
    CONFIG += link_pkgconfig
    PKGCONFIG += maliit-1.0 maliit-settings-1.0
    DEFINES += BT_MALIIT
}

INCLUDEPATH += ./common_files ../gui ../BtObjects ../BtObjects/ts ../BtObjects/devices
DEPENDPATH += . devices ../gui ../BtObjects ../BtObjects/ts
LIBS += -lssl

DESTDIR = ../bin/$${HARDWARE}

isEmpty(PREFIX) {
    target.path = $${OUT_PWD}/../dist/$${HARDWARE}
} else {
    target.path = $${PREFIX}
}

INSTALLS += target

# Input
SOURCES += \
    browser.cpp \
    ../BtObjects/configfile.cpp \
    ../BtObjects/iteminterface.cpp \
    ../BtObjects/linkinterface.cpp \
    ../BtObjects/medialink.cpp \
    ../BtObjects/devices/device.cpp \
    ../BtObjects/ts/devices_cache.cpp \
    ../BtObjects/ts/frame_classes.cpp \
    ../BtObjects/ts/frame_functions.cpp \
    ../BtObjects/ts/openclient.cpp \
    ../BtObjects/ts/signalshandler.cpp \
    ../BtObjects/ts/xml_functions.cpp \
    ../gui/applicationcommon.cpp \
    ../gui/eventfilters.cpp \
    ../gui/globalpropertiescommon.cpp \
    ../gui/guisettings.cpp \
    ../gui/imagereader.cpp \
    ../gui/inputcontextwrapper.cpp \
    networkmanager.cpp \
    networkreply.cpp \
    browserproperties.cpp

HEADERS += \
    ../BtObjects/configfile.h \
    ../BtObjects/iteminterface.h \
    ../BtObjects/linkinterface.h \
    ../BtObjects/medialink.h \
    ../BtObjects/devices/device.h \
    ../BtObjects/ts/devices_cache.h \
    ../BtObjects/ts/frame_classes.h \
    ../BtObjects/ts/frame_functions.h \
    ../BtObjects/ts/openclient.h \
    ../BtObjects/ts/signalshandler.h \
    ../BtObjects/ts/xml_functions.h \
    ../gui/applicationcommon.h \
    ../gui/eventfilters.h \
    ../gui/globalpropertiescommon.h \
    ../gui/guisettings.h \
    ../gui/imagereader.h \
    ../gui/inputcontextwrapper.h \
    networkmanager.h \
    networkreply.h \
    browserproperties.h

