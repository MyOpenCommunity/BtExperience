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
