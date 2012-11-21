QT -= gui

include(../hwtest.pri)
!isArm() {
	message(x86 architecture detected.)

	HARDWARE = x86
} else {
	message(ARM architecture detected.)

	HARDWARE = arm
}

DESTDIR = ../bin/$${HARDWARE}
HEADERS       = gstmediaplayer.h
SOURCES       = gstmediaplayer.cpp gstmain.cpp

# Add gstreamer
CONFIG += link_pkgconfig
PKGCONFIG += gstreamer-0.10

isEmpty(PREFIX) {
	target.path = $${OUT_PWD}/../dist/$${HARDWARE}
} else {
	target.path = $${PREFIX}
}

INSTALLS += target
