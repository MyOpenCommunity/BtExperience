/*
 * BTouch - Graphical User Interface to control MyHome System
 *
 * Copyright (C) 2010 BTicino S.p.A.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef TEST_VIDEODOORENTRY_OBJECTS_H
#define TEST_VIDEODOORENTRY_OBJECTS_H

#include "test_btobject.h"


class CCTV;
class Intercom;
class VideoDoorEntryDevice;


class TestVideoDoorEntry : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testIncomingCallNoAnswer();
	void testIncomingCallTerminatedByTalker();
	void testIncomingCallTerminatedByTouch();
	void testOutgoingCallTerminatedByTalker();
	void testIgnoringFramesIfNotActive();
	void testFloorCall();
	void testRingtone();
	void testOutgoingPagerCall();
	void testIncomingPagerCallIAnswer();
	void testIncomingPagerCallAnotherAnswer();

	void testCCTVIgnoringFramesIfNotActive();
	void testCCTVOutgoingCallTerminatedByTouch();
	void testCCTVOutgoingCallTerminatedByTalker();
	void testCCTVRingtone();
	void testCCTVTeleloop();
	void testAutoOpen();
	void testHandsFree();
	void testCCTVTeleloopAssociate();
	void testCCTVTeleloopTimeouFrame();
	void testCCTVTeleloopTimeouTimer();

protected:
	void compareClientCommandThatWorks(int timeout = 0);

private:
	CCTV *cctv;
	Intercom *intercom;
	VideoDoorEntryDevice *dev;
};

#endif // TEST_VIDEODOORENTRY_OBJECTS_H
