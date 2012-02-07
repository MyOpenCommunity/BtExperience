#include "objectinterface.h"


QVariant ObjectInterface::data(int role) const
{
    switch (role)
    {
    case ObjectIdRole:
        return getObjectId();
    case NameRole:
        return getName();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ObjectInterface::roleNames()
{
    QHash<int, QByteArray> default_names;
    default_names[ObjectIdRole] = "objectId";
    default_names[NameRole] = "name";
    return default_names;
}
