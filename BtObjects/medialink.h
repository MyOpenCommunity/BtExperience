#ifndef MEDIALINK_H
#define MEDIALINK_H

#include "iteminterface.h"

#include <QPoint>


class MediaLink : public ItemInterface
{
	Q_OBJECT

	Q_PROPERTY(MediaType type READ getType CONSTANT)
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)
	Q_PROPERTY(QPoint position READ getPosition WRITE setPosition NOTIFY positionChanged)

	Q_ENUMS(MediaType)

public:
	enum MediaType
	{
		Web = 1,
		Rss,
		Camera
	};

	MediaLink(int container_id, MediaType type, QString name, QString address, QPoint position);

	MediaType getType() const;
	QString getName() const;
	QString getAddress() const;
	QPoint getPosition() const;

public slots:
	void setName(QString name);
	void setAddress(QString address);
	void setPosition(QPoint position);

signals:
	void nameChanged(QString address);
	void addressChanged(QString address);
	void positionChanged(QPoint position);

private:
	MediaType type;
	QString name;
	QPoint position;
	QString address;
};

#endif // MEDIALINK_H
