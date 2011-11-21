#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include <QObject>
#include <QString>
#include <QHash>



// The enum ObjectCategory and the function nameToCategory must keep in sync!
enum ObjectCategory
{
    NONE = 0,
    LIGHT_SYSTEM = 1,
    THERMAL_REGULATION_SYSTEM = 2
};

inline ObjectCategory nameToCategory(QString name)
{
    static QHash<QString, ObjectCategory> c;
    if (c.isEmpty())
    {
        c["lighting"] = LIGHT_SYSTEM;
        c["thermalregulation"] = THERMAL_REGULATION_SYSTEM;
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
        IdLight = 1,
        IdDimmer = 2,
        IdThermalControlUnit = 3,
        IdThermalControlledProbe = 4
    };

    virtual int getObjectId() const = 0;
    virtual int getCategory() const = 0;
    virtual QString getName() const = 0;
    virtual bool getStatus() const = 0;
    virtual void setStatus(bool st) = 0;

signals:
    void dataChanged();
};


#endif // OBJECTINTERFACE_H
