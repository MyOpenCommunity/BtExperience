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
#include "xml_functions.h"


void updateMediaNameAddress(QDomNode node, MediaLink *item)
{
	setAttribute(node, "descr", item->getName());
	setAttribute(node, "url", item->getAddress());
}


MediaLink::MediaLink(int container_id, MediaType type, QString _name, QString _address, QPoint position) :
	LinkInterface(container_id, type, position)
{
	name = _name;
	address = _address;

	connect(this, SIGNAL(nameChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(addressChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(linkUpdateRequest()), this, SIGNAL(persistItem()));
}

QString MediaLink::getName() const
{
	return name;
}

QString MediaLink::getAddress() const
{
	return address;
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

void MediaLink::update()
{
	emit linkUpdateRequest();
}
