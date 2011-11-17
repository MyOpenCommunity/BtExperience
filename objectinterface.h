#ifndef LISTOBJECT_H
#define LISTOBJECT_H

#include <QObject>
#include <QString>
#include <QHash>



// The enum ObjectCategory and the function nameToCategory must keep in sync!
enum ObjectCategory
{
    NONE = 0,
    LIGHTING = 1,
    THERMAL_REGULATION = 2
};

inline ObjectCategory nameToCategory(QString name)
{
    static QHash<QString, ObjectCategory> c;
    if (c.isEmpty())
    {
        c["lighting"] = LIGHTING;
        c["thermalregulation"] = THERMAL_REGULATION;
    }

    if (c.contains(name))
        return c[name];

    return NONE;
}


class ObjectInterface : public QObject
{
    Q_OBJECT
    Q_ENUMS(ObjectId)

public:

    enum ObjectId
    {
        Light = 1,
        Dimmer = 2,
        ThermalControlUnit = 3,
        ThermalControlledProbe = 4
    };

    virtual int getObjectId() const = 0;
    virtual int getCategory() const = 0;
    virtual QString getName() const = 0;
    virtual bool getStatus() const = 0;
    virtual void setStatus(bool st) = 0;

signals:
    void dataChanged();
};


#endif // LISTOBJECT_H
