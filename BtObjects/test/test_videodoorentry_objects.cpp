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
#include "main.h" // bt_global::config

#include "vct.h"
#include "videodoorentry_device.h"

#include <QtTest/QtTest>
#include <QPair>

#define GRABBER_START_TIME 2000


void TestVideoDoorEntry::init()
{
	dev = new VideoDoorEntryDevice("11", "0", 1);

	bt_global::config = new QHash<GlobalField, QString>();
	(*bt_global::config)[PI_ADDRESS] = "11";

	// for tests we use the same list of external places, in real code we
	// expect to have different lists
	QList<ExternalPlace *> l;
	l << new ExternalPlace("portone", ObjectInterface::IdExternalPlace, "21");
	l << new ExternalPlace("garage", ObjectInterface::IdExternalPlace, "21#2");

	cctv = new CCTV(l, new VideoDoorEntryDevice("11", "0"));

	intercom = new Intercom(l, new VideoDoorEntryDevice("11", "0"), false);

	qRegisterMetaType<QProcess::ExitStatus>("QProcess::ExitStatus");
}

void TestVideoDoorEntry::cleanup()
{
	delete bt_global::config;
	bt_global::config = 0;

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
	QCOMPARE(false, intercom->exitingCall());
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(false, intercom->exitingCall());

	// call terminates
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;

	ObjectTester t2(intercom, SignalList()
					<< SIGNAL(callEnded()));
	intercom->valueReceived(v);
	t2.checkSignals();
	QCOMPARE(false, intercom->exitingCall());
}

void TestVideoDoorEntry::testIncomingCallTerminatedByTalker()
{
	// call arrives
	DeviceValues v;
	QCOMPARE(false, intercom->exitingCall());
	dev->is_calling = true;
	v[VideoDoorEntryDevice::INTERCOM_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	// answering
	intercom->answerCall();
	dev->answerCall();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	compareClientCommandThatWorks();

	// talker address arrives
	v.clear();
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t2.checkSignals();
	QCOMPARE(QString("garage"), intercom->getTalker());
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	// call terminates
	v.clear();
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;

	ObjectTester t3(intercom, SignalList()
					<< SIGNAL(callEnded())
					<< SIGNAL(talkerChanged()));
	intercom->valueReceived(v);
	t3.checkSignals();
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());
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
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	// answering
	intercom->answerCall();
	dev->answerCall();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	compareClientCommandThatWorks();

	// talker address arrives
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString("garage"), intercom->getTalker());
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	// call terminates
	QCOMPARE(true, dev->isCalling());
	intercom->endCall();
	dev->endCall();
	QCOMPARE(QString(""), intercom->getTalker());
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

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
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(true, intercom->exitingCall());

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(true, intercom->callActive());
	QCOMPARE(true, intercom->exitingCall());

	// call terminated by talker
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	QCOMPARE(QString(""), intercom->getTalker());
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	t.checkSignalCount(SIGNAL(callEnded()), 1);
	t.checkSignalCount(SIGNAL(talkerChanged()), 2);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
}

void TestVideoDoorEntry::testIgnoringFramesIfNotActive()
{
	DeviceValues v;
	ObjectTester t(intercom, SIGNAL(callEnded()));

	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->exitingCall());

	// sending a "spurious" VideoDoorEntryDevice::END_OF_CALL signal
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->exitingCall());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::ANSWER_CALL signal
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->exitingCall());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::CALLER_ADDRESS signal
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = QString("21#2");
	intercom->valueReceived(v);
	v.clear();

	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->exitingCall());
	QCOMPARE(QString(""), intercom->getTalker());

	t.checkNoSignals();
}

void TestVideoDoorEntry::testRingtone()
{
	DeviceValues v;
	ObjectTester t(intercom, SIGNAL(ringtoneChanged()));
	ObjectTester tfc(intercom, SIGNAL(floorRingtoneReceived()));
	ObjectTester trr(intercom, SIGNAL(ringtoneReceived()));

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::FLOORCALL;
	intercom->valueReceived(v);
	t.checkSignals();
	tfc.checkSignals();
	trr.checkNoSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);

	intercom->valueReceived(v);
	t.checkNoSignals();
	tfc.checkSignals();
	trr.checkNoSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Floorcall);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PI_INTERCOM;
	intercom->valueReceived(v);
	t.checkSignals();
	tfc.checkNoSignals();
	trr.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::Internal);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE_INTERCOM;
	intercom->valueReceived(v);
	t.checkSignals();
	tfc.checkNoSignals();
	trr.checkSignals();
	QCOMPARE(intercom->getRingtone(), Intercom::External);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE3;
	intercom->valueReceived(v);
	t.checkNoSignals();
	tfc.checkNoSignals();
	trr.checkNoSignals();
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
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(true, intercom->exitingCall());

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21";
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString("portone"), intercom->getTalker());
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(true, intercom->callActive());
	QCOMPARE(true, intercom->exitingCall());

	// call terminated by talker
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	QCOMPARE(QString(""), intercom->getTalker());
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

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
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));

	// answering
	intercom->answerPagerCall();
	dev->answerPagerCall();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

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
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());
}

void TestVideoDoorEntry::testIncomingPagerCallAnotherAnswer()
{
	// call arrives
	DeviceValues v;
	dev->is_calling = true;
	intercom->dev->caller_address = dev->caller_address = "21#2";
	QCOMPARE(QString(), intercom->getTalker());
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->exitingCall());
	v[VideoDoorEntryDevice::PAGER_CALL] = 0;

	ObjectTester t(intercom, SIGNAL(incomingCall()));
	intercom->valueReceived(v);
	t.checkSignals();
	QCOMPARE(true, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

	ObjectTester t2(intercom, SIGNAL(talkerChanged()));

	// someone else answers
	v.clear();
	v[VideoDoorEntryDevice::END_OF_CALL] = 0;
	intercom->valueReceived(v);
	v.clear();
	QCOMPARE(QString(), intercom->getTalker());
	QCOMPARE(false, intercom->callInProgress());
	QCOMPARE(false, intercom->callActive());
	QCOMPARE(false, intercom->exitingCall());

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

	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->exitingCall());

	// sending a "spurious" VideoDoorEntryDevice::STOP_VIDEO signal
	v[VideoDoorEntryDevice::STOP_VIDEO] = true;
	cctv->valueReceived(v);
	v.clear();

	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->exitingCall());

	t.checkNoSignals();

	// sending a "spurious" VideoDoorEntryDevice::CALLER_ADDRESS signal
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = QString("21#2");
	cctv->valueReceived(v);
	v.clear();

	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->exitingCall());

	t.checkNoSignals();
}

void TestVideoDoorEntry::testCCTVOutgoingCallTerminatedByTouch()
{
	DeviceValues v;
	ObjectTester ti(cctv, SIGNAL(incomingCall()));
	ObjectTester tstart(&cctv->video_grabber, SIGNAL(started()));
	ObjectTester t(cctv, SignalList()
				   << SIGNAL(incomingCall())
				   << SIGNAL(callAnswered())
				   << SIGNAL(callEnded()));
	ExternalPlace ep("", ObjectInterface::IdExternalPlace, "21");

	// starts a call
	cctv->cameraOn(&ep);
	dev->cameraOn("21");
	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());
	QCOMPARE(QProcess::NotRunning, cctv->video_grabber.state());
	QVERIFY(cctv->grabber_delay.isActive());

	ti.checkSignals();

	QVERIFY(tstart.waitForNewSignal(GRABBER_START_TIME));
	QVERIFY(!cctv->grabber_delay.isActive());

	// protocol for CCTV needs the following
	cctv->answerCall();
	dev->answerCall();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());

	compareClientCommandThatWorks();

	// answer confirmation
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(true, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());

	// caller terminates call
	cctv->endCall();
	dev->endCall();
	QCOMPARE(false, cctv->exitingCall());

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
	QCOMPARE(true, cctv->exitingCall());

	compareClientCommandThatWorks();

	// talker answers
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());

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
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(true, cctv->callActive());
	QCOMPARE(true, cctv->exitingCall());

	// callee terminates call
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());

	t.checkSignalCount(SIGNAL(incomingCall()), 1);
	t.checkSignalCount(SIGNAL(callAnswered()), 1);
	t.checkSignalCount(SIGNAL(callEnded()), 1);
}

void TestVideoDoorEntry::testCCTVRingtone()
{
	DeviceValues v;
	ObjectTester t(cctv, SIGNAL(ringtoneChanged()));
	ObjectTester trr(cctv, SIGNAL(ringtoneReceived()));

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE4;
	cctv->valueReceived(v);
	t.checkSignals();
	trr.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace4);

	cctv->valueReceived(v);
	t.checkNoSignals();
	trr.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace4);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE1;
	cctv->valueReceived(v);
	t.checkSignals();
	trr.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace1);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE2;
	cctv->valueReceived(v);
	t.checkSignals();
	trr.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace2);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PE3;
	cctv->valueReceived(v);
	t.checkSignals();
	trr.checkSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace3);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::PI_INTERCOM;
	cctv->valueReceived(v);
	t.checkNoSignals();
	trr.checkNoSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace3);

	v[VideoDoorEntryDevice::RINGTONE] = VideoDoorEntryDevice::FLOORCALL;
	cctv->valueReceived(v);
	t.checkNoSignals();
	trr.checkNoSignals();
	QCOMPARE(cctv->getRingtone(), CCTV::ExternalPlace3);
}

void TestVideoDoorEntry::testCCTVAudioOnly()
{
	DeviceValues v;
	ObjectTester t(cctv, SIGNAL(incomingCall()));

	// sets internal state on devices
	dev->is_calling = true;
	dev->kind = 6;
	dev->mmtype = 2;
	cctv->dev->is_calling = true;
	cctv->dev->kind = 6;
	cctv->dev->mmtype = 2;

	// call arrives
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::ONLY_AUDIO;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());

	t.checkSignals();
}

void TestVideoDoorEntry::testCCTVTeleloop()
{
	DeviceValues v;
	ObjectTester ti(cctv, SIGNAL(incomingCall()));
	ObjectTester te(cctv, SIGNAL(callEnded()));

	// sets internal state on devices
	dev->is_calling = true;
	dev->kind = 6;
	dev->mmtype = 2;
	cctv->dev->is_calling = true;
	cctv->dev->kind = 6;
	cctv->dev->mmtype = 2;

	// call arrives
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());
	QCOMPARE(false, cctv->getTeleloop());

	ti.checkSignals();

	// answered by teleloop
	v[VideoDoorEntryDevice::TELE_SESSION] = true;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(true, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());
	QCOMPARE(true, cctv->getTeleloop());

	// caller address arrives
	v[VideoDoorEntryDevice::CALLER_ADDRESS] = "21#2";
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(true, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());
	QCOMPARE(true, cctv->getTeleloop());

	// call terminates
	QCOMPARE(true, dev->isCalling());
	cctv->endCall();
	dev->endCall();
	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());
	QCOMPARE(false, cctv->getTeleloop());

	te.checkSignals();

	compareClientCommandThatWorks();
}

void TestVideoDoorEntry::testAutoOpen()
{
	ObjectTester t(cctv, SIGNAL(autoOpenChanged()));

	cctv->setAutoOpen(true);
	t.checkSignals();

	DeviceValues v;

	// arrives a call
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
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
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());

	QVERIFY(ti.waitForSignal(GRABBER_START_TIME));

	// auto answer
	dev->answerCall();

	compareClientCommandThatWorks();

	// answer confirmation
	v[VideoDoorEntryDevice::ANSWER_CALL] = true;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(true, cctv->callInProgress());
	QCOMPARE(true, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());

	// callee terminates call
	v[VideoDoorEntryDevice::END_OF_CALL] = true;
	cctv->valueReceived(v);
	v.clear();
	QCOMPARE(false, cctv->callInProgress());
	QCOMPARE(false, cctv->callActive());
	QCOMPARE(false, cctv->exitingCall());

	t2.checkSignalCount(SIGNAL(incomingCall()), 1);
	t2.checkSignalCount(SIGNAL(callAnswered()), 1);
	t2.checkSignalCount(SIGNAL(callEnded()), 1);
}

void TestVideoDoorEntry::testCCTVRearmSession()
{
	DeviceValues v;
	ObjectTester tstart(&cctv->video_grabber, SIGNAL(started()));
	ObjectTester tstop(&cctv->video_grabber, SIGNAL(finished(int,QProcess::ExitStatus)));

	// arrives a call
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(tstart.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() != QProcess::NotRunning);

	// call redirected to a different PI
	v[VideoDoorEntryDevice::STOP_VIDEO] = true;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(tstop.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() == QProcess::NotRunning);

	// receiving rearm session frame
	v[VideoDoorEntryDevice::VCT_TYPE] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(tstart.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() != QProcess::NotRunning);
}

void TestVideoDoorEntry::testCCTVRearmSessionAudioOnly()
{
	DeviceValues v;
	ObjectTester tstart(&cctv->video_grabber, SIGNAL(started()));
	ObjectTester tstop(&cctv->video_grabber, SIGNAL(finished(int,QProcess::ExitStatus)));

	// arrives a call
	v[VideoDoorEntryDevice::VCT_CALL] = VideoDoorEntryDevice::AUDIO_VIDEO;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(tstart.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() != QProcess::NotRunning);

	// call redirected to a different PI
	v[VideoDoorEntryDevice::STOP_VIDEO] = true;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(tstop.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() == QProcess::NotRunning);

	// receiving rearm session frame
	v[VideoDoorEntryDevice::VCT_TYPE] = VideoDoorEntryDevice::ONLY_AUDIO;
	cctv->valueReceived(v);
	v.clear();

	QVERIFY(!tstart.waitForSignal(GRABBER_START_TIME));
	QVERIFY(cctv->video_grabber.state() == QProcess::NotRunning);
}

void TestVideoDoorEntry::testCCTVTeleloopAssociate()
{
	ObjectTester tstart(cctv, SIGNAL(teleloopAssociationStarted()));
	ObjectTester tcompl(cctv, SIGNAL(teleloopAssociationComplete()));
	ObjectTester tchange(cctv, SIGNAL(associatedTeleloopIdChanged()));
	DeviceValues v;

	cctv->startTeleloopAssociation();
	QVERIFY(cctv->association_timeout.isActive());
	dev->startTeleLoop((*bt_global::config)[PI_ADDRESS]);
	compareClientCommand();
	tstart.checkSignals();

	v[VideoDoorEntryDevice::TELE_ANSWER] = 7;
	cctv->valueReceived(v);
	tcompl.checkSignals();
	tchange.checkSignals();

	QVERIFY(!cctv->association_timeout.isActive());
	QCOMPARE(cctv->getAssociatedTeleloopId(), 7);
}

void TestVideoDoorEntry::testCCTVTeleloopTimeouFrame()
{
	ObjectTester tstart(cctv, SIGNAL(teleloopAssociationStarted()));
	ObjectTester ttimeout(cctv, SIGNAL(teleloopAssociationTimeout()));
	DeviceValues v;

	cctv->startTeleloopAssociation();
	QVERIFY(cctv->association_timeout.isActive());
	dev->startTeleLoop((*bt_global::config)[PI_ADDRESS]);
	compareClientCommand();
	tstart.checkSignals();

	v[VideoDoorEntryDevice::TELE_TIMEOUT] = true;
	cctv->valueReceived(v);
	v.clear();
	ttimeout.checkSignals();

	QVERIFY(!cctv->association_timeout.isActive());
	QCOMPARE(cctv->getAssociatedTeleloopId(), 0);

	v[VideoDoorEntryDevice::TELE_TIMEOUT] = true;
	cctv->valueReceived(v);
	v.clear();
	ttimeout.checkNoSignals();
}

void TestVideoDoorEntry::testCCTVTeleloopTimeouTimer()
{
	ObjectTester tstart(cctv, SIGNAL(teleloopAssociationStarted()));
	ObjectTester ttimeout(cctv, SIGNAL(teleloopAssociationTimeout()));
	DeviceValues v;

	cctv->startTeleloopAssociation();
	QVERIFY(cctv->association_timeout.isActive());
	dev->startTeleLoop((*bt_global::config)[PI_ADDRESS]);
	compareClientCommand();
	tstart.checkSignals();

	cctv->association_timeout.stop(); // simulate timer expiration
	cctv->associationTimeout();
	ttimeout.checkSignals();

	QVERIFY(!cctv->association_timeout.isActive());
	QCOMPARE(cctv->getAssociatedTeleloopId(), 0);

	v[VideoDoorEntryDevice::TELE_TIMEOUT] = true;
	cctv->valueReceived(v);
	v.clear();
	ttimeout.checkNoSignals();
}
