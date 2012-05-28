QT += network xml testlib
OBJECTS_DIR = obj
MOC_DIR = moc

DEFINES += QT_QWS_EBX BT_EMBEDDED BTWEB QT_NO_DEBUG_OUTPUT DEBUG
DEFINES += TEST_ENERGY_DATA=0

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
	test_energy_data.h \
	test_energy_load.h \
	test_filebrowser.h \
	test_light_objects.h \
	test_media_models.h \
	test_media_objects.h \
	test_myhome_models.h \
	test_scenario_objects.h \
	test_stopandgo_objects.h \
	test_splitscenarios_object.h \
	test_thermal_objects.h \
	test_thermalprobes_object.h \
	test_videodoorentry_objects.h \
	objecttester.h \
	devices/test/openserver_mock.h \
	ts/main.h \
	common_files/logger.h

SOURCES += test_main.cpp \
	test_antintrusion_object.cpp \
	test_btobject.cpp \
	test_energy_data.cpp \
	test_energy_load.cpp \
	test_filebrowser.cpp \
	test_light_objects.cpp \
	test_media_models.cpp \
	test_media_objects.cpp \
	test_myhome_models.cpp \
	test_scenario_objects.cpp \
	test_stopandgo_objects.cpp \
	test_splitscenarios_object.cpp \
	test_thermal_objects.cpp \
	test_thermalprobes_object.cpp \
	test_videodoorentry_objects.cpp \
	objecttester.cpp \
	devices/test/openserver_mock.cpp \
	ts/definitions.cpp

include(../btobjects.pri)
