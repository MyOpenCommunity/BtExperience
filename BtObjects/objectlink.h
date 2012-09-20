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

public:
	ObjectLink(ObjectInterface *obj, MediaType type, int _x, int _y);

	virtual QString getName() const;

	ObjectInterface *getBtObject() const;

private slots:
	void objectNameChanged();

private:
	ObjectInterface *bt_object;
};

#endif // OBJECTLINK_H
