#include "objectlistmodel.h"
#include "objectinterface.h"

#include <QDebug>
#include <QStringList>

ObjectListModel *FilterListModel::source = 0;


ObjectListModel::ObjectListModel(QObject *parent) : QAbstractListModel(parent)
{
}

int ObjectListModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);
	return item_list.size();
}

void ObjectListModel::operator <<(ObjectInterface *item)
{
	// Objects extracted using a C++ method and passed to a Qml Component have
	// a 'javascript ownership', but in that way the qml has the freedom to
	// delete the object. To avoid that, we set the model as a parent.
	// See http://doc.trolltech.com/4.7/qdeclarativeengine.html#ObjectOwnership-enum
	// for details.
	item->setParent(this);

	beginInsertRows(QModelIndex(), rowCount(), rowCount() + 1);
	connect(item, SIGNAL(dataChanged()), SLOT(handleItemChange()));
	item_list.append(item);
	endInsertRows();
}

void ObjectListModel::handleItemChange()
{
	ObjectInterface* item = static_cast<ObjectInterface*>(sender());
	QModelIndex index = indexFromItem(item);
	if (index.isValid())
		emit dataChanged(index, index);
}

QModelIndex ObjectListModel::indexFromItem(const ObjectInterface *item) const
{
	for (int row = 0; row < item_list.size(); ++row)
		if (item_list.at(row) == item)
			return index(row);

	return QModelIndex();
}

ObjectInterface *ObjectListModel::getObject(int row) const
{
	if (row < 0 || row >= item_list.size())
		return 0;

	return item_list.at(row);
}


void FilterListModel::setSource(ObjectListModel *model)
{
	source = model;
}

FilterListModel::FilterListModel()
{
	Q_ASSERT_X(source, "FilterListModel::FilterListModel", "source model not set!");
	setSourceModel(source);
}

QVariantList FilterListModel::getCategories() const
{
	return input_categories;
}

void FilterListModel::setCategories(QVariantList cat)
{
	if (cat == input_categories)
		return;

	foreach (const QVariant &v, cat)
		categories << v.toInt();

	emit categoriesChanged();
	reset(); // I'd like to use invalidateFilter(), but it doesn't work
}

QVariantList FilterListModel::getFilters() const
{
	return input_filters;
}

void FilterListModel::setFilters(QVariantList f)
{
	if (f == input_filters)
		return;

	filters.clear();

	foreach (const QVariant &v, f)
	{
		QVariantMap m = v.value<QVariantMap>();
		int id = m["objectId"].toInt();
		if (id > ObjectInterface::IdMax || id <= 0)
		{
			qDebug() << "FilterListModel::setFilters: invalid id requested " << id;
			continue;
		}
		filters[id] = m.contains("objectKey") ? m["objectKey"].toString() : QString();
	}
	emit filtersChanged();
	reset();
}


bool FilterListModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
	// No category or filter means all the items
	if (categories.isEmpty() && filters.isEmpty())
		return true;

	QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);

	ObjectListModel *model = static_cast<ObjectListModel*>(sourceModel());
	ObjectInterface *obj = static_cast<ObjectInterface*>(model->getObject(idx.row()));

	if (categories.contains(obj->getCategory()))
		return true;

	if (filters.contains(obj->getObjectId()))
	{
		if (filters[obj->getObjectId()].isEmpty()) // no check on the key
			return true;

		if (filters[obj->getObjectId()] == obj->getObjectKey())
			return true;
	}

	return false;
}

QObject *FilterListModel::getObject(int row)
{
	QModelIndex idx = index(row, 0);
	int original_row = mapToSource(idx).row();
	return static_cast<ObjectListModel*>(sourceModel())->getObject(original_row);
}

