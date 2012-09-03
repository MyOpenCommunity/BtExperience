#ifndef CONTAINER_H
#define CONTAINER_H

#include "iteminterface.h"


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
		\brief Unique identifier for this container instance.

		Can be used as a filter criterium for MediaModel.
	*/
	Q_PROPERTY(int uii READ getUii CONSTANT)

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
		IdSoundDiffusion = 10,
		IdAntintrusion = 11,
		IdSettings = 12,
		IdFloors = 13,
		IdAmbient = 14,
		IdMessages = 15,
		IdRooms = 100,
		IdProfile = 101
	};

	Container(int id, int uii, QString image, QString description);

	int getUii() const;

	void setImage(QString image);
	QString getImage() const;

	void setDescription(QString description);
	QString getDescription() const;

signals:
	void descriptionChanged();
	void imageChanged();

private:
	QString description, image;
	int id, uii;
};

#endif // CONTAINER_H
