#ifndef MESSAGESOBJECTS_H
#define MESSAGESOBJECTS_H

#include "objectinterface.h"
#include "mediamodel.h"
#include "message_device.h"

#include <QDateTime>
#include <QDomNode>

class MessageDevice;

ObjectInterface *parseMessageObject(const QDomNode &xml_node);

class MessageItem : public ItemInterface
{
	Q_OBJECT

	Q_PROPERTY(QDateTime dateTime READ getDateTime CONSTANT)

	Q_PROPERTY(QString text READ getText CONSTANT)

	Q_PROPERTY(bool isRead READ isRead WRITE setRead NOTIFY readChanged)

public:
	MessageItem(QString _text, QDateTime date, bool _is_read = false);

	QDateTime getDateTime() const;

	QString getText() const;

	bool isRead() const;
	void setRead(bool read);

signals:
	void readChanged();

private:
	QDateTime date_time;
	QString text;
	bool is_read;
};

class MessagesSystem : public ObjectInterface
{
friend class TestMessagesSystem;
	Q_OBJECT

	Q_PROPERTY(MediaDataModel *messages READ getMessages CONSTANT)

public:
	MessagesSystem(MessageDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMessages;
	}

	MediaDataModel *getMessages() const;

private slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	MessageDevice *dev;
	MediaDataModel message_list;
};

#endif // MESSAGESOBJECTS_H
