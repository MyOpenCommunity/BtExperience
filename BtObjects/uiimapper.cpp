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

#include "uiimapper.h"

#include <QDebug>

void UiiMapper::insert(int uii, QObject *value)
{
	if (items.contains(uii))
		qFatal("Duplicate uii %d", uii);

	connect(value, SIGNAL(destroyed(QObject*)),
		this, SLOT(elementDestroyed(QObject*)));

	reserveUii(uii);

	items.insert(uii, value);
}

void UiiMapper::remove(QObject *value)
{
	int uii = findUii(value);
	if (uii == -1)
	{
		qWarning() << "Try to remove an object not in the list:" << value;
		return;
	}

	items.remove(uii);
}

void UiiMapper::reserveUii(int uii)
{
	if (uii >= next_uii)
		next_uii = uii + 1;
}

int UiiMapper::findUii(QObject *value) const
{
	QHashIterator<int, QObject *> iter(items);
	while (iter.hasNext())
	{
		iter.next();
		if (iter.value() == value)
			return iter.key();
	}
	return -1;
}

void UiiMapper::elementDestroyed(QObject *obj)
{
	remove(obj);
}

void UiiMapper::setUiiMapper(UiiMapper *map)
{
	uii_map = map;
}

UiiMapper *UiiMapper::getUiiMapper()
{
	return uii_map;
}

UiiMapper *UiiMapper::uii_map = 0;
