#ifndef ITEMINTERFACE_H
#define ITEMINTERFACE_H

#include <QObject>


class ItemInterface : public QObject
{
	Q_OBJECT

	Q_PROPERTY(int containerId READ getContainerId NOTIFY containerChanged)

public:
	ItemInterface(QObject *parent = 0);

	void setContainerId(int id);
	int getContainerId() const;

signals:
	void containerChanged();

private:
	int container_id;
};

#endif // ITEMINTERFACE_H
