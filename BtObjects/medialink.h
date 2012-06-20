#ifndef MEDIALINK_H
#define MEDIALINK_H

#include "iteminterface.h"

#include <QPoint>


/*!
	\ingroup Core
	\brief Link to a media source, for display in the user profile or multimedia section

	It can be a link to a web page, an RSS or a video-surveillance camera.
*/
class MediaLink : public ItemInterface
{
	Q_OBJECT

	/// Media link type
	Q_PROPERTY(MediaType type READ getType CONSTANT)

	/// Media link description
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)

	/*!
		\brief Media link address

		For web/RSS links this is the URL of the link, for video-surveillance
		camers it's the SCS where of the camera.
	*/
	Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)

	/*!
		\brief Absolute position for screen display
	*/
	Q_PROPERTY(QPointF position READ getPosition WRITE setPosition NOTIFY positionChanged)

	Q_ENUMS(MediaType)

public:
	/// Media link type
	enum MediaType
	{
		Web = 1, //!< Web link, address is an URL
		Rss,  //!< RSS link, address is an URL
		Camera  //!< Video-surveillance camera link, address is the SCS where of the camera
	};

	MediaLink(int container_id, MediaType type, QString name, QString address, QPoint position);

	MediaType getType() const;
	QString getName() const;
	QString getAddress() const;
	QPointF getPosition() const;

public slots:
	void setName(QString name);
	void setAddress(QString address);
	void setPosition(QPointF position);

signals:
	void nameChanged(QString address);
	void addressChanged(QString address);
	void positionChanged(QPointF position);

private:
	MediaType type;
	QString name;
	QPoint position;
	QString address;
};

#endif // MEDIALINK_H
