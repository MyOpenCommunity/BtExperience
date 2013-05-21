#include "mediamodel.h"
#include "iteminterface.h"
#include "container.h"
#include "uiimapper.h"

#include <QTimer>
#include <QtDebug>


MediaDataModel::MediaDataModel(QObject *parent) : QAbstractListModel(parent)
{
}

MediaDataModel &MediaDataModel::operator<<(ItemInterface *item)
{
	insertObject(item);
	return *this;
}

void MediaDataModel::append(ItemInterface *item)
{
	insertObject(item);
}

void MediaDataModel::prepend(ItemInterface *item)
{
	insertObject(item, true);
}

bool MediaDataModel::remove(ItemInterface *obj)
{
	bool ok = removeRows(item_list.indexOf(obj), 1);
	if (!ok)
		qWarning() << "MediaDataModel::remove, there was an error when removing object" << obj;
	return ok;
}

int MediaDataModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);
	return item_list.size();
}

bool MediaDataModel::removeRows(int row, int count, const QModelIndex &parent)
{
	// Ensure that count is at least 1, otherwise we don't have to remove
	// anything
	if (row >= 0 && count > 0 && row + count <= item_list.size())
	{
		beginRemoveRows(parent, row, row + count - 1);
		for (int i = 0; i < count; ++i)
		{
			ItemInterface *it = item_list.takeAt(row);

			if (it->parent() == this)
				it->deleteLater();
		}
		endRemoveRows();
		return true;
	}
	return false;
}

void MediaDataModel::clear()
{
	removeRows(0, item_list.size());
}

void MediaDataModel::insertObject(ItemInterface *obj, bool prepend)
{
	// Objects extracted using a C++ method and passed to a Qml Component have
	// a 'javascript ownership', but in that way the qml has the freedom to
	// delete the object. To avoid that, we set the model as a parent.
	// See http://doc.trolltech.com/4.7/qdeclarativeengine.html#ObjectOwnership-enum
	// for details.
	if (!obj->parent())
		obj->setParent(this);

	connect(obj, SIGNAL(persistItem()), this, SLOT(persistItem()));

	if (prepend)
	{
		beginInsertRows(QModelIndex(), 0, 0);
		item_list.prepend(obj);
		endInsertRows();
	}
	else
	{
		beginInsertRows(QModelIndex(), rowCount(), rowCount());
		item_list.append(obj);
		endInsertRows();
	}
}

void MediaDataModel::persistItem()
{
	emit persistItem(static_cast<ItemInterface *>(sender()));
}

QModelIndex MediaDataModel::indexFromItem(const ItemInterface *item) const
{
	for (int row = 0; row < item_list.size(); ++row)
		if (item_list.at(row) == item)
			return index(row);

	return QModelIndex();
}

ItemInterface *MediaDataModel::getObject(int row) const
{
	if (row < 0 || row >= item_list.size())
		return 0;

	return item_list.at(row);
}


/*
	Summary: always call reset() after changing filters, and do so before emitting the
		 <filter>Changed() signal.

	After each filter change here or in a subclass, we must call reset() on the model
	and not invalidateFilter().

	This happens because QSortFilterProxyModel expects to be able to call filterAcceptsRow()
	in any order, but our implementation requires a linear scan from index 0 to size - 1 in order
	to handle range selection.

	Calling reset() before <filter>Changed() is not a strict requirement, but it makes behaviour
	less surprising for users that want to do something in an on<filter>Changed QML handler.
*/
MediaModel::MediaModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	min_range = -1;
	max_range = -1;
	counter = 0;
	pending_reset = false;
	connect(this, SIGNAL(modelAboutToBeReset()), SLOT(resetCounter()));
}

int MediaModel::getCount()
{
	if (counter == 0)
	{
		rowCount();
		sort(0);
	}
	return counter;
}

int MediaModel::getRangeCount()
{
	int c = rowCount();
	sort(0);
	return c;
}

void MediaModel::setSource(MediaDataModel *s)
{
	Q_ASSERT_X(s, "MediaModel::setSource", "Can't set NULL model source");
	if (sourceModel())
	{
		disconnect(sourceModel(), SIGNAL(rowsRemoved(const QModelIndex &, int, int)));
		disconnect(sourceModel(), SIGNAL(rowsInserted(const QModelIndex &, int, int)));
	}
	connect(s, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), SLOT(waitResetFilter()));
	connect(s, SIGNAL(rowsInserted(const QModelIndex &, int, int)), SLOT(waitResetFilter()));
	setSourceModel(s);
}

MediaDataModel *MediaModel::getSource() const
{
	return qobject_cast<MediaDataModel *>(sourceModel());
}

QVariantList MediaModel::getRange() const
{
	return QVariantList() << min_range << max_range;
}

void MediaModel::setRange(QVariantList range)
{
	if (range.length() != 2)
	{
		qDebug() << "MediaModel::setRange: the range must be a couple of int [min, max)";
		return;
	}

	bool min_ok, max_ok;
	int min = range.at(0).toInt(&min_ok);
	int max = range.at(1).toInt(&max_ok);

	if (!min_ok || !max_ok)
	{
		qDebug() << "MediaModel::setRange: one of [min, max) is not an integer";
		return;
	}

	if (min_range == min && max_range == max)
		return;

	min_range = min;
	max_range = max;

	reset(); // see comment at the top
	emit rangeChanged();
}

QVariantList MediaModel::getContainers() const
{
	return containers;
}

void MediaModel::setContainers(QVariantList _containers)
{
	if (containers == _containers)
		return;

	containers = _containers;
	reset(); // see comment at the top
	emit containersChanged();
}

bool MediaModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
	if (source_row == 0) // restart from the beginning
		counter = 0;
	if (source_row == getSource()->getCount() - 1)
		QTimer::singleShot(0, const_cast<MediaModel *>(this), SIGNAL(countChanged()));

	QModelIndex idx = getSource()->index(source_row, 0, source_parent);

	if (acceptsRow(idx.row()))
	{
		bool in_range = counter >= min_range && (counter < max_range || max_range == -1);

		++counter;

		if (min_range == -1 && max_range == -1)
			return true;

		return in_range;
	}

	return false;
}

bool MediaModel::acceptsRow(int source_row) const
{
	if (containers.isEmpty())
		return true;

	ItemInterface *item = getSource()->getObject(source_row);

	return containers.contains(item->getContainerUii());
}

bool MediaModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
	ItemInterface *left_item = getSource()->getObject(left.row());
	ItemInterface *right_item = getSource()->getObject(right.row());

	int c = left_item->getContainerUii();
	if (c == -1)
		return false;

	Container *container = UiiMapper::getUiiMapper()->value<Container>(c);
	if (!container)
		return false;

	int left_index = -1, right_index = -1;
	QList<int> uiis = container->getItemOrder();
	for (int i = 0; i < uiis.size(); ++i)
	{
		if (UiiMapper::getUiiMapper()->value<ItemInterface>(uiis.at(i)) == left_item)
			left_index = i;
		if (UiiMapper::getUiiMapper()->value<ItemInterface>(uiis.at(i)) == right_item)
			right_index = i;
	}

	return left_index < right_index;
}

void MediaModel::resetCounter()
{
	counter = 0;
}

void MediaModel::resetFilter()
{
	pending_reset = false;
	reset();
	emit countChanged();
}

void MediaModel::waitResetFilter()
{
	// We need to reset the filter when the underlying model has done adding or
	// removing rows. This isn't done automatically because of our implementation
	// of the filter (filterAcceptsRow() must be called in order on each row and
	// this can be done only by resetting the filter).
	//
	// Furthermore, we cannot reset() here because our base class is already
	// reacting to a row change: if we reset() and emit, a new calculation is
	// triggered before the base class has finished doing its things.
	// This instruction lets the base class finish its work before.
	if (pending_reset)
		return;
	pending_reset = true;
	QTimer::singleShot(0, this, SLOT(resetFilter()));
}

ItemInterface *MediaModel::getObject(int row)
{
	QModelIndex idx = index(row, 0);
	int original_row = mapToSource(idx).row();
	return getSource()->getObject(original_row);
}

void MediaModel::remove(int index)
{
	removeRow(index);
}

void MediaModel::remove(QObject *obj)
{
	ItemInterface *item = qobject_cast<ItemInterface *>(obj);
	if (item && getSource()->remove(item)) {
		reset();
		emit countChanged();
	}
}

void MediaModel::clear()
{
	MediaDataModel *source = getSource();

	// we can't call removeRows() on ourselves because this will only remove items that
	// match both filter and range (and we want to ignore the range), and we need to take into
	// account the filter when calling removeRows() on the source
	for (int source_row = source->rowCount() - 1; source_row >= 0; --source_row)
		if (acceptsRow(source_row))
			source->removeRows(source_row, 1, QModelIndex());
}

int MediaModel::getAbsoluteIndexOf(ItemInterface *obj)
{
	MediaModel *unrangedModel = getUnrangedModel();
	for (int i = 0; i < unrangedModel->getCount(); ++i)
		if (unrangedModel->getObject(i) == obj)
			return i;
	return -1;
}

MediaModel *MediaModel::getUnrangedModel()
{
	// clones this model without range
	MediaModel *result = new MediaModel(this);

	result->setSource(this->getSource());
	result->setContainers(this->getContainers());

	return result;
}

void MediaModel::append(ItemInterface *obj)
{
	getSource()->append(obj);
}

void MediaModel::prepend(ItemInterface *obj)
{
	getSource()->prepend(obj);
}
