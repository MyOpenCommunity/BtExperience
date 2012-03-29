#ifndef GUI_H
#define GUI_H

#include "objectinterface.h"

#include <QObject>


/*!
	\ingroup Settings
	\brief Manages GUI settings for application

	Class to provide services to read and write settings indepent from hardware.

	The object id is \a ObjectInterface::IdGui.
*/
class GuiSettings : public ObjectInterface
{
	friend class TestGuiSettings;

	Q_OBJECT

public:

	virtual int getObjectId() const
	{
		return ObjectInterface::IdGuiSettings;
	}

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Settings;
	}

	virtual QString getName() const { return QString(); }

};

#endif // GUI_H
