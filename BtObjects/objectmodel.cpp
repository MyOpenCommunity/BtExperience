#include "objectmodel.h"
#include "objectinterface.h"

#include <QDebug>


ObjectDataModel *ObjectModel::global_source = 0;


ObjectDataModel::ObjectDataModel(QObject *parent) : MediaDataModel(parent)
{
}

ObjectDataModel &ObjectDataModel::operator<<(ObjectInterface *obj)
{
	insertObject(obj);
	return *this;
}

ObjectInterface *ObjectDataModel::getObject(int row) const
{
	return static_cast<ObjectInterface *>(MediaDataModel::getObject(row));
}


void ObjectModel::setGlobalSource(ObjectDataModel *model)
{
	global_source = model;
}

ObjectModel::ObjectModel()
{
	Q_ASSERT_X(global_source, "ObjectModel::ObjectModel", "global source model not set!");
	setSource(global_source);
}

void ObjectModel::setSource(ObjectDataModel *s)
{
	MediaModel::setSource(s);
}

ObjectDataModel *ObjectModel::getSource() const
{

	return qobject_cast<ObjectDataModel *>(MediaModel::getSource());
}

QVariantList ObjectModel::getCategories() const
{
	return input_categories;
}

void ObjectModel::setCategories(QVariantList cat)
{
	if (cat == input_categories)
		return;

	input_categories = cat;
	categories.clear();

	foreach (const QVariant &v, cat)
		categories << v.toInt();

	reset(); // see comment at the top of MediaModel
	emit categoriesChanged();
}

QVariantList ObjectModel::getFilters() const
{
	return input_filters;
}

void ObjectModel::setFilters(QVariantList f)
{
	if (f == input_filters)
		return;

	input_filters = f;
	filters.clear();

	foreach (const QVariant &v, f)
	{
		QVariantMap m = v.value<QVariantMap>();
		int id = m["objectId"].toInt();
		if (id > ObjectInterface::IdMax || id <= 0)
		{
			qDebug() << "ObjectModel::setFilters: invalid id requested" << id;
			continue;
		}
		filters[id] = m.contains("objectKey") ? m["objectKey"].toString() : QString();
	}
	reset(); // see comment at the top of MediaModel
	emit filtersChanged();
}

bool ObjectModel::acceptsRow(int source_row) const
{
	bool match_conditions = MediaModel::acceptsRow(source_row);

	if (!match_conditions)
		return false;

	// No category or filter means all the items
	if (categories.isEmpty() && filters.isEmpty())
		return true;

	ObjectInterface *obj = getSource()->getObject(source_row);

	match_conditions = false;

	if (categories.isEmpty() && filters.isEmpty()) // no conditions, we keep all the items
		match_conditions = true;
	else if (categories.contains(obj->getCategory()))
		match_conditions = true;
	else if (filters.contains(obj->getObjectId()))
	{
		QString key = filters[obj->getObjectId()];
		if (key.isEmpty() || keyMatches(key, obj))
			match_conditions = true;
	}

	return match_conditions;
}

bool ObjectModel::keyMatches(QString key, ObjectInterface *obj) const
{
	QStringList keyList = key.split(",");
	QStringList objList = obj->getObjectKey().split(",");
	foreach (QString k, keyList)
		if (!objList.contains(k))
			return false;
	return true;
}
