#include "medialink.h"
#include "xml_functions.h"


void updateMediaNameAddress(QDomNode node, MediaLink *item)
{
	setAttribute(node, "descr", item->getName());
	setAttribute(node, "url", item->getAddress());
}


MediaLink::MediaLink(int container_id, MediaType type, QString _name, QString _address, QPoint position) :
	LinkInterface(container_id, type, position)
{
	name = _name;
	address = _address;

	connect(this, SIGNAL(nameChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(addressChanged(QString)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(linkUpdateRequest()), this, SIGNAL(persistItem()));
}

QString MediaLink::getName() const
{
	return name;
}

QString MediaLink::getAddress() const
{
	return address;
}

void MediaLink::setName(QString _name)
{
	if (name == _name)
		return;
	name = _name;
	emit nameChanged(name);
}

void MediaLink::setAddress(QString _address)
{
	if (address == _address)
		return;
	address = _address;
	emit addressChanged(address);
}

void MediaLink::update()
{
	emit linkUpdateRequest();
}
