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

private slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void updateUnreadMessagesIfChanged();
	void saveMessages();

private:
	void loadMessages();

	MessageDevice *dev;
	MediaDataModel message_list;
	int unread_messages;
};

#endif // MESSAGESOBJECTS_H
