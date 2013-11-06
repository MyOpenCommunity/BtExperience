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

#ifndef OBJECTLINK_H
#define OBJECTLINK_H

#include "linkinterface.h"

#include <QPoint>

class ObjectInterface;


/*!
	\ingroup Core
	\brief Link to a MyHome object, for use in a room
*/
class ObjectLink : public LinkInterface
{
	Q_OBJECT

	/*!
		\brief The MyHome object instance
	*/
	Q_PROPERTY(ObjectInterface *btObject READ getBtObject CONSTANT)

	/// Object link description
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)

public:
	ObjectLink(ObjectInterface *obj, int _x, int _y, int container_uii = -1);

	virtual QString getName() const;
	void setName(QString new_value);

	ObjectInterface *getBtObject() const;

private slots:
	void objectNameChanged();

signals:
	void nameChanged(QString address);

private:
	ObjectInterface *bt_object;
};

#endif // OBJECTLINK_H
