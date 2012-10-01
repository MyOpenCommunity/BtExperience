#include "iteminterface.h"
#include "xml_functions.h"


ItemInterface::ItemInterface(QObject *parent) :
	QObject(parent)
{
	container_uii = -1;
}

void ItemInterface::setContainerUii(int id)
{
	if (id == container_uii)
		return;

	container_uii = id;
	emit containerChanged();
}

int ItemInterface::getContainerUii() const
{
	return container_uii;
}
