#include "messagessystem.h"
#include "devices_cache.h"
#include "xml_functions.h"

#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QXmlStreamWriter>
#include <QDebug>

#if defined(BT_HARDWARE_X11)
#define MESSAGES_FILENAME "messages.xml"
#else
#define MESSAGES_FILENAME "/home/bticino/cfg/extra/4/messages.xml"
#endif

#define DATE_FORMAT_AS_STRING "yyyy/MM/dd HH:mm"
#define MESSAGES_MAX 10


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

MessagesSystem::MessagesSystem(MessageDevice *d) :
	message_list(this)
{
	dev = d;
	unreadMessages = 0;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
	connect(&message_list, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SLOT(updateUnreadMessagesIfChanged()));

	loadMessages();
}

void MessagesSystem::valueReceived(const DeviceValues &values_list)
{
	// TODO: play ringtone and set audio state machine

	Q_ASSERT_X(values_list[MessageDevice::DIM_MESSAGE].canConvert<Message>(), "MessagesListPage::newMessage", "conversion error");
	Message message = values_list[MessageDevice::DIM_MESSAGE].value<Message>();

	// TODO add isRead and sender info!
	MessageItem *newMessage = new MessageItem(message.text, message.datetime);
	connect(newMessage, SIGNAL(readChanged()), SLOT(updateUnreadMessagesIfChanged()));
	connect(newMessage, SIGNAL(readChanged()), SLOT(saveMessages()));
	message_list << newMessage;

	// limits number of messages to MAX
	int n = message_list.getCount();
	while (n > MESSAGES_MAX)
	{
		// TODO: popup pages in GUI must be closed if a message is removed this way.
		MessageItem *message = static_cast<MessageItem *>(message_list.getObject(n - 1));
		message_list.remove(message);
		delete message;
		--n;
	}

	emit messagesChanged();

	updateUnreadMessagesIfChanged();

	saveMessages();
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

void MessagesSystem::loadMessages()
{
	if (!QFile::exists(MESSAGES_FILENAME))
		return;

	QDomDocument qdom_messages;
	QFile fh(MESSAGES_FILENAME);
	if (!qdom_messages.setContent(&fh))
	{
		qWarning() << "Unable to read messages file:" << MESSAGES_FILENAME;
		return;
	}

	QDomNode root = qdom_messages.documentElement();

	foreach (const QDomNode &item, getChildren(root, "item"))
	{
		QDateTime date = QDateTime::fromString(getTextChild(item, "date"), DATE_FORMAT_AS_STRING);
		QString text = getTextChild(item, "text");
		QString sender = getTextChild(item, "sender");
		bool read = getTextChild(item, "read").toInt();

		MessageItem *newMessage = new MessageItem(text, date, read, sender);
		connect(newMessage, SIGNAL(readChanged()), SLOT(updateUnreadMessagesIfChanged()));
		connect(newMessage, SIGNAL(readChanged()), SLOT(saveMessages()));
		message_list << newMessage;
	}

	emit messagesChanged();
	emit unreadMessagesChanged();
}

void MessagesSystem::saveMessages()
{
	QString dirname = QFileInfo(MESSAGES_FILENAME).absolutePath();
	if (!QDir(dirname).exists() && !QDir().mkpath(dirname))
	{
		qWarning() << "Unable to create the directory" << dirname << "for scs messages";
		return;
	}

	QString tmp_filename = QString(MESSAGES_FILENAME) + ".new";
	QFile f(tmp_filename);
	if (!f.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		qWarning() << "Unable to save scs messages (open failed)";
		return;
	}
	QXmlStreamWriter writer(&f);
	writer.setAutoFormatting(true);
	writer.writeStartDocument();
	writer.writeStartElement("message");

	for (int i = 0; i < message_list.getCount(); ++i)
	{
		ItemInterface *item = message_list.getObject(i);
		MessageItem *message = qobject_cast<MessageItem *>(item);
		writer.writeStartElement("item");
		writer.writeTextElement("date", message->getDateTime().toString(DATE_FORMAT_AS_STRING));
		writer.writeTextElement("text", message->getText());
		writer.writeTextElement("sender", message->getSender());
		writer.writeTextElement("read", QString::number(message->isRead()));
		writer.writeEndElement();
	}
	writer.writeEndElement();
	writer.writeEndDocument();

	if (::rename(qPrintable(tmp_filename), MESSAGES_FILENAME))
		qWarning() << "Unable to save scs messages (rename failed)";
}

MediaDataModel *MessagesSystem::getMessages() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<MediaDataModel *>(&message_list);
}
