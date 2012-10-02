#include "splitbasicscenario.h"
#include "airconditioning_device.h"
#include "probe_device.h"
#include "scaleconversion.h"
#include "devices_cache.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "uiimapper.h"
#include "objectmodel.h"

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

void parseSplitBasicCommand(const QDomNode &xml_node, const UiiMapper &uii_map)
{
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			SplitBasicScenario *s = uii_map.value<SplitBasicScenario>(object_uii);

			if (!s)
			{
				qWarning() << "Invalid split uii" << object_uii << "in command";
				continue;
			}

			s->addProgram(new SplitBasicProgram(v.value("descr"), v.intValue("command")));
		}
	}
}


SplitBasicProgram::SplitBasicProgram(const QString &_name, int number)
{
	program_number = number;
	name = _name;
}

SplitBasicScenario::SplitBasicScenario(QString _name,
									   QString _key,
									   AirConditioningDevice *d,
									   QString off_command,
									   NonControlledProbeDevice *d_probe,
									   QObject *parent) :
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
		program_list.append(new SplitBasicProgram("off", off_command.toInt()));
		actual_program = program_list.front();
	}
	temperature = 200;
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
			}
			break;
		}
		++it;
	}
}

QString SplitBasicScenario::getProgram() const
{
	return actual_program->getName();
}

QStringList SplitBasicScenario::getPrograms() const
{
	QStringList result;
	for (int i = 0; i < program_list.size(); ++i)
		result << program_list.at(i)->getName();
	return result;
}

int SplitBasicScenario::getCount() const
{
	return program_list.size();
}

void SplitBasicScenario::setProgram(QString program)
{
	if (program.isEmpty())
	{
		qWarning() << QString("SplitBasicScenario::setProgram(): "
							  "program cannot be empty");
		return;
	}

	if (actual_program->getName() == program)
		// nothing to do
		return;

	// looks for the program in the program list
	int p = program_list.size() - 1;
	for (; p >= 0; --p)
	{
		if (program == program_list.at(p)->getName())
			break;
	}

	// if not found, print a warning and exit
	if (p == -1)
	{
		qWarning() << QString("SplitBasicScenario::setProgram(%1) didn't "
							  "find the program inside available ones. "
							  "Program will not be changed.").arg(program);
		return;
	}

	actual_program = program_list.at(p);
	emit programChanged();
}

void SplitBasicScenario::addProgram(SplitBasicProgram *program)
{
	program_list.append(program);
	if (!actual_program)
		actual_program = program_list.front();
}

void SplitBasicScenario::apply()
{
	if (actual_program && actual_program->getName() == tr("off"))
		dev->turnOff();
	else
		dev->activateScenario(QString::number(actual_program->getObjectId()));
}

int SplitBasicScenario::getTemperature() const
{
	return bt2Celsius(temperature);
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
