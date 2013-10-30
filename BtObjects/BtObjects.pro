TEMPLATE = lib
TARGET = btobjects
QT += declarative network xml
CONFIG += qt plugin

include(../config.pri)

DEFINES += OPENSERVER_ADDR=\\\"openserver\\\"
DEFINES += XML_SERVER_ADDRESS=\\\"openserver\\\"
DEFINES += BT_EXPERIENCE_TODO_REVIEW_ME

INCLUDEPATH += ./common_files
DEPENDPATH += . ../../libqtdevices ../..

TARGET = $$qtLibraryTarget($$TARGET)

DESTDIR = ../bin/$${HARDWARE}/BtObjects

isEmpty(PREFIX) {
    target.path = $${OUT_PWD}/../dist/$${HARDWARE}/BtObjects
} else {
    target.path = $${PREFIX}/BtObjects/
}

INSTALLS += target

# Input
SOURCES += btobjectsplugin.cpp
HEADERS += btobjectsplugin.h

INCLUDEPATH += . ../../ ../../libqtdevices

include(btobjects.pri)

OTHER_FILES += \
	qmldir \
	BtObjects.dox \

