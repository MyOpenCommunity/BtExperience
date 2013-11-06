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

#include "iteminterface.h"
#include "xml_functions.h"


ItemInterface::ItemInterface(QObject *parent) :
	QObject(parent)
{
	container_uii = -1;

	connect(this, SIGNAL(containerChanged()), this, SIGNAL(persistItem()));
}

void ItemInterface::setContainerUii(int id)
{
	if (id == container_uii)
		return;

	container_uii = id;
	emit containerChanged();
}

int ItemInterface::getContainerUii() const
{
	return container_uii;
}
