#include "objectlistmodel.h"
#include "objectinterface.h"

#include <QDebug>
#include <QStringList>
#include <QTimer>

ObjectListModel *FilterListModel::global_source = 0;


ObjectListModel::ObjectListModel(QObject *parent) : QAbstractListModel(parent)
{
}

int ObjectListModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);
	return item_list.size();
}

bool ObjectListModel::removeRows(int row, int count, const QModelIndex &parent)
{
	if (row >= 0 && row + count <= item_list.size())
	{
		// FIXME: this call incorrectly always deletes the last item in the view
		// instead of the right row, what's wrong?
		beginRemoveRows(parent, row, row + count - 1);
		for (int i = 0; i < count; ++i)
		{
			QObject *it = item_list.takeAt(row);
			it->disconnect();
			it->deleteLater();
		}
		endRemoveRows();
		return true;
	}
	return false;
}

void ObjectListModel::clear()
{
	removeRows(0, item_list.size());
}

ObjectListModel &ObjectListModel::operator<<(ObjectInterface *item)
{
	// Objects extracted using a C++ method and passed to a Qml Component have
	// a 'javascript ownership', but in that way the qml has the freedom to
	// delete the object. To avoid that, we set the model as a parent.
	// See http://doc.trolltech.com/4.7/qdeclarativeengine.html#ObjectOwnership-enum
	// for details.
	item->setParent(this);

	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	connect(item, SIGNAL(dataChanged()), SLOT(handleItemChange()));
	item_list.append(item);
	endInsertRows();
	return *this;
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

void ObjectListModel::remove(int index)
{
	removeRow(index);
}


void FilterListModel::setGlobalSource(ObjectListModel *model)
{
	global_source = model;
}

FilterListModel::FilterListModel()
{
	Q_ASSERT_X(global_source, "FilterListModel::FilterListModel", "global source model not set!");
	local_source = 0;
	setSourceModel(global_source);
	min_range = -1;
	max_range = -1;
	counter = 0;
}

int FilterListModel::getSize() const
{
	return counter;
}

void FilterListModel::setSource(ObjectListModel *s)
{
	if (s == local_source)
		return;

	local_source = s;
	setSourceModel(local_source);
}

ObjectListModel *FilterListModel::getSource() const
{
	return local_source ? local_source : global_source;
}

QVariantList FilterListModel::getCategories() const
{
	return input_categories;
}

void FilterListModel::setCategories(QVariantList cat)
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

QVariantList FilterListModel::getFilters() const
{
	return input_filters;
}

void FilterListModel::setFilters(QVariantList f)
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
			qDebug() << "FilterListModel::setFilters: invalid id requested" << id;
			continue;
		}
		filters[id] = m.contains("objectKey") ? m["objectKey"].toString() : QString();
	}
	emit filtersChanged();
	reset();
}

QVariantList FilterListModel::getRange() const
{
	return QVariantList() << min_range << max_range;
}

void FilterListModel::setRange(QVariantList range)
{
	if (range.length() != 2)
	{
		qDebug() << "FilterListModel::setRange: the range must be a couple of int [min, max)";
		return;
	}

	bool min_ok, max_ok;
	int min = range.at(0).toInt(&min_ok);
	int max = range.at(1).toInt(&max_ok);

	if (!min_ok || !max_ok)
	{
		qDebug() << "FilterListModel::setRange: one of [min, max) is not an integer";
		return;
	}

	if (min_range == min && max_range == max)
		return;

	min_range = min;
	max_range = max;

	emit rangeChanged();
	reset(); // I'd like to use invalidateFilter(), but it doesn't work
}

bool FilterListModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
	// No category or filter or range means all the items
	if (categories.isEmpty() && filters.isEmpty() && min_range == -1 && max_range == -1)
		return true;

	if (source_row == 0) // restart from the beginning
		counter = 0;
	if (source_row == getSource()->getSize() - 1)
		QTimer::singleShot(0, const_cast<FilterListModel *>(this), SIGNAL(sizeChanged()));

	QModelIndex idx = getSource()->index(source_row, 0, source_parent);

	ObjectInterface *obj = getSource()->getObject(idx.row());

	bool match_conditions = false;
	if (categories.isEmpty() && filters.isEmpty()) // no conditions, we keep all the items
		match_conditions = true;
	else if (categories.contains(obj->getCategory()))
		match_conditions = true;
	else if (filters.contains(obj->getObjectId()))
	{
		QString key = filters[obj->getObjectId()];
		if (key.isEmpty() || key == obj->getObjectKey())
			match_conditions = true;
	}

	if (match_conditions)
	{
		bool match_range = counter >= min_range && (counter < max_range || max_range == -1);
		++counter;
		return match_range;
	}

	return false;
}

ObjectInterface *FilterListModel::getObject(int row)
{
	QModelIndex idx = index(row, 0);
	int original_row = mapToSource(idx).row();
	return getSource()->getObject(original_row);
}

void FilterListModel::remove(int index)
{
	removeRow(index);
}
