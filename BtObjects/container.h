#ifndef CONTAINER_H
#define CONTAINER_H

#include "iteminterface.h"

class QDomNode;
class Container;
class ContainerWithCard;


void updateContainerNameImage(QDomNode node, Container *item);
void updateProfileCardImage(QDomNode node, ContainerWithCard *item);


/*!
	\ingroup Core
	\brief A generic container for ItemInterface%s

	The \ref uii property can be used as a filter criterium for MediaModel.
*/
class Container : public ItemInterface
{
	Q_OBJECT

	/*!
		\brief Container description
	*/
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)

	/*!
		\brief Descriptive image
	*/
	Q_PROPERTY(QString image READ getImage WRITE setImage NOTIFY imageChanged)

	/*!
		\brief Image for profile card. Here, it is equal to image, in derived classes may be different
	*/
	Q_PROPERTY(QString cardImage READ getCardImage NOTIFY cardImageChanged)

	/*!
		\brief Image for profile card. This must be used in QML when file may change.
	*/
	Q_PROPERTY(QString cardImageCached READ getCardImageCached NOTIFY cardImageCachedChanged)

	/*!
		\brief Unique identifier for this container instance.

		Can be used as a filter criterium for MediaModel.
	*/
	Q_PROPERTY(int uii READ getUii CONSTANT)

	/*!
		\brief Identifier for this container type.

		Can be used as a filter criterium for MediaModel.
	*/
	Q_PROPERTY(int containerId READ getContainerId CONSTANT)

	Q_ENUMS(ContainerId)

public:
	enum ContainerId
	{
		IdNoContainer = -1234567, // Invalid container, always has 0 elements inside
		IdScenarios = 1,
		IdLights = 2,
		IdAutomation = 3,
		IdAirConditioning = 4,
		IdLoadControl = 5,
		IdSupervision = 6,
		IdEnergyData = 7,
		IdThermalRegulation = 8,
		IdVideoDoorEntry = 9,
		IdSoundDiffusionMulti = 10,
		IdAntintrusion = 11,
		IdSettings = 12,
		IdFloors = 13,
		IdAmbient = 14,
		IdMessages = 15,
		IdSpecialAmbient = 16,
		IdHomepage = 17,
		IdSoundDiffusionMono = 18,
		IdMultimediaRss = 19,
		IdMultimediaRssMeteo = 20,
		IdMultimediaWebRadio = 21,
		IdMultimediaWebCam = 22,
		IdMultimediaDevice = 23,
		IdMultimediaWebLink = 24,
		IdRooms = 100,
		IdProfile = 101
	};

	Container(int id, int uii, QString image, QString description);

	Q_INVOKABLE void setCacheDirty();

	int getUii() const;

	void setImage(QString image);
	QString getImage() const;

	virtual QString getCardImage() const;
	virtual QString getCardImageCached() const;

	void setDescription(QString description);
	QString getDescription() const;

	int getContainerId() const;

signals:
	void descriptionChanged();
	void imageChanged();
	void cardImageChanged();
	void cardImageCachedChanged();

protected:
	QString getCacheId() const;

private:
	QString description, image;
	int id, uii, cache_id;
};


/*!
	\brief Container subclass with separate card image
*/
class ContainerWithCard : public Container
{
	Q_OBJECT

	/*!
		\brief Image for profile card.
	*/
	Q_PROPERTY(QString cardImage READ getCardImage WRITE setCardImage NOTIFY cardImageChanged)

public:
	ContainerWithCard(int id, int uii, QString image, QString card_image, QString description);

	void setCardImage(QString image);
	virtual QString getCardImage() const;
	virtual QString getCardImageCached() const;

signals:
	void cardImageChanged();

private:
	QString card_image;
};

#endif // CONTAINER_H
