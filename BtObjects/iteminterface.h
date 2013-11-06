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

#ifndef ITEMINTERFACE_H
#define ITEMINTERFACE_H

#include <QObject>


/*!
	\ingroup Core
	\brief Base class for items in MediaDataModel and MediaModel
*/
class ItemInterface : public QObject
{
	Q_OBJECT

	/*!
		\brief The id of a container object (defaults to -1), used for filtering
	*/
	Q_PROPERTY(int containerUii READ getContainerUii WRITE setContainerUii NOTIFY containerChanged)

public:
	ItemInterface(QObject *parent = 0);

	virtual void setContainerUii(int uii);
	int getContainerUii() const;

signals:
	void containerChanged();

	/*!
		\brief Emitted when the item must be saved to disk
	*/
	void persistItem();

private:
	int container_uii;
};

#endif // ITEMINTERFACE_H
