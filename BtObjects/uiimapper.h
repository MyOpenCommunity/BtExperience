#ifndef UIIMAPPER_H
#define UIIMAPPER_H

#include <QObject>
#include <QHash>


class UiiMapper : public QObject
{
	Q_OBJECT

public:
	void insert(int uii, QObject *value);

	void remove(QObject *value);

	template<class V>
	V *value(int uii) const
	{
		return qobject_cast<V *>(value(uii));
	}

	QObject *value(int uii) const
	{
		return items.value(uii);
	}

private slots:
	void elementDestroyed(QObject *obj);

private:
	QHash<int, QObject *> items;
};

#endif // UIIMAPPER_H
