#include "objectlistmodel.h"
#include "objectinterface.h"

#include <QDebug>
#include <QStringList>


ObjectListModel::ObjectListModel(QObject *parent) : QAbstractListModel(parent)
{
    QHash<int, QByteArray> names;
    names[ObjectIdRole] = "objectId";
    names[NameRole] = "name";
    names[StatusRole] = "status";
    names[CategoryRole] = "category";

    setRoleNames(names);
}

int ObjectListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return item_list.size();
}

QVariant ObjectListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= item_list.size())
        return QVariant();

    ObjectInterface *item = item_list.at(index.row());
    switch (role)
    {
    case ObjectIdRole:
        return item->getObjectId();
    case NameRole:
        return item->getName();
    case StatusRole:
        return item->getStatus();
    case CategoryRole:
        return item->getCategory();
    default:
        return QVariant();
    }
}

void ObjectListModel::appendRow(ObjectInterface *item)
{
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

QObject *ObjectListModel::getObject(int row)
{
    if (row < 0 || row >= item_list.size())
        return 0;

     return item_list.at(row);
}


CustomListModel::CustomListModel()
{
}

QString CustomListModel::getCategories() const
{
    return categories;
}

void CustomListModel::setCategories(QString cat)
{
    qDebug() << "CustomListModel::setCategory" << cat;
    if (cat == categories)
        return;

    foreach (const QString &name, cat.split(','))
    {
        ObjectCategory c = nameToCategory(name.trimmed());
        if (c == NONE)
        {
            qWarning() << "Unknown category:" <<  name.trimmed();
            continue;
        }

        category_types << c;
    }
    emit categoriesChanged();
}

bool CustomListModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);

    int category = sourceModel()->data(idx, CategoryRole).toInt();
    return category_types.contains(category) || category_types.isEmpty();
}

void CustomListModel::setSource(QObject *model)
{
    setSourceModel(static_cast<ObjectListModel*>(model));
}

QObject *CustomListModel::getObject(int row)
{
    QModelIndex idx = index(row, 0);
    int original_row = mapToSource(idx).row();
    return static_cast<ObjectListModel*>(sourceModel())->getObject(original_row);
}

