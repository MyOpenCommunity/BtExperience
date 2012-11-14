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
	Q_PROPERTY(QString cardImage READ getCardImage WRITE setCardImage NOTIFY cardImageChanged)

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

	int getUii() const;

	void setImage(QString image);
	QString getImage() const;

	virtual void setCardImage(QString image);
	virtual QString getCardImage() const;

	void setDescription(QString description);
	QString getDescription() const;

	int getContainerId() const;

signals:
	void descriptionChanged();
	void imageChanged();
	void cardImageChanged();

private:
	QString description, image;
	int id, uii;
};


/*!
	\brief Container subclass with separate card image
*/
class ContainerWithCard : public Container
{
	Q_OBJECT

public:
	ContainerWithCard(int id, int uii, QString image, QString card_image, QString description);

	virtual void setCardImage(QString image);
	virtual QString getCardImage() const;

private:
	QString card_image;
};

#endif // CONTAINER_H
