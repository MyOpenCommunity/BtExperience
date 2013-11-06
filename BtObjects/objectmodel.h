/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
class ObjectModelFilters;
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
	ObjectDataModel &operator<<(ObjectInterface *obj);

	ObjectInterface *getObject(int row) const;
};


/*!
	\ingroup Core
	\brief Provides a view over a model containing ObjectInterface instances

	This model implements three filter criteria in addition to the ones in MediaModel:
	- objectId
	- object key

	for example:

	\verbatim
	ObjectModel {
	     id: thermal
	     source: myHomeModels.myHomeObjects
	     filters: [
		 {objectId:  ObjectInterface.IdThermalControlledProbe,
		  objectKey: "1"},
		 {objectId:  ObjectInterface.IdThermalControlledProbeFancoil}
	     ]
	}
	\endverbatim

	selects all the objects with:
	- objectId ObjectInterface::IdThermalControlledProbe and key "1" or
	- objectId ObjectInterface::IdThermalControlledProbeFancoil

	\sa ObjectInterface::ObjectId
*/
class ObjectModel : public MediaModel
{
	Q_OBJECT

	/*!
		\brief A list of filter criteria

		Each item is a dictionary with keys:
		- objectId (ObjectInterface::ObjectId, required)
		- objectKey (comma-separated string, optional)

		The object is selected if its \ref ObjectInterface::objectId matches and each susbstring in the
		key is contained in the \ref ObjectInterface::objectKey

		An empty list matches all objects.
	*/
	Q_PROPERTY(QVariantList filters READ getFilters WRITE setFilters NOTIFY filtersChanged)

public:
	ObjectModel(QObject * parent = 0);
	static void setGlobalSource(ObjectDataModel *model);

	// The filters argument is a QVariantList in order to set them from qml. The real
	// type expected is a list of javascript objects represented with a map that
	// has an element with the objectId and objectKey keys (the latter can be omitted
	// to get all the items with a certain objectId).
	QVariantList getFilters() const;
	void setFilters(QVariantList f);

	// helper method for C++
	void setFilters(ObjectModelFilters f);

	void setSource(ObjectDataModel *s);
	ObjectDataModel *getSource() const;

	virtual ItemInterface *getObject(int row);

signals:
	void filtersChanged();

protected:
	bool acceptsRow(int source_row) const;
	virtual MediaModel *getUnrangedModel();

private:
	bool keyMatches(QString key, ObjectInterface *obj) const;

	QVariantList input_filters;

	QHash<int, QString> filters;
	static ObjectDataModel *global_source;
};


/*!
	\ingroup Core
	\brief Create a data model instance from QML

	Can be used when applying a filter to an existing model is not enough, for example:

	\verbatim
	ObjectModelSource {
	    id: customModel
	}

	Component.onCompleted: {
	    // contrived example
	    for (var i = 0; i < amplifierModel.count; ++i)
		if (i % 2 == 0)
		    customModel.append(amplifierModel.getObject(i))
	}

	ObjectModel {
	    id: filterModel
	    filters: [
		// ...
	    ]
	    range: // ...
	    source: customModel.model
	}
	\endverbatim
*/
class ObjectModelSource : public QObject
{
	Q_OBJECT

	/// Retrieve the associated model instance
	Q_PROPERTY(ObjectDataModel *model READ getModel CONSTANT)

public:
	ObjectModelSource(QObject *parent = 0) : QObject(parent)
	{
		model = new ObjectDataModel(this);
	}

	ObjectDataModel *getModel() const { return model; }

	/// Append an object to the model
	Q_INVOKABLE void append(ItemInterface *obj) { model->append(obj); }

	/// Append an empty object to the model
	Q_INVOKABLE void appendEmpty();

	/// Remove all objects from the model
	Q_INVOKABLE void clear() { model->clear(); }

	/// inits the model from a QStringList
	Q_INVOKABLE void init(QStringList source);

private:
	ObjectDataModel *model;
};

/*!
	\ingroup Core
	\brief Helper class to simplify filter creation from C++

	for example:

	\verbatim
	ObjectListModel thermal;

	thermal.setFilter(ObjectModelFilters() << "objectId" << ObjectInterface.IdThermalControlledProbe
					       << "objectKey" << "1"
		       << ObjectModelFilters() << "objectId" << ObjectInterface.IdThermalControlledProbeFancoil);
	\endverbatim

	Is equivalent to the following QML code

	\verbatim
	ObjectModel {
	     id: thermal
	     source: myHomeModels.myHomeObjects
	     filters: [
		 {objectId:  ObjectInterface.IdThermalControlledProbe,
		  objectKey: "1"},
		 {objectId:  ObjectInterface.IdThermalControlledProbeFancoil}
	     ]
	}
	\endverbatim

	\sa ObjectListModel
*/
class ObjectModelFilters
{
public:
	ObjectModelFilters();

	QVariantList getFilters() const;

	ObjectModelFilters &operator <<(QVariant v);

	ObjectModelFilters &operator <<(const char *v)
	{
		return operator <<(QString(v));
	}

	ObjectModelFilters &operator <<(ObjectModelFilters f);

private:
	QVariantList filters;
	QString key;
	bool has_key;
};

#endif // OBJECTMODEL_H
