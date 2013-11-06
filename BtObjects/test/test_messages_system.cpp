/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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

#include "test_messages_system.h"
#include "messagessystem.h"
#include "../../../libqtdevices/message_device.h"
#include "objecttester.h"

#include <QtTest/QtTest>

void TestMessagesSystem::init()
{
	MessageDevice *d = new MessageDevice;

	MessagesSystem::cleanupMessagesFile();

	obj = new MessagesSystem(d);
	dev = new MessageDevice(1);
}

void TestMessagesSystem::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;

	MessagesSystem::cleanupMessagesFile();
}

void TestMessagesSystem::testNewMessage()
{
	QVERIFY(obj->message_list.getCount() == 0);
	Message message;
	message.datetime = QDateTime(QDate(2010, 3, 8), QTime(17, 32));
	message.text = "qualsiasi cosa";

	DeviceValues v;
	v[MessageDevice::DIM_MESSAGE].setValue(message);

	ObjectTester t(obj, SignalList()
				   << SIGNAL(messagesChanged())
				   << SIGNAL(unreadMessagesChanged()));
	obj->valueReceived(v);
	t.checkSignals();

	QCOMPARE(obj->message_list.getCount(), 1);
	MessageItem *it = static_cast<MessageItem *>(obj->message_list.getObject(0));
	QCOMPARE(it->getText(), message.text);
	QCOMPARE(it->getDateTime(), message.datetime);
	QCOMPARE(it->isRead(), false);
	QCOMPARE(it->getSender(), QString());

	QCOMPARE(obj->getUnreadMessages(), 1);

	ObjectTester t2(obj, SIGNAL(unreadMessagesChanged()));
	it->setRead();
	t2.checkSignals();

	QCOMPARE(obj->getUnreadMessages(), 0);
}
