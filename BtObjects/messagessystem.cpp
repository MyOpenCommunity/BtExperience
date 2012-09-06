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
	// TODO: load messages
}

void MessagesSystem::valueReceived(const DeviceValues &values_list)
{
	// TODO: play ringtone and set audio state machine

	Q_ASSERT_X(values_list[MessageDevice::DIM_MESSAGE].canConvert<Message>(), "MessagesListPage::newMessage", "conversion error");
	Message message = values_list[MessageDevice::DIM_MESSAGE].value<Message>();

	// TODO: limit message number to MESSAGES_MAX
	// TODO: popup pages in GUI must be closed if a message is removed this way.

	message_list << new MessageItem(message.text, message.datetime);
	emit messagesChanged();
	// TODO: save messages
}

MediaDataModel *MessagesSystem::getMessages() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<MediaDataModel *>(&message_list);
}
