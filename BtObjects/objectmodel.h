#ifndef OBJECTMODEL_H
#define OBJECTMODEL_H

#include "mediamodel.h"
#include "uiimapper.h"

#include <QSortFilterProxyModel>
#include <QVariant>
#include <QStringList>
#include <QList>
#include <QHash>
#include <QByteArray>

class ObjectInterface;
typedef QPair<int, ObjectInterface *> ObjectPair;


// The model that contains all the objects. Do not use this in Qml, use
// the ObjectModel instead.
class ObjectDataModel : public MediaDataModel
{
	Q_OBJECT

public:
	explicit ObjectDataModel(QObject *parent = 0);

	// Append an item to the model. The model takes the ownership of the item
	// and reparent it.
	ObjectDataModel &operator<<(ObjectPair pair);
	ObjectDataModel &insertWithoutUii(ObjectInterface *obj);

	ObjectInterface *getObject(int row) const;
	// may return 0 if uii doesn't exist
	ObjectInterface *getObjectByUii(int uii) const;

protected:
	void insertObject(ObjectInterface *obj, int uii);

private:
	UiiMapper uii_mapper;
};


// A view around the data contained in a ObjectDataModel. It contains some
// functions to make it easy to use this model from qml
class ObjectModel : public MediaModel
{
	Q_OBJECT
	Q_PROPERTY(QVariantList categories READ getCategories WRITE setCategories NOTIFY categoriesChanged)
	Q_PROPERTY(QVariantList filters READ getFilters WRITE setFilters NOTIFY filtersChanged)

public:
	ObjectModel();
	static void setGlobalSource(ObjectDataModel *model);

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

	void setSource(ObjectDataModel *s);
	ObjectDataModel *getSource() const;

signals:
	void categoriesChanged();
	void filtersChanged();

protected:
	bool acceptsRow(int source_row) const;

private:
	bool keyMatches(QString key, ObjectInterface *obj) const;

	QVariantList input_categories;
	QVariantList input_filters;

	QList<int> categories;
	QHash<int, QString> filters;
	static ObjectDataModel *global_source;
};


class RoomListModel : public QSortFilterProxyModel
{
	Q_OBJECT
	Q_PROPERTY(int size READ getSize NOTIFY sizeChanged)
	Q_PROPERTY(QString room READ getRoom WRITE setRoom NOTIFY roomChanged)

public:
	RoomListModel();
	static void setGlobalSource(ObjectDataModel *source);

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
	static ObjectDataModel *global_source;
	QString room;
};


#endif // OBJECTMODEL_H
