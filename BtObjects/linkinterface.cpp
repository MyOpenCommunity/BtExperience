#include "medialink.h"
#include "vct.h"
#include "xml_functions.h"


void updateLinkPosition(QDomNode node, LinkInterface *item)
{
	setAttribute(node, "x", QString::number(item->getPosition().x()));
	setAttribute(node, "y", QString::number(item->getPosition().y()));
}


LinkInterface::LinkInterface(int container_id, MediaType _type, QPoint _position)
{
	setContainerUii(container_id);
	type = _type;
	position = _position;

	connect(this, SIGNAL(positionChanged(QPointF)), this, SIGNAL(persistItem()));
}

LinkInterface::MediaType LinkInterface::getType() const
{
	return type;
}

QPointF LinkInterface::getPosition() const
{
	return position;
}

void LinkInterface::setPosition(QPointF _position)
{
	QPoint p = _position.toPoint();
	if (position == p)
		return;
	position = p;
	emit positionChanged(position);
}
