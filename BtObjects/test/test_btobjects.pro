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

VPATH = ../.. ..

HEADERS += test_antintrusion_object.h \
	test_btobject.h \
	test_thermalprobes_object.h \
	objecttester.h \
	../devices/antintrusion_device.h \
	../devices/device.h \
	../devices/probe_device.h \
	../devices/test/openserver_mock.h \
	../ts/delayedslotcaller.h \
	../ts/frame_classes.h \
	../ts/openclient.h \
	../ts/frame_functions.h \
	../ts/devices_cache.h \
	../ts/xml_functions.h \
	../ts/main.h \
	../ts/scaleconversion.h \
	../common_files/logger.h

SOURCES += test_main.cpp \
	test_antintrusion_object.cpp \
	test_btobject.cpp \
	test_thermalprobes_object.cpp \
	objecttester.cpp \
	../devices/antintrusion_device.cpp \
	../devices/device.cpp \
	../devices/probe_device.cpp \
	../devices/test/openserver_mock.cpp \
	../ts/delayedslotcaller.cpp \
	../ts/openclient.cpp \
	../ts/frame_functions.cpp \
	../ts/devices_cache.cpp \
	../ts/xml_functions.cpp \
	../ts/definitions.cpp \
	../ts/frame_classes.cpp \
	../ts/scaleconversion.cpp

include(../btobjects.pri)
