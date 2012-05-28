#ifndef CONTAINER_H
#define CONTAINER_H

#include "iteminterface.h"


class Container : public ItemInterface
{
	Q_OBJECT
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString image READ getImage WRITE setImage NOTIFY imageChanged)
	Q_PROPERTY(int id READ getId CONSTANT)

public:
	Container(int id, QString image, QString description);

	int getId() const;

	void setImage(QString image);
	QString getImage() const;

	void setDescription(QString description);
	QString getDescription() const;

signals:
	void descriptionChanged();
	void imageChanged();

private:
	QString description, image;
	int id;
};

#endif // CONTAINER_H
