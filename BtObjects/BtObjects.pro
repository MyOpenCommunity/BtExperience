TEMPLATE = lib
TARGET = btobjects
QT += declarative network xml
CONFIG += qt plugin

include(../config.pri)

DEFINES += OPENSERVER_ADDR=\\\"openserver\\\"
DEFINES += XML_SERVER_ADDRESS=\\\"openserver\\\"

INCLUDEPATH += ./common_files
DEPENDPATH += . devices ts

TARGET = $$qtLibraryTarget($$TARGET)

DESTDIR = ../bin/$${HARDWARE}/BtObjects

isEmpty(PREFIX) {
    target.path = ../dist/$${HARDWARE}/BtObjects
} else {
    target.path = $${PREFIX}/BtObjects/
}

INSTALLS += target

# Input
SOURCES += btobjectsplugin.cpp
HEADERS += btobjectsplugin.h

INCLUDEPATH += . ./ts ./devices

include(btobjects.pri)

OTHER_FILES = qmldir

