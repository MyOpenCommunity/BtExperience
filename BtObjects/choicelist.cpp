#include "choicelist.h"

#include <QDebug>


void ChoiceList::add(int value)
{
	values.append(value);
	if (choice < 0)
		choice = 0;
}

int ChoiceList::value() const
{
	return values.at(choice);
}

int ChoiceList::value(int def) const
{
	return choice == -1 ? def : value();
}

void ChoiceList::next()
{
	if (++choice >= values.size())
		choice = 0;
}

void ChoiceList::previous()
{
	if (--choice < 0)
		choice = values.size() - 1;
}

QVariantList ChoiceList::getValues() const
{
	QVariantList result;
	foreach (int choice, values) {
		result.append(choice);
	}
	return result;
}

int ChoiceList::size() const
{
	return values.size();
}
