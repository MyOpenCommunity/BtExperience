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
