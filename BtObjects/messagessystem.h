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

#ifndef MESSAGESOBJECTS_H
#define MESSAGESOBJECTS_H

#include "objectinterface.h"
#include "mediamodel.h"
#include "message_device.h"

#include <QDateTime>
#include <QDomNode>

class MessageDevice;

ObjectInterface *createMessageObject();

class MessageItem : public ItemInterface
{
	Q_OBJECT

	Q_PROPERTY(QDateTime dateTime READ getDateTime CONSTANT)

	Q_PROPERTY(QString text READ getText CONSTANT)

	Q_PROPERTY(QString sender READ getSender CONSTANT)

	Q_PROPERTY(bool isRead READ isRead WRITE setRead NOTIFY readChanged)

public:
	MessageItem(QString _text, QDateTime date, bool _is_read = false, QString _sender = QString());

	QDateTime getDateTime() const;

	QString getText() const;
	QString getSender() const { return sender; }

	bool isRead() const;
	void setRead(bool read = true);

signals:
	void readChanged();

private:
	QDateTime date_time;
	QString text, sender;
	bool is_read;
};

class MessagesSystem : public ObjectInterface
{
	friend class TestMessagesSystem;
	Q_OBJECT

	Q_PROPERTY(int unreadMessages READ getUnreadMessages NOTIFY unreadMessagesChanged)

	Q_PROPERTY(MediaDataModel *messages READ getMessages NOTIFY messagesChanged)

public:
	MessagesSystem(MessageDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMessages;
	}

	MediaDataModel *getMessages() const;
	int getUnreadMessages() const { return unread_messages; }

signals:
	void messagesChanged();
	void unreadMessagesChanged();
	void newUnreadMessages();

private slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void updateUnreadMessagesIfChanged();
	void saveMessages();

private:
	void loadMessages();
	static void cleanupMessagesFile();

	MessageDevice *dev;
	MediaDataModel message_list;
	int unread_messages;
};

#endif // MESSAGESOBJECTS_H
