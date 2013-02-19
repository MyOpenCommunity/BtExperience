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

ObjectModel::ObjectModel(QObject *parent)
	: MediaModel(parent)
{
	Q_ASSERT_X(global_source, "ObjectModel::ObjectModel", "global source model not set!");
	setSource(global_source);
}

void ObjectModel::setSource(ObjectDataModel *s)
{
	Q_ASSERT_X(s, "ObjectModel::setSource", "Can't set NULL model source");
	MediaModel::setSource(s);
}

ObjectDataModel *ObjectModel::getSource() const
{
	return qobject_cast<ObjectDataModel *>(MediaModel::getSource());
}

ItemInterface *ObjectModel::getObject(int row)
{
	ItemInterface *item = MediaModel::getObject(row);
	ObjectInterface *obj = qobject_cast<ObjectInterface *>(item);

	if (!obj)
		return item;
	obj->initializeObject();

	return obj;
}

QVariantList ObjectModel::getFilters() const
{
	return input_filters;
}

void ObjectModel::setFilters(ObjectModelFilters f)
{
	setFilters(f.getFilters());
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
		filters.insertMulti(id, m.contains("objectKey") ? m["objectKey"].toString() : QString());
	}
	reset(); // see comment at the top of MediaModel
	emit filtersChanged();
}

bool ObjectModel::acceptsRow(int source_row) const
{
	bool match_conditions = MediaModel::acceptsRow(source_row);

	if (!match_conditions)
		return false;

	// No filter means all the items
	if (filters.isEmpty())
		return true;

	ObjectInterface *obj = getSource()->getObject(source_row);

	match_conditions = false;

	if (filters.isEmpty()) // no conditions, we keep all the items
		match_conditions = true;
	else if (filters.contains(obj->getObjectId()))
	{
		QList<QString> keys = filters.values(obj->getObjectId());
		foreach (QString key, keys) {
			if (key.isEmpty() || keyMatches(key, obj))
				match_conditions = true;
		}
	}

	return match_conditions;
}

MediaModel *ObjectModel::getUnrangedModel()
{
	// clones this model without range
	ObjectModel *result = new ObjectModel(this);

	// we need to call MediaModel of the getSource and setSource functions
	// because, in general, we cannot assume the model is an ObjectDataModel,
	// but it can be a MediaDataModel, too
	((MediaModel *)result)->setSource(((MediaModel *)this)->getSource());
	result->setContainers(this->getContainers());
	result->setFilters(this->getFilters());

	return result;
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


ObjectModelFilters::ObjectModelFilters()
{
	has_key = false;
}

QVariantList ObjectModelFilters::getFilters() const
{
	Q_ASSERT_X(!has_key, "ObjectModelFilters::getFilters", "Odd number of elements in filter");
	return filters;
}

ObjectModelFilters &ObjectModelFilters::operator <<(QVariant v)
{
	if (has_key)
	{
		has_key = false;
		if (filters.count() == 0)
			filters << QVariantMap();

		QVariantMap last = filters.last().toMap();

		last[key] = v;
		filters.last().setValue(last);
	}
	else
	{
		has_key = true;
		key = v.toString();
	}

	return *this;
}

ObjectModelFilters &ObjectModelFilters::operator <<(ObjectModelFilters f)
{
	Q_UNUSED(f)
	filters.append(QVariant());

	return *this;
}
