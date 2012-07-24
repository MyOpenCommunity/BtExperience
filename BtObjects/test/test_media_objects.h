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

#ifndef TEST_MEDIA_OBJECT_H
#define TEST_MEDIA_OBJECT_H

#include "test_btobject.h"

class SourceBase;
class SourceObject;
class SourceDevice;
class SourceRadio;
class RadioSourceDevice;
class Amplifier;
class AmplifierDevice;
class SoundAmbient;
class PowerAmplifier;
class PowerAmplifierDevice;


class TestSoundAmbient : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testActiveAmplifiers();
	void testActiveSource();

private:
	SourceDevice *srcd1, *srcd2;
	AmplifierDevice *ampd22, *ampd23, *ampd33;

	SoundAmbient *obj2, *obj3;
	SourceBase *src1, *src2;
	SourceObject *srco1, *srco2;
	Amplifier *amp22, *amp23, *amp33;
};


class TestSourceBase : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(SourceDevice *dev, SourceBase *obj, SourceObject *so);

private slots:
	void cleanup();

	void testSetActive();
	void testPreviousTrack();
	void testNextTrack();

	void testReceiveAreaChanged();
	void testReceiveCurrentTrack();

private:
	SourceBase *obj;
	SourceDevice *dev;
	SourceObject *so;
};


class TestSourceAux : public TestSourceBase
{
	Q_OBJECT

private slots:
	void init();
};


class TestSourceRadio : public TestSourceBase
{
	Q_OBJECT

private slots:
	void init();

	void testSetStation();
	void testPreviousStation();
	void testNextStation();

	void testFrequencyUp();
	void testFrequencyDown();

	void testSearchUp();
	void testSearchDown();

	void testReceiveFrequency();
	void testReceiveRds();
	void testReceiveStation();

private:
	SourceRadio *obj;
	SourceObject *so;
	RadioSourceDevice *dev;
};


class TestAmplifier : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(AmplifierDevice *dev, Amplifier *obj);

private slots:
	void init();
	void cleanup();

	void testSetActive();
	void testSetVolume();

	void testReceiveActive();
	void testReceiveVolume();

private:
	Amplifier *obj;
	AmplifierDevice *dev;
};


class TestPowerAmplifier : public TestAmplifier
{
	Q_OBJECT

private slots:
	void init();

	void testBass();
	void testTreble();
	void testBalance();
	void testPreset();
	void testLoud();

	void testReceiveBass();
	void testReceiveTreble();
	void testReceiveBalance();
	void testReceivePreset();
	void testReceiveLoud();

private:
	PowerAmplifier *obj;
	PowerAmplifierDevice *dev;
};

#endif // TEST_MEDIA_OBJECT_H
