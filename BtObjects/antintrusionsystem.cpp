#include "antintrusionsystem.h"
#include "antintrusion_device.h"
#include "devices_cache.h"
#include "objectmodel.h"

#include "xml_functions.h"

#include <QDebug>
#include <QStringList>
#include <QtAlgorithms>


namespace
{
AntintrusionAlarmSource *findAlarmSource(const ObjectDataModel &sources, int number)
{
	for (int i = 0; i < sources.getCount(); ++i)
	{
		AntintrusionAlarmSource *s = static_cast<AntintrusionAlarmSource *>(sources.getObject(i));

		if (s->getNumber() == number)
			return s;
	}

	return 0;
}
}


QList<ObjectPair> parseAntintrusionZone(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);

		if (!where.length() == 2 && !where.startsWith('#'))
		{
			qWarning("Invalid where in antintrusion zone");
			continue;
		}

		bool ok;
		int zone = where.mid(1).toInt(&ok);

		if (!ok)
		{
			qWarning("Invalid where in antintrusion zone");
			continue;
		}

		obj_list << ObjectPair(uii, new AntintrusionZone(zone, descr));
	}
	return obj_list;
}

QList<ObjectPair> parseAntintrusionAux(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);

		bool ok;
		int number = where.toInt(&ok);

		if (!ok)
		{
			qWarning("Invalid number in antintrusion aux");
			continue;
		}

		obj_list << ObjectPair(uii, new AntintrusionAlarmSource(number, descr));
	}
	return obj_list;
}

QList<ObjectPair> parseAntintrusionScenario(const QDomNode &obj, const UiiMapper &uii_map, QList<AntintrusionZone *> zones)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QList<int> zone_ids;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			AntintrusionZone *zone = uii_map.value<AntintrusionZone>(object_uii);

			if (!zone)
			{
				qWarning() << "Invalid uii" << object_uii << "in antintrusion zone set";
				Q_ASSERT_X(false, "parseAntintrusionScenario", "Invalid uii");
				continue;
			}

			zone_ids.append(zone->getNumber());
		}

		obj_list << ObjectPair(uii, new AntintrusionScenario(descr, zone_ids, zones));
	}
	return obj_list;
}

AntintrusionSystem *createAntintrusionSystem(QList<AntintrusionZone *> zones, QList<AntintrusionAlarmSource *> aux, QList<AntintrusionScenario *> scenarios)
{
	AntintrusionDevice *dev = bt_global::add_device_to_cache(new AntintrusionDevice);
	AntintrusionSystem *system = new AntintrusionSystem(dev, scenarios, aux, zones);
	// this is needed to have toolbar icon notifications since startup
	// this is needed to request zone status since the antintrusion object is
	// never inserted into a container
	system->enableObject();

	return system;
}


AntintrusionAlarmSource::AntintrusionAlarmSource(int _number, QString _name)
{
	name = _name;
	number = _number;
}

int AntintrusionAlarmSource::getNumber() const
{
	return number;
}


AntintrusionZone::AntintrusionZone(int id, QString _name) : AntintrusionAlarmSource(id, _name)
{
	active = selected = false;
}

bool AntintrusionZone::getSelected() const
{
	return selected;
}

bool AntintrusionZone::getActive() const
{
	return active;
}

void AntintrusionZone::setSelected(bool p)
{
	if (p != selected)
	{
		selected = p;
		emit selectedChanged();
		// we need the device to request the parzialization when inserting
		// the system
		emit requestPartialization(getNumber(), !p);
	}
}

void AntintrusionZone::setActive(bool p)
{
	if (p != active)
	{
		active = p;
		emit activeChanged();
	}
	if (p != selected)
	{
		selected = p;
		emit selectedChanged();
	}
}

AntintrusionScenario::AntintrusionScenario(QString _name, QList<int> _scenario_zones, QList<AntintrusionZone*> _zones)
{
	name = _name;
	scenario_zones = _scenario_zones;
	zones = _zones;
	foreach (AntintrusionZone *z, zones)
		connect(z, SIGNAL(selectedChanged()), SLOT(verifySelection()));
	verifySelection(false);
}

QString AntintrusionScenario::getDescription() const
{
	QStringList l;
	foreach (int z, scenario_zones)
		l << QString::number(z);

	return l.join(".");
}

void AntintrusionScenario::verifySelection(bool notify)
{
	QList<int> selected_zones;
	foreach (AntintrusionZone *z, zones)
		if (z->getSelected())
			selected_zones.append(z->getNumber());

	QSet<int> scenario_zones_set = scenario_zones.toSet();
	QSet<int> selected_zones_set = selected_zones.toSet();
	bool sets_are_equal = (scenario_zones_set == selected_zones_set);
	if (notify && selected != sets_are_equal)
	{
		selected = sets_are_equal;
		emit selectionChanged();
	}
	else
		selected = sets_are_equal;
}

bool AntintrusionScenario::isSelected() const
{
	return selected;
}

void AntintrusionScenario::apply()
{
	foreach (AntintrusionZone *z, zones)
	{
		bool inserted = scenario_zones.contains(z->getNumber());
		z->setSelected(inserted);
	}
}


AntintrusionAlarm::AntintrusionAlarm(AlarmType _type, const AntintrusionAlarmSource *_source, int _number, QDateTime time)
{
	type = _type;
	source = _source;
	number = _number;
	date_time = time;
}

AntintrusionAlarm::AlarmType AntintrusionAlarm::getType()
{
	return type;
}

ObjectInterface *AntintrusionAlarm::getSource()
{
	return const_cast<AntintrusionAlarmSource *>(source);
}

QDateTime AntintrusionAlarm::getDateTime()
{
	return date_time;
}

int AntintrusionAlarm::getNumber() const
{
	return source ? source->getNumber() : number;
}

QString AntintrusionAlarm::getName() const
{
	return source ? source->getName() : "";
}


AntintrusionSystem::AntintrusionSystem(AntintrusionDevice *d, QList<AntintrusionScenario*> _scenarios, QList<AntintrusionAlarmSource *> _aux, QList<AntintrusionZone*> _zones) :
	DeviceObjectInterface(d)
{
	foreach (AntintrusionScenario *s, _scenarios)
	{
		scenarios << s;
		connect(s, SIGNAL(selectionChanged()), this, SIGNAL(currentScenarioChanged()));
	}

	foreach (AntintrusionZone *z, _zones)
	{
		zones << z;
		d->partializeZone(z->getNumber(), !z->getSelected()); // initialization
		connect(z, SIGNAL(requestPartialization(int,bool)), d, SLOT(partializeZone(int,bool)));
		connect(z, SIGNAL(selectedChanged()), this, SIGNAL(canPartializeChanged()));
		connect(z, SIGNAL(activeChanged()), this, SIGNAL(canPartializeChanged()));
	}

	foreach (AntintrusionAlarmSource *a, _aux)
		aux << a;

	current_scenario = -1;
	waiting_response = false;
	initialized = false;
	status = false;
	dev = d;
	zones_to_check = 0;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

ObjectDataModel *AntintrusionSystem::getScenarios() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectDataModel*>(&scenarios);
}

ObjectDataModel *AntintrusionSystem::getAlarms() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectDataModel*>(&alarms);
}

ObjectDataModel *AntintrusionSystem::getZones() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectDataModel*>(&zones);
}

void AntintrusionSystem::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case AntintrusionDevice::DIM_SYSTEM_INSERTED:
		{
			bool inserted = it.value().toBool();
			if (!initialized)
			{
				initialized = true;
				setStatus(inserted);
			}
			else
			{
				if (inserted == status)
				{
					if (waiting_response && (zones_to_check == 0))
					{
						emit codeRefused();
						waiting_response = false;
					}
				}
				else
				{
					if (!status)
						alarms.clear();
					setStatus(inserted);
					emit statusChanged();

					if (waiting_response)
					{
						emit codeAccepted();
						waiting_response = false;
					}
				}
			}
			break;
		}

		case AntintrusionDevice::DIM_ZONE_INSERTED:
		case AntintrusionDevice::DIM_ZONE_PARTIALIZED:
			for (int i = 0; i < zones.getCount(); ++i)
			{
				AntintrusionZone *z = static_cast<AntintrusionZone*>(zones.getObject(i));
				if (z->getNumber() == it.value().toInt())
				{
					// we have to check code correctness: we assume the code
					// is wrong if no zone has changed its partialization
					// value, otherwise we assume it is right
					bool newActiveValue = (it.key() == AntintrusionDevice::DIM_ZONE_INSERTED);
					if (z->getActive() != newActiveValue)
						code_right = true;
					z->setActive(newActiveValue);
					if (!(--zones_to_check))
					{
						if (code_right)
							emit codeAccepted();
						else
							emit codeRefused();
						waiting_response = false;
					}
				}
			}
			break;
		case AntintrusionDevice::DIM_ANTIPANIC_ALARM:
			addAlarm(AntintrusionAlarm::Antipanic, it.value().toInt());
			break;
		case AntintrusionDevice::DIM_INTRUSION_ALARM:
			addAlarm(AntintrusionAlarm::Intrusion, it.value().toInt());
			break;
		case AntintrusionDevice::DIM_TAMPER_ALARM:
			addAlarm(AntintrusionAlarm::Tamper, it.value().toInt());
			break;
		case AntintrusionDevice::DIM_TECHNICAL_ALARM:
			addAlarm(AntintrusionAlarm::Technical, it.value().toInt());
			break;

		case AntintrusionDevice::DIM_RESET_TECHNICAL_ALARM:
			removeAlarm(AntintrusionAlarm::Technical, it.value().toInt());
			break;
		}

		++it;
	}
}

void AntintrusionSystem::handleCodeTimeout()
{
	if (!waiting_response) // we have already received the response
		return;

	qDebug() << "AntintrusionSystem -> code timeout";
	waiting_response = false;
	emit codeTimeout();
}

void AntintrusionSystem::addAlarm(AntintrusionAlarm::AlarmType t, int zone_num)
{
	// ensure that no other same alarm is already present
	if (isDuplicateAlarm(t, zone_num))
	{
		qDebug() << "Ignoring duplicate alarm";
		return;
	}

	bool requires_source = true;
	AntintrusionAlarmSource *source = 0;

	switch (t)
	{
	case AntintrusionAlarm::Intrusion:
		source = findAlarmSource(zones, zone_num);
		requires_source = true;
		break;
	case AntintrusionAlarm::Antipanic:
		if (zone_num != 9)
		{
			qWarning() << "Invalid zone" << zone_num << "for antipanic alarm";
			return;
		}

		source = findAlarmSource(zones, zone_num);
		requires_source = false;
		break;
	case AntintrusionAlarm::Tamper:
		if (zone_num <= 8)
		{
			source = findAlarmSource(zones, zone_num);
			requires_source = true;
		}
		else
		{
			source = 0;
			requires_source = false;
		}
		break;
	case AntintrusionAlarm::Technical:
		source = findAlarmSource(aux, zone_num);
		requires_source = true;
		break;
	}

	if (!source && requires_source)
	{
		qWarning() << "Alarm source" << zone_num << "not configured, ignoring event";
		return;
	}

	AntintrusionAlarm *a = new AntintrusionAlarm(t, source, zone_num, QDateTime::currentDateTime());
	alarms << a;
	emit newAlarm(a);
}

void AntintrusionSystem::removeAlarm(AntintrusionAlarm::AlarmType t, int zone_num)
{
	for (int i = 0; i < alarms.getCount(); ++i)
	{
		AntintrusionAlarm *alarm = static_cast<AntintrusionAlarm *>(alarms.getObject(i));
		int number = alarm->getNumber();

		if (alarm->getType() == t && number == zone_num)
		{
			alarms.removeRow(i);
			return;
		}
	}
	qWarning() << "No active technical alarm for source" << zone_num;
}

bool AntintrusionSystem::isDuplicateAlarm(AntintrusionAlarm::AlarmType t, int zone_num)
{
	for (int i = 0; i < alarms.getCount(); ++i)
	{
		AntintrusionAlarm *alarm = static_cast<AntintrusionAlarm *>(alarms.getObject(i));
		if (t == alarm->getType() && alarm->getNumber() == zone_num)
			return true;
	}
	return false;
}

void AntintrusionSystem::setStatus(bool new_value)
{
	if (status == new_value)
		return;

	status = new_value;
	emit statusChanged();
}

void AntintrusionSystem::requestPartialization(const QString &password)
{
	if (!canPartialize())
	{
		qWarning() << "Ignoring partialization request. System is inserted or configuration is not changed.";
		return;
	}
	// sets some values to check code correctness for partialization
	zones_to_check = zones.getCount();
	code_right = false;
	dev->setPartialization(password);
	waiting_response = true;
	QTimer::singleShot(AntintrusionSystemNS::CODE_TIMEOUT_SECS * 1000, this, SLOT(handleCodeTimeout()));
}

void AntintrusionSystem::toggleActivation(const QString &password)
{
	dev->toggleActivation(password);
	waiting_response = true;
	QTimer::singleShot(AntintrusionSystemNS::CODE_TIMEOUT_SECS * 1000, this, SLOT(handleCodeTimeout()));
}

bool AntintrusionSystem::canPartialize() const
{
	// if system is inserted is not possible to request a partialization
	if (status)
		return false;
	// we request a partialization only if zones configuration is changed
	for (int i = 0; i < zones.getCount(); ++i)
	{
		AntintrusionZone *z = static_cast<AntintrusionZone*>(zones.getObject(i));
		if (z->getActive() != z->getSelected())
			return true;
	}
	return false;
}

QObject *AntintrusionSystem::getCurrentScenario() const
{
	for (int i = 0; i < scenarios.getCount(); ++i)
	{
		AntintrusionScenario* s = static_cast<AntintrusionScenario*>(scenarios.getObject(i));
		if (s->isSelected())
			return s;
	}

	return 0;
}

