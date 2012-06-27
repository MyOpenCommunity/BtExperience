#ifndef CHOICELIST_H
#define CHOICELIST_H

#include <QObject>
#include <QList>
#include <QVariantList>


/*!
	\ingroup Core
	\brief Manage a list of possible choices

	In some cases, not all possible values are available to the user, but only
	some of them.
	For example, all fancoil speeds are: auto, min, med, max, silent.
	A specific fancoil may be configured to have only auto, max, silent.
	This class is used to manage only those and not all the possible values.
	The class manages int values because it expects that such values are enums.
*/
class ChoiceList : public QObject
{
	Q_OBJECT

	/*!
		\brief Gets the modes list
	*/
	Q_PROPERTY(QVariantList values READ getValues CONSTANT)

public:
	ChoiceList(QObject *parent = 0) : QObject(parent), choice(-1) {}

	/*!
		\brief Add a new enumeration value to the end of the list.
	*/
	void add(int value);
	int value() const;
	void next();
	void previous();
	QVariantList getValues() const;

private:
	QList<int> values;
	int choice;
};


#endif // CHOICELIST_H
