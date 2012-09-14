#include "messagessystem.h"
#include "devices_cache.h"

#include <QFile>
#include <QDebug>

#if BT_HARDWARE_X11
#define MESSAGES_FILENAME "messages.xml"
#else
#define MESSAGES_FILENAME "cfg/extra/4/messages.xml"
#endif

ObjectInterface *parseMessageObject(const QDomNode &xml_node)
{
	Q_UNUSED(xml_node);
	return new MessagesSystem(bt_global::add_device_to_cache(new MessageDevice));
}

MessageItem::MessageItem(QString _text, QDateTime date, bool _is_read, QString _sender)
{
	text = _text;
	date_time = date;
	is_read = _is_read;
	sender = _sender;
}

QDateTime MessageItem::getDateTime() const
{
	return date_time;
}

QString MessageItem::getText() const
{
	return text;
}

bool MessageItem::isRead() const
{
	return is_read;
}

void MessageItem::setRead(bool read)
{
	if (is_read == read)
		return;
	is_read = read;
	emit readChanged();
}

MessagesSystem::MessagesSystem(MessageDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
	connect(&message_list, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SLOT(updateUnreadMessagesIfChanged()));
	// TODO: load messages
}

void MessagesSystem::valueReceived(const DeviceValues &values_list)
{
	// TODO: play ringtone and set audio state machine

	Q_ASSERT_X(values_list[MessageDevice::DIM_MESSAGE].canConvert<Message>(), "MessagesListPage::newMessage", "conversion error");
	Message message = values_list[MessageDevice::DIM_MESSAGE].value<Message>();

	// TODO: limit message number to MESSAGES_MAX
	// TODO: popup pages in GUI must be closed if a message is removed this way.

	// TODO add isRead and sender info!
	MessageItem *newMessage = new MessageItem(message.text, message.datetime);
	connect(newMessage, SIGNAL(readChanged()), SLOT(updateUnreadMessagesIfChanged()));
	message_list << newMessage;
	emit messagesChanged();

	updateUnreadMessagesIfChanged();

	// TODO: save messages
}

void MessagesSystem::updateUnreadMessagesIfChanged()
{
	int unreads = 0;
	for (int i = 0; i < message_list.getCount(); ++i)
	{
		MessageItem *pMsg = static_cast<MessageItem *>(message_list.getObject(i));
		if (!pMsg->isRead())
			++unreads;
	}
	if (unreads != unreadMessages)
	{
		unreadMessages = unreads;
		emit unreadMessagesChanged();
	}
}

MediaDataModel *MessagesSystem::getMessages() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<MediaDataModel *>(&message_list);
}
