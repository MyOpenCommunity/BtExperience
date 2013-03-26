QT += declarative network xml testlib
OBJECTS_DIR = obj
MOC_DIR = moc

DEFINES += QT_QWS_EBX BT_EMBEDDED BTWEB QT_NO_DEBUG_OUTPUT DEBUG
DEFINES += TEST_ENERGY_DATA=0
DEFINES += BT_EXPERIENCE_TODO_REVIEW_ME

INCLUDEPATH+= . .. ../.. ../../../common_files ../../../stackopen
INCLUDEPATH+= ../../../stackopen/common_develer/lib
INCLUDEPATH+= ../ts ../devices ../devices/test
DEPENDPATH+= . .. ../..

TARGET = test
CONFIG   += console
CONFIG   -= app_bundle

CONFIG += debug
CONFIG -= release

# Add gstreamer by default, it's needed for video playback
CONFIG += link_pkgconfig
PKGCONFIG += gstreamer-0.10

QMAKE_CXXFLAGS_WARN_ON += -Wno-unused-parameter

TEMPLATE = app

LIBS+= -L ../../../common_files/lib/x86 -lcommon -lssl

DEPENDPATH = ../.. ..

HEADERS += \
	test_alarm_clock.h \
	test_antintrusion_object.h \
	test_automation_objects.h \
	test_btobject.h \
	test_energy_data.h \
	test_energy_load.h \
	test_filebrowser.h \
	test_light_objects.h \
	test_media_models.h \
	test_media_objects.h \
	test_messages_system.h \
	test_multimedia_player.h \
	test_myhome_models.h \
	test_scenario_objects.h \
	test_screenstate.h \
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
	test_alarm_clock.cpp \
	test_antintrusion_object.cpp \
	test_automation_objects.cpp \
	test_btobject.cpp \
	test_energy_data.cpp \
	test_energy_load.cpp \
	test_filebrowser.cpp \
	test_light_objects.cpp \
	test_media_models.cpp \
	test_media_objects.cpp \
	test_messages_system.cpp \
	test_multimedia_player.cpp \
	test_myhome_models.cpp \
	test_scenario_objects.cpp \
	test_screenstate.cpp \
	test_stopandgo_objects.cpp \
	test_splitscenarios_object.cpp \
	test_thermal_objects.cpp \
	test_thermalprobes_object.cpp \
	test_videodoorentry_objects.cpp \
	objecttester.cpp \
	devices/test/openserver_mock.cpp \
	ts/definitions.cpp

include(../btobjects.pri)
include(../../config.pri)
