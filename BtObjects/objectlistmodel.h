#ifndef OBJECTLISTMODEL_H
#define OBJECTLISTMODEL_H

#include <QSortFilterProxyModel>
#include <QVariant>
#include <QStringList>
#include <QList>
#include <QHash>
#include <QByteArray>

class ObjectInterface;

// The model that contains all the objects. Do not use this in Qml, use
// the FilterListModel instead.
class ObjectListModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int size READ getSize NOTIFY sizeChanged)

public:
	explicit ObjectListModel(QObject *parent = 0);

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

	// Append an item to the model. The model takes the ownership of the item
	// and reparent it.
	ObjectListModel &operator<<(ObjectInterface *item);

	ObjectInterface *getObject(int row) const;
	void remove(int index);

	int getSize() const
	{
		return item_list.size();
	}

signals:
	void sizeChanged();

private slots:
	void handleItemChange();

private:
	QModelIndex indexFromItem(const ObjectInterface *item) const;

	QList<ObjectInterface*> item_list;
	QHash<int, QByteArray> names;
};


// A view around the data contained in a ObjectListModel. It contains some
// functions to make it easy to use this model from qml
class FilterListModel : public QSortFilterProxyModel
{
	Q_OBJECT
	Q_PROPERTY(QVariantList categories READ getCategories WRITE setCategories NOTIFY categoriesChanged)
	Q_PROPERTY(QVariantList filters READ getFilters WRITE setFilters NOTIFY filtersChanged)
	Q_PROPERTY(QVariantList range READ getRange WRITE setRange NOTIFY rangeChanged)
	Q_PROPERTY(ObjectListModel* source READ getSource WRITE setSource NOTIFY sourceChanged)
	Q_PROPERTY(int size READ getSize NOTIFY sizeChanged)

public:
	FilterListModel();
	static void setGlobalSource(ObjectListModel *model);

	Q_INVOKABLE ObjectInterface *getObject(int row);
	Q_INVOKABLE void remove(int index);
	Q_INVOKABLE void clear();

	// The categories argument is a QVariantList in order to set them from qml. The real
	// type expected is a list of ObjectInterface::ObjectCategory
	QVariantList getCategories() const;
	void setCategories(QVariantList cat);

	// The filters argument is a QVariantList in order to set them from qml. The real
	// type expected is a list of javascript objects represented with a map that
	// has an element with the objectId and objectKey keys (the latter can be omitted
	// to get all the items with a certain objectId).
	QVariantList getFilters() const;
	void setFilters(QVariantList f);

	// The range argument is a QVariantList in order to set them from qml. The real
	// type expected is a couple of int [min, max)
	QVariantList getRange() const;
	void setRange(QVariantList range);

	int getSize() const;

	void setSource(ObjectListModel *s);
	ObjectListModel *getSource() const;

signals:
	void categoriesChanged();
	void filtersChanged();
	void rangeChanged();
	void sourceChanged();
	void sizeChanged();

protected:
	bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
	bool removeRows(int row, int count, const QModelIndex &parent);

private slots:
	void resetCounter();

private:
	QVariantList input_categories;
	QVariantList input_filters;

	int min_range, max_range;
	// used for the pagination. We need a mutable because the filterAcceptRow
	// is a const method.
	mutable int counter;

	QList<int> categories;
	QHash<int, QString> filters;
	ObjectListModel *local_source;
	static ObjectListModel *global_source;
};


class RoomListModel : public QSortFilterProxyModel
{
	Q_OBJECT
	Q_PROPERTY(int size READ getSize NOTIFY sizeChanged)
	Q_PROPERTY(QString room READ getRoom WRITE setRoom NOTIFY roomChanged)

public:
	RoomListModel();
	static void setGlobalSource(ObjectListModel *source);

	int getSize() const;
	QString getRoom() const;
	void setRoom(QString room_name);
	Q_INVOKABLE QStringList rooms();
	Q_INVOKABLE ObjectInterface *getObject(int row);

signals:
	void sizeChanged();
	void roomChanged();

protected:
	virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
	static ObjectListModel *global_source;
	QString room;
};


#endif // OBJECTLISTMODEL_H
