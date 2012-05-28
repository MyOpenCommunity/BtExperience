#include "iteminterface.h"


ItemInterface::ItemInterface(QObject *parent) :
	QObject(parent)
{
	container_id = -1;
}

void ItemInterface::setContainerId(int id)
{
	if (id == container_id)
		return;

	container_id = id;
	emit containerChanged();
}

int ItemInterface::getContainerId() const
{
	return container_id;
}
