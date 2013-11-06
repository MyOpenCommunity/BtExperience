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

#ifndef LINKINTERFACE_H
#define LINKINTERFACE_H

#include "iteminterface.h"

#include <QPoint>

class QDomNode;
class LinkInterface;


void updateLinkPosition(QDomNode node, LinkInterface *item);


/*!
	\ingroup Core
	\brief Link to a media source, for display in the user profile or multimedia section

	It can be a link to a web page, an RSS or a video-surveillance camera.
*/
class LinkInterface : public ItemInterface
{
	Q_OBJECT

	/// Media link type
	Q_PROPERTY(MediaType type READ getType CONSTANT)

	/// Media link description
	Q_PROPERTY(QString name READ getName NOTIFY nameChanged)

	/*!
		\brief Absolute position for screen display
	*/
	Q_PROPERTY(QPointF position READ getPosition WRITE setPosition NOTIFY positionChanged)

	Q_ENUMS(MediaType)

public:
	/// Media link type
	enum MediaType
	{
		Web = 16004, //!< Web link, address is an URL
		RssMeteo = 16003, //!< RSS link, address is an URL
		Rss = 16002,  //!< RSS link, address is an URL
		Webcam = 16001,  //!< Webcam link, address is an URL
		WebRadio = 16000, //!< Web radio link, address is an URL
		Browser = 16005, //!< Launch web browser, address is an URL
		Camera = 3, //!< Video-surveillance camera link
		BtObject = 4, //!< Generic BtObject link
		Scenario = 5 //!< Scenario link
	};

	LinkInterface(int container_uii, MediaType type, QPoint position);

	MediaType getType() const;
	QPointF getPosition() const;

	virtual QString getName() const = 0;

public slots:
	void setPosition(QPointF position);

signals:
	void nameChanged(QString address);
	void positionChanged(QPointF position);

private:
	MediaType type;
	QPoint position;
};

#endif // LINKINTERFACE_H
