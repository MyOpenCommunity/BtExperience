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
		Web = 16003, //!< Web link, address is an URL
		Rss = 16002,  //!< RSS link, address is an URL
		Webcam = 16001,  //!< Webcam link, address is an URL
		Camera = 3, //!< Video-surveillance camera link
		BtObject = 4 //!< Generic BtObject link
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
