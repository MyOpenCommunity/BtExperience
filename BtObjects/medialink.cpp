#include "medialink.h"
#include "xml_functions.h"


void updateMediaNameAddress(QDomNode node, MediaLink *item)
{
	if (!setAttribute(node, "descr", item->getName()))
		qWarning("Attribute descr not found in XML node");
	if (!setAttribute(node, "url", item->getAddress()))
		qWarning("Attribute url not found in XML node");
}

void updateMediaPosition(QDomNode node, MediaLink *item)
{
	if (!setAttribute(node, "x", QString::number(item->getPosition().x())))
		qWarning("Attribute x not found in XML node");
	if (!setAttribute(node, "y", QString::number(item->getPosition().y())))
		qWarning("Attribute y not found in XML node");
}


MediaLink::MediaLink(int container_id, MediaType _type, QString _name, QString _address, QPoint _position)
{
	setContainerId(container_id);
	type = _type;
	name = _name;
	address = _address;
	position = _position;

	connect(this, SIGNAL(nameChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(addressChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(positionChanged(QPointF)), this, SIGNAL(persistItem()));
}

MediaLink::MediaType MediaLink::getType() const
{
	return type;
}

QString MediaLink::getName() const
{
	return name;
}

QString MediaLink::getAddress() const
{
	return address;
}

QPointF MediaLink::getPosition() const
{
	return position;
}

void MediaLink::setName(QString _name)
{
	if (name == _name)
		return;
	name = _name;
	emit nameChanged(name);
}

void MediaLink::setAddress(QString _address)
{
	if (address == _address)
		return;
	address = _address;
	emit addressChanged(address);
}

void MediaLink::setPosition(QPointF _position)
{
	QPoint p = _position.toPoint();
	if (position == p)
		return;
	position = p;
	emit positionChanged(position);
}
