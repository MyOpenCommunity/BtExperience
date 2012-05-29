#include "mediamodel.h"
#include "iteminterface.h"

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
			QObject *it = item_list.takeAt(row);

			it->deleteLater();
		}
		endRemoveRows();
		emit countChanged();
		return true;
	}
	return false;
}

void MediaDataModel::clear()
{
	removeRows(0, item_list.size());
}

void MediaDataModel::insertObject(ItemInterface *obj)
{
	// Objects extracted using a C++ method and passed to a Qml Component have
	// a 'javascript ownership', but in that way the qml has the freedom to
	// delete the object. To avoid that, we set the model as a parent.
	// See http://doc.trolltech.com/4.7/qdeclarativeengine.html#ObjectOwnership-enum
	// for details.
	obj->setParent(this);

	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	item_list.append(obj);
	endInsertRows();
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

void MediaDataModel::remove(int index)
{
	removeRow(index);
}


MediaModel::MediaModel()
{
	min_range = -1;
	max_range = -1;
	counter = -1;
	connect(this, SIGNAL(modelAboutToBeReset()), SLOT(resetCounter()));
}

int MediaModel::getCount() const
{
	if (counter == -1)
		rowCount();
	return counter;
}

int MediaModel::getRangeCount() const
{
	return rowCount();
}

void MediaModel::setSource(MediaDataModel *s)
{
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

	emit rangeChanged();
	reset(); // I'd like to use invalidateFilter(), but it doesn't work
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
	emit containersChanged();
	reset();
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

	return containers.contains(item->getContainerId());
}

bool MediaModel::removeRows(int row, int count, const QModelIndex &parent)
{
	// TODO: probably we need to also map the row?
	if (getSource()->removeRows(row, count, mapToSource(parent)))
	{
		counter -= count;
		return true;
	}
	else
		return false;
}

void MediaModel::resetCounter()
{
	counter = -1;
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
	invalidate();
}

void MediaModel::clear()
{
	if (removeRows(0, counter, QModelIndex()))
		emit countChanged();
}
