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

enum ItemRoles
{
    ObjectIdRole = Qt::UserRole + 1,
    CategoryRole,
    NameRole,
    StatusRole
};


class ObjectListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ObjectListModel(QObject *parent = 0);

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    void appendRow(ObjectInterface *item);

    // Models in qml are not directly editable. Return a QObject and modify it
    // is a workaround.
    // https://bugreports.qt.nokia.com//browse/QTBUG-7932
    Q_INVOKABLE QObject *getObject(int row);

private slots:
    void handleItemChange();

private:
    QModelIndex indexFromItem(const ObjectInterface *item) const;

    QList<ObjectInterface*> item_list;
};


class CustomListModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString categories READ getCategories WRITE setCategories NOTIFY categoriesChanged)

public:
    CustomListModel();
    static void setSource(ObjectListModel *model);

    Q_INVOKABLE QObject *getObject(int row);

    QString getCategories() const;
    void setCategories(QString cat);

signals:
    void categoriesChanged();
    void sourceChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
    QString categories;
    QList<int> category_types;
    static ObjectListModel *source;
};


#endif // OBJECTLISTMODEL_H
