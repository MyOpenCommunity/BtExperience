#include "objectinterface.h"
#include "xml_functions.h"

#include "device.h"


void updateObjectName(QDomNode node, ObjectInterface *item)
{
	setAttribute(node, "descr", item->getName());
}


ObjectInterface::ObjectInterface(QObject *parent) : ItemInterface(parent)
{
	connect(this, SIGNAL(nameChanged()), this, SIGNAL(persistItem()));
}

int ObjectInterface::getObjectId() const
{
	return -1;
}

QString ObjectInterface::getObjectKey() const
{
	return QString();
}

QString ObjectInterface::getName() const
{
	return name;
}

void ObjectInterface::setName(const QString &n)
{
	if (n == name)
		return;

	name = n;
	emit nameChanged();
}

void ObjectInterface::setContainerUii(int uii)
{
	ItemInterface::setContainerUii(uii);

	if (uii != -1)
		enableObject();
}


DeviceObjectInterface::DeviceObjectInterface(device *_dev, QObject *parent) :
	ObjectInterface(parent)
{
	dev = _dev;

	if (dev)
		dev->setSupportedInitMode(device::DISABLED_INIT);
}

void DeviceObjectInterface::enableObject()
{
	if (!dev || dev->getSupportedInitMode() == device::NORMAL_INIT)
		return;

	dev->setSupportedInitMode(device::DEFERRED_INIT);
}

void DeviceObjectInterface::initializeObject()
{
	if (dev)
		dev->smartInit(device::DEFERRED_INIT);
}
