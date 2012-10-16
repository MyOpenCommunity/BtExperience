#ifndef ITEMINTERFACE_H
#define ITEMINTERFACE_H

#include <QObject>


/*!
	\ingroup Core
	\brief Base class for items in MediaDataModel and MediaModel
*/
class ItemInterface : public QObject
{
	Q_OBJECT

	/*!
		\brief The id of a container object (defaults to -1), used for filtering
	*/
	Q_PROPERTY(int containerUii READ getContainerUii WRITE setContainerUii NOTIFY containerChanged)

public:
	ItemInterface(QObject *parent = 0);

	virtual void setContainerUii(int uii);
	int getContainerUii() const;

signals:
	void containerChanged();

	/*!
		\brief Emitted when the item must be saved to disk
	*/
	void persistItem();

private:
	int container_uii;
};

#endif // ITEMINTERFACE_H
