TEMPLATE      = lib
CONFIG       += plugin qt
QT -= gui

include(../hwtest.pri)
!isArm() {
	message(x86 architecture detected.)

	HARDWARE = x86
} else {
	message(ARM architecture detected.)

	HARDWARE = arm
}

INCLUDEPATH  += ../BtObjects
HEADERS       = gstmediaplayerplugin.h \
	../BtObjects/gstmediaplayer.h
SOURCES       = gstmediaplayerplugin.cpp
TARGET        = $$qtLibraryTarget(gstmediaplayer)

DESTDIR = ../bin/$${HARDWARE}/

# Add gstreamer
CONFIG += link_pkgconfig
PKGCONFIG += gstreamer-0.10

isEmpty(PREFIX) {
	target.path = $${OUT_PWD}/../dist/$${HARDWARE}/
} else {
	target.path = $${PREFIX}/
}

INSTALLS += target
