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
	Q_PROPERTY(QVariantList range READ getRange WRITE setRange NOTIFY rangeChanged)
	Q_PROPERTY(QVariantList containers READ getContainers WRITE setContainers NOTIFY containersChanged)
	Q_PROPERTY(MediaDataModel* source READ getSource WRITE setSource NOTIFY sourceChanged)
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)

public:
	MediaModel();

	Q_INVOKABLE ItemInterface *getObject(int row);
	Q_INVOKABLE void remove(int index);
	Q_INVOKABLE void clear();

	// The range argument is a QVariantList in order to set them from qml. The real
	// type expected is a couple of int [min, max)
	QVariantList getRange() const;
	void setRange(QVariantList range);

	QVariantList getContainers() const;
	void setContainers(QVariantList containers);

	int getCount() const;

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
