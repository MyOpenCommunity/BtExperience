#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include <QObject>
#include <QString>
#include <QHash>


class ObjectInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)
    Q_ENUMS(ObjectId)
    Q_ENUMS(ObjectCategory)

public:
    virtual ~ObjectInterface() {}

    enum ObjectId
    {
        IdLight = 1,
        IdDimmer = 2,
        IdThermalControlUnit99 = 3,
        IdThermalControlledProbe = 4,
        IdThermalControlUnit4 = 5,
        IdMax // the last value + 1, used to check the ids requested from qml
    };

    enum ObjectCategory
    {
        Lighting = 1,
        ThermalRegulation = 2
    };

    virtual int getObjectId() const = 0;

    // an unique key to identify an object from the others with the same id.
    virtual QString getObjectKey() const = 0;

    // the category (ex: lighting, automation, etc..)
    virtual ObjectCategory getCategory() const = 0;

    // the name of the object
    virtual QString getName() const = 0;

    // the status (if applicable) of the object: on or off.
    // for convenience, we provide an empty (fake) implementation of the (get|set)Status methods
    virtual bool getStatus() const
    {
        return false;
    }

    virtual void setStatus(bool st)
    {
        Q_UNUSED(st)
    }

signals:
    void dataChanged();
};


#endif // OBJECTINTERFACE_H
