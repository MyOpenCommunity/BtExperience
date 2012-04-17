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
	dev = new VideoDoorEntryDevice("11", "1", 1);
	obj = new CCTV("portone", "12", new VideoDoorEntryDevice("13", "1"));

}

void TestVideoDoorEntry::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}
