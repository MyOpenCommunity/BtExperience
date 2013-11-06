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

#ifndef QML_CACHE_H
#define QML_CACHE_H


#include <QObject>
#include <QSet>
#include <QHash>
#include <QVariant>


/*!
	\brief A class to cache temporary values while user is editing them in QML forms.

	The user must register the original values from the C++ model.

	When the user changes a value in QML, the user calls setQMLValue function to store
	the new actual value (the C++ model don't change).

	A qmlValueChanged signal is emitted and can be used to reflect the new choosen value on the QML interface.

	If reset method is called, all actual (QML) values are reset to their original values.

	If apply method is called, all actual (QML) values are to be set on the C++ model.

	In the former case, the qmlValueChanged signals are emitted.
	In the latter case, the originalValueChanged signals are emitted.

	Follow this procedure to use this class:

	Firstly, declare a pointer to QMLCache.

	\code
	class QMLCache;

	...

	private:
		QMLCache *cache;
	\endcode

	Declare instance variable only if you have to. The QMLCache can either trace C++ model values
	(they are called original values) and QML values.

	Secondly, import qmlcache.h file and create an instance using the object the cache is in as parent.

	\code
	#include "qmlcache.h"

	...

	cache = new QMLCache(this);
	\endcode

	Moreover, define some int constants to trace relevant object state.

	\code
	// constants for QMLCache
	const int QML_ALARM_TYPE = 1;
	const int QML_DESCRIPTION = 2;
	const int QML_DAYS = 3;
	const int QML_HOUR = 4;
	const int QML_MINUTE = 5;
	const int QML_VOLUME = 6;
	\endcode

	Once constants are in place, set C++ model values in the cache (this registers traced values, too).

	\code
	switch(type)
	{
	case 1:
		cache->setOriginalValue(QML_ALARM_TYPE, AlarmClockSoundSystem);
		break;
	default:
		cache->setOriginalValue(QML_ALARM_TYPE, AlarmClockBeep);
		break;
	}
	cache->setOriginalValue(QML_DESCRIPTION, description);
	cache->setOriginalValue(QML_DAYS, days);
	cache->setOriginalValue(QML_HOUR, hour);
	cache->setOriginalValue(QML_MINUTE, minute);
	cache->setOriginalValue(QML_AMPLIFIER, Converter<Amplifier>::asQVariant(0));
	cache->setOriginalValue(QML_VOLUME, 0);
	\endcode

	Keep in mind that some values are parsed and set after the object is constructed. In this case,
	call apply when the object state is fully updated. If you don't do this you will have a fake
	value inside QML cache (in the example above, volume is set to zero: this is hardly right).

	\code
	alarm->setVolume(v.intValue("volume"));

	...

	alarm->apply();
	\endcode

	Then, connect the qmlValueChanged and persistItemRequested signals.

	\code
	connect(cache, SIGNAL(qmlValueChanged(int,QVariant)), this, SLOT(qmlValueChanged(int,QVariant)));
	connect(cache, SIGNAL(persistItemRequested()), this, SLOT(persistItem()));
	\endcode

	Of course, you need to implement the connected slot.

	\code
	void AlarmClock::qmlValueChanged(int key, QVariant value)
	{
		Q_UNUSED(value);

		switch(key)
		{
		case QML_ALARM_TYPE:
			emit alarmTypeChanged();
			break;
		case QML_DESCRIPTION:
			emit descriptionChanged();
			break;
		case QML_DAYS:
			emit daysChanged();
			break;
		case QML_HOUR:
			emit hourChanged();
			break;
		case QML_MINUTE:
			emit minuteChanged();
			break;
		case QML_VOLUME:
			emit volumeChanged();
			break;
		default:
			qWarning() << __PRETTY_FUNCTION__ << "an unknown key (" << key << ") has arrived";
		}
	}
	\endcode

	The next task is to implement reset and apply methods. Remember to use them at proper times
	in QML code.

	\code
	void AlarmClock::reset()
	{
		cache->reset();
	}

	void AlarmClock::apply()
	{
		cache->apply();
	}
	\endcode

	Lastly, implement proper get and set methods.

	\code
	AlarmClock::AlarmClockType AlarmClock::getAlarmType() const
	{
		return static_cast<AlarmClock::AlarmClockType>(cache->getQMLValue(QML_ALARM_TYPE).toInt());
	}

	void AlarmClock::setAlarmType(AlarmClockType new_value)
	{
		if (getAlarmType() != new_value)
			cache->setQMLValue(QML_ALARM_TYPE, new_value);
	}

	int AlarmClock::getDays() const
	{
		return cache->getQMLValue(QML_DAYS).toInt();
	}

	void AlarmClock::setDays(int new_value)
	{
		// checks if new value is in permitted range
		if (new_value < 0 || new_value > 0x7F)
			return;

		if (getDays() != new_value)
			cache->setQMLValue(QML_DAYS, new_value);
	}

	SourceObject *AlarmClock::getSource() const
	{
		return Converter<SourceObject>::asPointer(cache->getQMLValue(QML_SOURCE));
	}

	void AlarmClock::setSource(SourceObject *new_value)
	{
		if (getSource() != new_value)
			cache->setQMLValue(QML_SOURCE, Converter<SourceObject>::asQVariant(new_value));
	}
	\endcode

	Now you are ready to code the QML part.

	Every time you use a property with setter and getter implemented as above,
	the value set will be reflected in the QML GUI, but it will be persisted
	only when you call the apply method.

	If, at any time, you call the reset method, all changes will be reverted
	to their original values and the user has to start over again.
*/
class QMLCache : public QObject
{
	Q_OBJECT

public:
	QMLCache(QObject *parent = 0);

	/*!
		\brief Returns the QML value corresponding to the passed key.

		If key is not managed returns an invalid variant.
	*/
	QVariant getQMLValue(int key);

	/*!
		\brief Sets a QML value corresponding to the passed key.

		If key is not managed, returns false and does nothing.
	*/
	bool setQMLValue(int key, QVariant value);

	/*!
		\brief Sets an original value corrisponding to the passed key.

		If key is not managed, registers key to be managed.
		Updates QML value to be equal to original one.
	*/
	void setOriginalValue(int key, QVariant original_value);

	/*!
		\brief Resets QML values back to original ones.

		May emit qmlValueChanged signals.
	*/
	void reset();

	/*!
		\brief Apply QML values to original ones.

		May emit qmlValueChanged signals.
		Always emits persistItemRequested signal (only one time).
	*/
	void apply();

signals:
	// a QML value has changed
	void qmlValueChanged(int key, QVariant value);
	// original values were modified: request a persistItem
	void persistItemRequested();

private:
	// registers what values were "originally" set and must be managed
	QSet<int> keys;
	QHash<int, QVariant> original_values, values;
};

// an utility template
template <class T> class Converter
{
public:
	static T* asPointer(QVariant v)
	{
		return reinterpret_cast<T *>(v.value<void *>());
	}

	static QVariant asQVariant(T* ptr)
	{
		return qVariantFromValue((void *) ptr);
	}
};

#endif // QML_CACHE_H
