#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include <QObject>
#include <QString>
#include <QHash>


class ObjectInterface : public QObject
{
    Q_OBJECT
    Q_ENUMS(ObjectId)
    Q_ENUMS(ObjectCategory)

public:

    enum ObjectId
    {
        IdLight = 1,
        IdDimmer = 2,
        IdThermalControlUnit99 = 3,
        IdThermalControlledProbe = 4,
        IdMax = 5 // the last value + 1, used to check the ids requested from qml
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
    virtual bool getStatus() const = 0;
    virtual void setStatus(bool st) = 0;

signals:
    void dataChanged();
};


#endif // OBJECTINTERFACE_H
