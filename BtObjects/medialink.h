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

#ifndef MEDIALINK_H
#define MEDIALINK_H

#include "linkinterface.h"

#include <QPoint>

class QDomNode;
class MediaLink;


void updateMediaNameAddress(QDomNode node, MediaLink *item);


/*!
	\ingroup Core
	\brief Link to a media source, for display in the user profile or multimedia section

	It can be a link to a web page or RSS
*/
class MediaLink : public LinkInterface
{
	Q_OBJECT

	/// Media link description
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)

	/*!
		\brief Media link URL
	*/
	Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)

public:
	MediaLink(int container_uii, MediaType type, QString name, QString address, QPoint position);

	virtual QString getName() const;
	QString getAddress() const;

public slots:
	void setName(QString name);
	void setAddress(QString address);
	void update();

signals:
	void nameChanged(QString address);
	void addressChanged(QString address);
	void linkUpdateRequest();

private:
	QString name;
	QString address;
};

#endif // MEDIALINK_H
