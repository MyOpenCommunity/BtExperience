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

#include "test_videodoorentry_objects.h"

#include "openserver_mock.h"
#include "openclient.h"
#include "objecttester.h"

#include "vct.h"
#include "videodoorentry_device.h"

#include <QtTest/QtTest>
#include <QPair>


void TestVideoDoorEntry::init()
{
	dev = new VideoDoorEntryDevice("11", "0", 1);

	// for tests we use the same list of external places, in real code we
	// expect to have different lists
	QList<ExternalPlace *> l;
	l << new ExternalPlace("portone", ObjectInterface::IdExternalPlace, "21");
	l << new ExternalPlace("garage", ObjectInterface::IdExternalPlace, "21#2");

	cctv = new CCTV(l, new VideoDoorEntryDevice("11", "0"));

	intercom = new Intercom(l, new VideoDoorEntryDevice("11", "0"));
}

void TestVideoDoorEntry::cleanup()
{
	delete intercom->dev;
	delete intercom;
	delete cctv->dev;
	delete cctv;
	delete dev;
}

void TestVideoDoorEntry::compareClientCommand(int timeout)
{
	TestBtObject::flushCompressedFrames(dev);
	TestBtObject::flushCompressedFrames(cctv->dev);
	TestBtObject::flushCompressedFrames(intercom->dev);

	TestBtObject::compareClientCommand();
}

void TestVideoDoorEntry::testIncomingCallNoAnswer()
{
	// call arrives
	DeviceValues v;
	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();

	// call terminates
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;

	ObjectTester t2(intercom, SignalList()
					<< SIGNAL(callEnded())
					<< SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t2.checkSignals();
}

void TestVideoDoorEntry::testIncomingCallTerminatedByTalker()
{
	// call arrives
	DeviceValues v;
	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();

	// answering
	intercom->answerCall();
	dev->answerCall();

	compareClientCommand();

	// talker address arrives
	v.clear();
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t2.checkSignals();
	QCOMPARE(QString("garage"), intercom->getTalker());

	// call terminates
	v.clear();
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;

	ObjectTester t3(intercom, SignalList()
					<< SIGNAL(callEnded())
					<< SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t3.checkSignals();
}

void TestVideoDoorEntry::testIncomingCallTerminatedByTouch()
{
	DeviceValues v;
	ObjectTester t(intercom, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callEnded())
				   << SIGNAL(talkerChanged()));

	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;

	// call arrives
	intercom->valueReceived(v);
	v.clear();

	// answering
	intercom->answerCall();
	dev->answerCall();

	compareClientCommand();

	// talker address arrives
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString("garage"), intercom->getTalker());

	// call terminates
	intercom->endCall();
	dev->endCall();
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
	t.checkSignalCount(SIGNAL(talkerChanged()), 2);

	compareClientCommand();
}

void TestVideoDoorEntry::testOutgoingCallTerminatedByTalker()
{
	DeviceValues v;
	ObjectTester t(intercom, SignalList()
				   << SIGNAL(callEnded())
				   << SIGNAL(talkerChanged())
				   << SIGNAL(callAnswered()));

	// starts a call
	intercom->startCall("21");
	dev->internalIntercomCall("21");
	QCOMPARE(QString("portone"), intercom->getTalker());

	compareClientCommand();

	// talker answers
	v[VideoDoorEntryDevice::ANSWER_CALL] = QString("21");
	intercom->valueReceived(v);
	v.clear();

	// call terminated by talker
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkSignalCount(SIGNAL(callEnded()), 1);
	t.checkSignalCount(SIGNAL(talkerChanged()), 2);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
}

void TestVideoDoorEntry::testIgnoringFramesIfNotActive()
{
	DeviceValues v;
	ObjectTester t(intercom, SIGNAL(callEnded()));

	QCOMPARE(false, intercom->callActive());

	// sending a "spurious" VideoDoorEntryDevice::END_OF_CALL signal
	v[VideoDoorEntryDevice::END_OF_CALL] = QString("21");
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callActive());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::ANSWER_CALL signal
	v[VideoDoorEntryDevice::ANSWER_CALL] = QString("21");
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callActive());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::CALLER_ADDRESS signal
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = QString("21#2");
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callActive());
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkNoSignals();
}

void TestVideoDoorEntry::testCCTVIgnoringFramesIfNotActive()
{
	DeviceValues v;
	ObjectTester t(cctv, SIGNAL(callEnded()));

	QCOMPARE(false, cctv->callActive());

	// sending a "spurious" VideoDoorEntryDevice::STOP_VIDEO signal
	v[VideoDoorEntryDevice::STOP_VIDEO] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	QCOMPARE(false, cctv->callActive());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::CALLER_ADDRESS signal
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = QString("21#2");
	cctv->valueReceived(v);
	v.clear();

	QCOMPARE(false, cctv->callActive());

	t.checkNoSignals();
}

void TestVideoDoorEntry::testCCTVOutgoingCallTerminatedByTouch()
{
	DeviceValues v;
	ObjectTester t(cctv, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callEnded()));

	// starts a call
	cctv->cameraOn("21");
	dev->cameraOn("21");

	compareClientCommand();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	// protocol for CCTV needs the following
	cctv->answerCall();
	dev->answerCall();

	compareClientCommand();

	// caller terminates call
	cctv->endCall();
	dev->endCall();

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
}

void TestVideoDoorEntry::testCCTVOutgoingCallTerminatedByTalker()
{
	DeviceValues v;
	ObjectTester t(cctv, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callEnded()));

	// starts a call
	cctv->cameraOn("21");
	dev->cameraOn("21");

	compareClientCommand();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	// protocol for CCTV needs the following
	cctv->answerCall();
	dev->answerCall();

	compareClientCommand();

	// callee terminates call
	v[VideoDoorEntryDevice::END_OF_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
}
