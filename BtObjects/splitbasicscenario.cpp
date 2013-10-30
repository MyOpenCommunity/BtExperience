#include "splitbasicscenario.h"
#include "airconditioning_device.h"
#include "probe_device.h"
#include "devices_cache.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "uiimapper.h"
#include "objectmodel.h"

#include <libqtcommon/scaleconversion.h>

#include <QDebug>


QList<ObjectPair> parseSplitBasicCommandGroup(const QDomNode &xml_node, QHash<int, QPair<QDomNode, QDomNode> > programs)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QList<QPair<QString, SplitBasicProgram *> > commands;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");

			if (!programs.contains(object_uii))
			{
				qWarning() << "Invalid command uii" << object_uii << "in command group";
				continue;
			}

			QPair<QDomNode, QDomNode> obj_ist = programs[object_uii];
			XmlObject pv(obj_ist.first);

			pv.setIst(obj_ist.second);

			SplitBasicProgram *p = new SplitBasicProgram(pv.value("descr"), pv.intValue("command"));
			commands.append(qMakePair(pv.value("where"), p));
		}
		obj_list << ObjectPair(uii, new SplitBasicCommandGroup(v.value("descr"), commands));
	}
	return obj_list;
}

QList<ObjectPair> parseSplitBasicScenario(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString off_command = v.intValue("off_presence") ? v.value("off_cmd") : QString();
		NonControlledProbeDevice *probe = 0;
		AirConditioningDevice *d = new AirConditioningDevice(v.value("where"));

		if (v.intValue("eprobe"))
		{
			QString where = getAttribute(getChildWithName(ist, "probe"), "where_probe");

			probe = bt_global::add_device_to_cache(new NonControlledProbeDevice(where, NonControlledProbeDevice::INTERNAL));
		}

		obj_list << ObjectPair(uii, new SplitBasicScenario(v.value("descr"), "", d, off_command, probe));
	}
	return obj_list;
}

QList<ObjectPair> parseSplitBasicCommand(const QDomNode &xml_node, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			SplitBasicScenario *s = uii_map.value<SplitBasicScenario>(object_uii);

			if (!s)
			{
				qWarning() << "Invalid split uii" << object_uii << "in command";
				continue;
			}

			SplitBasicProgram *p = new SplitBasicProgram(v.value("descr"), v.intValue("command"));
			SplitBasicCommand *c = new SplitBasicCommand(s);

			s->addProgram(p);
			c->appendCommand(s, p);

			obj_list << ObjectPair(uii, c);
		}
	}
	return obj_list;
}


SplitBasicProgram::SplitBasicProgram(const QString &_name, int number)
{
	program_number = number;
	name = _name;
}


SplitBasicScenario::SplitBasicScenario(QString _name, QString _key, AirConditioningDevice *d,
		QString off_command, NonControlledProbeDevice *d_probe, QObject *parent) :
	DeviceObjectInterface(d_probe, parent)
{
	dev = d;
	dev_probe = d_probe;
	if (dev_probe)
		connect(dev_probe, SIGNAL(valueReceived(DeviceValues)),
				SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	actual_program = 0;
	dev->setOffCommand(off_command);
	if (!off_command.isEmpty())
	{
		SplitBasicProgram *p = new SplitBasicOffProgram(off_command.toInt());
		programs << p;
		actual_program = p;
	}
	temperature = 1235; // -23.5
	is_valid_temperature = false;
}

void SplitBasicScenario::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case NonControlledProbeDevice::DIM_TEMPERATURE:
			if (it.value().toInt() != temperature)
			{
				temperature = it.value().toInt();
				emit temperatureChanged();
				if (!is_valid_temperature)
				{
					is_valid_temperature = true;
					emit temperatureIsValidChanged(is_valid_temperature);
				}
			}
			break;
		}
		++it;
	}
}

SplitBasicProgram *SplitBasicScenario::getProgram() const
{
	return actual_program;
}

ObjectDataModel *SplitBasicScenario::getPrograms() const
{
	return const_cast<ObjectDataModel*>(&programs);
}

void SplitBasicScenario::setProgram(SplitBasicProgram *program)
{
	if (actual_program != program)
	{
		bool found = false;
		for (int i = 0; i < programs.rowCount(); ++i)
		{
			if (programs.getObject(i) == program)
				found = true;
		}
		if (!found)
			return;
		actual_program = program;
		emit programChanged();
	}
}

void SplitBasicScenario::addProgram(SplitBasicProgram *program)
{
	programs << program;
	if (!actual_program)
		actual_program = program;
}

void SplitBasicScenario::execute(SplitBasicProgram *program)
{
	// see apply for reasons to use getObjectId
	dev->activateScenario(QString::number(program->getObjectId()));
}

void SplitBasicScenario::apply()
{
	// since program number is correct for all programs (including "off"), just using
	// activateScenario() works for both normal programs and the off program
	dev->activateScenario(QString::number(actual_program->getObjectId()));
}

int SplitBasicScenario::getTemperature() const
{
	return bt2Celsius(temperature);
}

bool SplitBasicScenario::getTemperatureEnabled() const
{
	return dev_probe != 0;
}

bool SplitBasicScenario::getTemperatureIsValid() const
{
	return is_valid_temperature;
}

SplitBasicCommandGroup::SplitBasicCommandGroup(QString _name, QList<QPair<QString, SplitBasicProgram *> > _commands)
{
	typedef QPair<QString, SplitBasicProgram *> Command;

	name = _name;

	foreach (Command command, _commands)
	{
		AirConditioningDevice *d = bt_global::add_device_to_cache(new AirConditioningDevice(command.first));

		commands.append(qMakePair(d, command.second));
	}
}

void SplitBasicCommandGroup::apply()
{
	typedef QPair<AirConditioningDevice *, SplitBasicProgram *> Command;

	foreach (Command command, commands)
		command.first->activateScenario(QString::number(command.second->getObjectId()));
}


SplitBasicCommand::SplitBasicCommand(QObject *parent) : ObjectInterface(parent)
{
	commands.clear();
}

void SplitBasicCommand::appendCommand(SplitBasicScenario *scenario, SplitBasicProgram *program)
{
	setName(program->getName()); // uses last
	commands.append(qMakePair(scenario, program));
}

void SplitBasicCommand::execute()
{
	typedef QPair<SplitBasicScenario *, SplitBasicProgram *> Command;
	foreach (Command command, commands) {
		command.first->execute(command.second);
	}
}
