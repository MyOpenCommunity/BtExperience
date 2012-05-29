#include "objectmodel.h"
#include "objectinterface.h"

#include <QDebug>


ObjectDataModel *ObjectModel::global_source = 0;


ObjectDataModel::ObjectDataModel(QObject *parent) : MediaDataModel(parent)
{
}

ObjectDataModel &ObjectDataModel::operator<<(ObjectPair pair)
{
	insertObject(pair.second, pair.first);
	return *this;
}

ObjectDataModel &ObjectDataModel::insertWithoutUii(ObjectInterface *obj)
{
	insertObject(obj, -1);
	return *this;
}

void ObjectDataModel::insertObject(ObjectInterface *obj, int uii)
{
	if (uii != -1)
		uii_mapper.insert(uii, obj);

	MediaDataModel::insertObject(obj);
}

ObjectInterface *ObjectDataModel::getObject(int row) const
{
	return qobject_cast<ObjectInterface *>(MediaDataModel::getObject(row));
}

ObjectInterface *ObjectDataModel::getObjectByUii(int uii) const
{
	return uii_mapper.value<ObjectInterface>(uii);
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

	emit categoriesChanged();
	reset(); // I'd like to use invalidateFilter(), but it doesn't work
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
	emit filtersChanged();
	reset();
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


ObjectDataModel *RoomListModel::global_source = 0;

void RoomListModel::setGlobalSource(ObjectDataModel *source)
{
	global_source = source;
}

RoomListModel::RoomListModel()
{
	Q_ASSERT_X(global_source, "RoomListModel::RoomListModel", "global source model not set!");
	setSourceModel(global_source);
}

int RoomListModel::getCount() const
{
	return rowCount();
}

QString RoomListModel::getRoom() const
{
	return room;
}

void RoomListModel::setRoom(QString room_name)
{
	if (room_name == room)
		return;
	room = room_name;
	reset();
	emit roomChanged();
}

QStringList RoomListModel::rooms()
{
	QSet<QString> set;
	for (int i = 0; i < global_source->getCount(); ++i)
	{
		ObjectInterface *obj = global_source->getObject(i);
		set << obj->getObjectKey();
	}

	return set.toList();
}

ObjectInterface *RoomListModel::getObject(int row)
{
	QModelIndex idx = index(row, 0);
	return global_source->getObject(mapToSource(idx).row());
}

bool RoomListModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
	if (room.isEmpty())
		return true;

	QModelIndex idx = global_source->index(source_row, 0, source_parent);
	ObjectInterface *obj = global_source->getObject(idx.row());
	if (obj->getObjectKey() == room)
		return true;

	return false;
}
