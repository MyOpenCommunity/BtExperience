QT += network xml testlib
OBJECTS_DIR = obj
MOC_DIR = moc

DEFINES += QT_QWS_EBX BT_EMBEDDED BTWEB QT_NO_DEBUG_OUTPUT DEBUG

INCLUDEPATH+= . .. ../.. ../../../common_files ../../../stackopen
INCLUDEPATH+= ../../../stackopen/common_develer/lib
INCLUDEPATH+= ../ts ../devices ../devices/test
DEPENDPATH+= . .. ../..

TARGET = test
CONFIG   += console
CONFIG   -= app_bundle

CONFIG += debug
CONFIG -= release

QMAKE_CXXFLAGS_WARN_ON += -Wno-unused-parameter

TEMPLATE = app

LIBS+= -L ../../../common_files/lib/x86 -lcommon -lssl

DEPENDPATH = ../.. ..

HEADERS += test_antintrusion_object.h \
	test_btobject.h \
	test_media_objects.h \
	test_thermal_objects.h \
	test_thermalprobes_object.h \
	objecttester.h \
	devices/test/openserver_mock.h \
	ts/main.h \
	common_files/logger.h

SOURCES += test_main.cpp \
	test_antintrusion_object.cpp \
	test_btobject.cpp \
	test_media_objects.cpp \
	test_thermal_objects.cpp \
	test_thermalprobes_object.cpp \
	objecttester.cpp \
	devices/test/openserver_mock.cpp \
	ts/definitions.cpp

include(../btobjects.pri)
