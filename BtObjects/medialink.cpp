#include "medialink.h"


MediaLink::MediaLink(int container_id, MediaType _type, QString _name, QString _address, QPoint _position)
{
	setContainerId(container_id);
	type = _type;
	name = _name;
	address = _address;
	position = _position;
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
