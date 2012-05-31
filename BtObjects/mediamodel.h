#ifndef MEDIALISTMODEL_H
#define MEDIALISTMODEL_H

#include <QSortFilterProxyModel>

class ItemInterface;


class MediaDataModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)

public:
	MediaDataModel(QObject *parent = 0);

	// Append an item to the model. The model takes the ownership of the item
	// and reparent it.
	MediaDataModel &operator<<(ItemInterface *item);

	virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
	virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());
	void clear();

	// We cannot use the roles system offered by Qt models because we don't want
	// a double interface for the ObjectInterface objects.
	// In fact, we have to extract single qt objects, using the getObject method,
	// to pass them to their specific components (ex: the Light object must to
	// be passed to the Light.qml component).
	// An object extracted in that way offers a public API formed by properties,
	// public slots, Q_INVOKABLE methods and signals but the same object when
	// used inside the model's delegate exposes an API composed by the roles of
	// the model.
	// So, in order to obtain an unique API, we use the getObject method even
	// inside delegates.
	virtual QVariant data(const QModelIndex &index, int role) const
	{
		Q_UNUSED(index)
		Q_UNUSED(role)
		return QVariant();
	}

	ItemInterface *getObject(int row) const;

	int getCount() const
	{
		return item_list.size();
	}

	void remove(int index);
	void append(ItemInterface *obj);

signals:
	void countChanged();

protected:
	void insertObject(ItemInterface *obj);

private:
	QModelIndex indexFromItem(const ItemInterface *item) const;

	QList<ItemInterface *> item_list;
};


class MediaModel : public QSortFilterProxyModel
{
	Q_OBJECT

	/*!
		\brief Limit returned elements to the specified range

		The range is applied after filtering (can be used for paging through elements).

		Valid ranges are:
		- [-1, -1]: no range set
		- [min, -1]: elements starting from min up to the end of the source model
		- [min, max]: elements from min (inclusive), to max (exclusive)
	*/
	Q_PROPERTY(QVariantList range READ getRange WRITE setRange NOTIFY rangeChanged)

	/*!
		\brief List of containers to select
	*/
	Q_PROPERTY(QVariantList containers READ getContainers WRITE setContainers NOTIFY containersChanged)

	/*!
		\brief Source model
	*/
	Q_PROPERTY(MediaDataModel* source READ getSource WRITE setSource NOTIFY sourceChanged)

	/*!
		\brief The number of filtered rows without taking range into account

		When a range is	not set, this number is equal to \c rangeCount.
	*/
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)

	/*!
		\brief The number of filtered rows taking range into account

		Only elements with indices from 0 to rangeCount can be accessed; when a range is
		not set, this number is equal to \c count.
	*/
	Q_PROPERTY(int rangeCount READ getRangeCount NOTIFY countChanged)

public:
	MediaModel();

	/*!
		\brief Returns the specified item

		Row must be in the range [0 .. rangeCount - 1]
	*/
	Q_INVOKABLE ItemInterface *getObject(int row);

	/*!
		\brief Deletes the specified element in this model from the source model
	*/
	Q_INVOKABLE void remove(int index);

	Q_INVOKABLE void append(ItemInterface *obj);

	/*!
		\brief Deletes all elements in this model from the source model
	*/
	Q_INVOKABLE void clear();

	// The range argument is a QVariantList in order to set them from qml. The real
	// type expected is a couple of int [min, max)
	QVariantList getRange() const;
	void setRange(QVariantList range);

	QVariantList getContainers() const;
	void setContainers(QVariantList containers);

	int getCount() const;
	int getRangeCount() const;

	void setSource(MediaDataModel *s);
	MediaDataModel *getSource() const;

signals:
	void rangeChanged();
	void sourceChanged();
	void countChanged();
	void containersChanged();

protected:
	bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
	bool removeRows(int row, int count, const QModelIndex &parent);

	virtual bool acceptsRow(int source_row) const;

private slots:
	void resetCounter();

private:
	QVariantList containers;
	int min_range, max_range;
	// used for the pagination. We need a mutable because the filterAcceptRow
	// is a const method.
	mutable int counter;
};

#endif // MEDIALISTMODEL_H
