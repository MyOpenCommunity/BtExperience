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

signals:
	void nameChanged(QString address);
	void addressChanged(QString address);

private:
	QString name;
	QString address;
};

#endif // MEDIALINK_H
