#ifndef OBJECTLISTMODEL_H
#define OBJECTLISTMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QVariant>
#include <QString>
#include <QModelIndex>
#include <QList>
#include <QObject>
#include <QHash>
#include <QByteArray>

class ObjectInterface;


class ObjectListModel : public QAbstractListModel
{
	Q_OBJECT
public:
	explicit ObjectListModel(QObject *parent = 0);

	virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;

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

	void appendRow(ObjectInterface *item);

	Q_INVOKABLE QObject *getObject(int row);

	// Objects extracted using a C++ method and pass to a Qml Component have
	// a 'javascript ownership', but in that way the qml has the freedom to
	// delete the object. To avoid that, we set the model as a parent.
	// See http://doc.trolltech.com/4.7/qdeclarativeengine.html#ObjectOwnership-enum
	// for details.
	void reparentObjects();

private slots:
	void handleItemChange();

private:
	QModelIndex indexFromItem(const ObjectInterface *item) const;

	QList<ObjectInterface*> item_list;
	QHash<int, QByteArray> names;
};


class FilterListModel : public QSortFilterProxyModel
{
	Q_OBJECT
	Q_PROPERTY(QVariantList categories READ getCategories WRITE setCategories NOTIFY categoriesChanged)
	Q_PROPERTY(QVariantList filters READ getFilters WRITE setFilters NOTIFY filtersChanged)

public:
	FilterListModel();
	static void setSource(ObjectListModel *model);

	Q_INVOKABLE QObject *getObject(int row);

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

signals:
	void categoriesChanged();
	void filtersChanged();

protected:
	bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
	QVariantList input_categories;
	QVariantList input_filters;

	QList<int> categories;
	QHash<int, QString> filters;
	static ObjectListModel *source;
};


#endif // OBJECTLISTMODEL_H
