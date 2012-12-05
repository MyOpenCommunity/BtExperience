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

#define GRABBER_START_TIME 2000


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
	cctv->video_grabber.terminate();
	cctv->video_grabber.waitForFinished(300);

	delete intercom->dev;
	delete intercom;
	delete cctv->dev;
	delete cctv;
	delete dev;

	TestBtObject::clearAllClients();
}

void TestVideoDoorEntry::compareClientCommandThatWorks(int timeout)
{
	TestBtObject::flushCompressedFrames(dev);
	TestBtObject::flushCompressedFrames(cctv->dev);
	TestBtObject::flushCompressedFrames(intercom->dev);

	TestBtObject::compareClientCommand();
	TestBtObject::clearAllClients();
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
					<< SIGNAL(callEnded()));
	intercom->valueReceived(v);
	t2.checkSignals();
}

void TestVideoDoorEntry::testIncomingCallTerminatedByTalker()
{
	// call arrives
	DeviceValues v;
	dev->is_calling = true;
	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();

	// answering
	intercom->answerCall();
	dev->answerCall();

	compareClientCommandThatWorks();

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

	// sets internal state on devices
	dev->is_calling = true;
	dev->kind = 6;
	dev->mmtype = 2;
	intercom->dev->is_calling = true;
	intercom->dev->kind = 6;
	intercom->dev->mmtype = 2;

	// call arrives
	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;
	intercom->valueReceived(v);
	v.clear();

	// answering
	intercom->answerCall();
	dev->answerCall();

	compareClientCommandThatWorks();

	// talker address arrives
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString("garage"), intercom->getTalker());

	// call terminates
	QCOMPARE(true, dev->isCalling());
	intercom->endCall();
	dev->endCall();
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
	t.checkSignalCount(SIGNAL(talkerChanged()), 2);

	compareClientCommandThatWorks();
}

void TestVideoDoorEntry::testOutgoingCallTerminatedByTalker()
{
	DeviceValues v;
	ObjectTester t(intercom, SignalList()
				   << SIGNAL(callEnded())
				   << SIGNAL(talkerChanged())
				   << SIGNAL(callAnswered()));
	ExternalPlace ep("", ObjectInterface::IdInternalIntercom, "21");

	// starts a call
	intercom->startCall(&ep);
	dev->internalIntercomCall("21");
	QCOMPARE(QString("portone"), intercom->getTalker());

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
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
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callActive());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::ANSWER_CALL signal
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
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

void TestVideoDoorEntry::testRingtone()
{
	DeviceValues v;
	ObjectTester t(intercom, SIGNAL(ringtoneChanged()));
	ObjectTester tfc(intercom, SIGNAL(floorRingtoneReceived()));

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::FLOORCALL;
	intercom->valueReceived(v);
	t.checkSignals();
	tfc.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);

	intercom->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PI_INTERCOM;
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Internal);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE_INTERCOM;
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::External);
}

void TestVideoDoorEntry::testOutgoingPagerCall()
{
	DeviceValues v;
	ObjectTester t(intercom, SignalList()
				   << SIGNAL(callEnded())
				   << SIGNAL(talkerChanged())
				   << SIGNAL(callAnswered()));

	// starts a call
	intercom->startPagerCall();
	dev->pagerCall();

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21";
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString("portone"), intercom->getTalker());

	// call terminated by talker
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkSignalCount(SIGNAL(callEnded()), 1);
	t.checkSignalCount(SIGNAL(talkerChanged()), 2);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
}

void TestVideoDoorEntry::testIncomingPagerCallIAnswer()
{
	// call arrives
	DeviceValues v;
	dev->is_calling = true;
	intercom->dev->caller_address = dev->caller_address = "21#2";
	v[VideoDoorEntryDevice::PAGER_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));

	// answering
	intercom->answerPagerCall();
	dev->answerPagerCall();

	t2.checkSignals();
	QCOMPARE(QString("garage"), intercom->getTalker());

	compareClientCommandThatWorks();

	// call terminates
	v.clear();
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;

	ObjectTester t3(intercom, SignalList()
					<< SIGNAL(callEnded())
					<< SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t3.checkSignals();
}

void TestVideoDoorEntry::testIncomingPagerCallAnotherAnswer()
{
	// call arrives
	DeviceValues v;
	dev->is_calling = true;
	intercom->dev->caller_address = dev->caller_address = "21#2";
	QCOMPARE(QString(), intercom->getTalker());
	QCOMPARE(false, intercom->callActive());
	v[VideoDoorEntryDevice::PAGER_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(true, intercom->callActive());

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));

	// someone else answers
	v.clear();
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString(), intercom->getTalker());
	QCOMPARE(false, intercom->callActive());

	t2.checkNoSignals();
}

void TestVideoDoorEntry::testFloorCall()
{
	DeviceValues v;
	ObjectTester tr(intercom, SIGNAL(ringtoneChanged()));
	ObjectTester tfc(intercom, SIGNAL(floorRingtoneReceived()));

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::FLOORCALL;
	intercom->valueReceived(v);
	tr.checkSignals();
	tfc.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);

	intercom->valueReceived(v);
	tr.checkNoSignals();
	tfc.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);
}

void TestVideoDoorEntry::testCCTVIgnoringFramesIfNotActive()
{
	DeviceValues v;
	ObjectTester t(cctv, SIGNAL(callEnded()));

	QCOMPARE(false, cctv->callActive());

	// sending a "spurious" VideoDoorEntryDevice::STOP_VIDEO signal
	v[VideoDoorEntryDevice::STOP_VIDEO] = true;
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
	ObjectTester ti(cctv, SIGNAL(incomingCall()));
	ObjectTester t(cctv, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callAnswered())
				   << SIGNAL(callEnded()));
	ExternalPlace ep("", ObjectInterface::IdExternalPlace, "21");

	// starts a call
	cctv->cameraOn(&ep);
	dev->cameraOn("21");

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(ti.waitForSignal(GRABBER_START_TIME));

	// protocol for CCTV needs the following
	cctv->answerCall();
	dev->answerCall();

	compareClientCommandThatWorks();

	// answer confirmation
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	cctv->valueReceived(v);
	v.clear();

	// caller terminates call
	cctv->endCall();
	dev->endCall();

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
}

void TestVideoDoorEntry::testCCTVOutgoingCallTerminatedByTalker()
{
	DeviceValues v;
	ObjectTester ti(cctv, SIGNAL(incomingCall()));
	ObjectTester t(cctv, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callAnswered())
				   << SIGNAL(callEnded()));
	ExternalPlace ep("", ObjectInterface::IdExternalPlace, "21");

	// starts a call
	cctv->cameraOn(&ep);
	dev->cameraOn("21");

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(ti.waitForSignal(GRABBER_START_TIME));

	// sets internal state on devices
	dev->is_calling = true;
	dev->kind = 4;
	dev->mmtype = 2;
	cctv->dev->is_calling = true;
	cctv->dev->kind = 4;
	cctv->dev->mmtype = 2;

	// protocol for CCTV needs the following
	cctv->answerCall();
	dev->answerCall();

	compareClientCommandThatWorks();

	// answer confirmation
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	cctv->valueReceived(v);
	v.clear();

	// callee terminates call
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	cctv->valueReceived(v);
	v.clear();

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
}

void TestVideoDoorEntry::testCCTVRingtone()
{
	DeviceValues v;
	ObjectTester t(cctv, SIGNAL(ringtoneChanged()));

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE4;
	cctv->valueReceived(v);
	t.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace4);

	cctv->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace4);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE1;
	cctv->valueReceived(v);
	t.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace1);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE2;
	cctv->valueReceived(v);
	t.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace2);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE3;
	cctv->valueReceived(v);
	t.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace3);
}

void TestVideoDoorEntry::testAutoOpen()
{
	ObjectTester t(cctv, SIGNAL(autoOpenChanged()));

	cctv->setAutoOpen(true);
	t.checkSignals();

	DeviceValues v;

	// arrives a call
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	// opens door
	dev->openLock();
	dev->releaseLock();

	compareClientCommandThatWorks();
}

void TestVideoDoorEntry::testHandsFree()
{
	ObjectTester t(cctv, SIGNAL(handsFreeChanged()));

	cctv->setHandsFree(true);
	t.checkSignals();

	DeviceValues v;
	ObjectTester ti(cctv, SIGNAL(incomingCall()));
	ObjectTester t2(cctv, SignalList()
					<< SIGNAL(incomingCall())
					<< SIGNAL(callAnswered())
					<< SIGNAL(callEnded()));

	// arrives a call
	v[VideoDoorEntryDevice::VCT_CALL] = QString("21");
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(ti.waitForSignal(GRABBER_START_TIME));

	// auto answer
	dev->answerCall();

	compareClientCommandThatWorks();

	// answer confirmation
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	cctv->valueReceived(v);
	v.clear();

	// callee terminates call
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	cctv->valueReceived(v);
	v.clear();

	t2.checkSignalCount(SIGNAL(incomingCall()), 1);
	t2.checkSignalCount(SIGNAL(callAnswered()), 1);
	t2.checkSignalCount(SIGNAL(callEnded()), 1);
}
