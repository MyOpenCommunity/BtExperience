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

INCLUDEPATH += ./common_files ../gui ../BtObjects ../BtObjects/ts ../BtObjects/../../libqtdevices
DEPENDPATH += . ../../libqtdevices ../gui ../BtObjects ../BtObjects/ts
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
    ../BtObjects/../../libqtdevices/device.cpp \
    ../BtObjects/../../libqtdevices/devices_cache.cpp \
    ../BtObjects/../../libqtdevices/frame_classes.cpp \
    ../BtObjects/../../libqtdevices/frame_functions.cpp \
    ../BtObjects/../../libqtdevices/openclient.cpp \
    ../BtObjects/../../libqtdevices/xml_functions.cpp \
    ../BtObjects/configfile.cpp \
    ../BtObjects/iteminterface.cpp \
    ../BtObjects/linkinterface.cpp \
    ../BtObjects/medialink.cpp \
    ../BtObjects/paths.cpp \
    ../BtObjects/ts/signalshandler.cpp \
    ../gui/applicationcommon.cpp \
    ../gui/eventfilters.cpp \
    ../gui/globalpropertiescommon.cpp \
    ../gui/guisettings.cpp \
    ../gui/imagereader.cpp \
    ../gui/inputcontextwrapper.cpp \
    browser.cpp \
    browserproperties.cpp \
    networkmanager.cpp \
    networkreply.cpp

HEADERS += \
    ../BtObjects/../../libqtdevices/device.h \
    ../BtObjects/../../libqtdevices/devices_cache.h \
    ../BtObjects/../../libqtdevices/frame_classes.h \
    ../BtObjects/../../libqtdevices/frame_functions.h \
    ../BtObjects/../../libqtdevices/openclient.h \
    ../BtObjects/../../libqtdevices/xml_functions.h \
    ../BtObjects/configfile.h \
    ../BtObjects/iteminterface.h \
    ../BtObjects/linkinterface.h \
    ../BtObjects/medialink.h \
    ../BtObjects/paths.h \
    ../BtObjects/ts/signalshandler.h \
    ../gui/applicationcommon.h \
    ../gui/eventfilters.h \
    ../gui/globalpropertiescommon.h \
    ../gui/guisettings.h \
    ../gui/imagereader.h \
    ../gui/inputcontextwrapper.h \
    browserproperties.h \
    networkmanager.h \
    networkreply.h

