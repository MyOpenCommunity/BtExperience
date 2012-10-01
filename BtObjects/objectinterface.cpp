#include "objectinterface.h"
#include "xml_functions.h"


void updateObjectName(QDomNode node, ObjectInterface *item)
{
	if (!setAttribute(node, "descr", item->getName()))
		qWarning("Attribute descr not found in XML node");
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

