#include "stopandgoobjects.h"
#include "stopandgo_device.h"
#include "xmlobject.h"
#include "devices_cache.h"

#include <QDebug>


namespace
{
	template<class Device, class Object>
	QList<ObjectPair> parseStopAndGo(const QDomNode &obj)
	{
		QList<ObjectPair> obj_list;
		XmlObject v(obj);

		foreach (const QDomNode &ist, getChildren(obj, "ist"))
		{
			v.setIst(ist);
			int uii = getIntAttribute(ist, "uii");

			Device *d = bt_global::add_device_to_cache(new Device(v.value("where")));
			obj_list << ObjectPair(uii, new Object(d, v.value("descr")));
		}
		return obj_list;
	}
}

QList<ObjectPair> parseStopAndGo(const QDomNode &obj)
{
	return parseStopAndGo<StopAndGoDevice, StopAndGo>(obj);
}

QList<ObjectPair> parseStopAndGoPlus(const QDomNode &obj)
{
	return parseStopAndGo<StopAndGoPlusDevice, StopAndGoPlus>(obj);
}

QList<ObjectPair> parseStopAndGoBTest(const QDomNode &obj)
{
	return parseStopAndGo<StopAndGoBTestDevice, StopAndGoBTest>(obj);
}


StopAndGo::StopAndGo(StopAndGoDevice *_dev, QString _name) :
	DeviceObjectInterface(_dev)
{
	dev = _dev;
	name = _name;
	auto_reset = false;
	status = Unknown;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
}

StopAndGo::Status StopAndGo::getStatus() const
{
	return status;
}

void StopAndGo::valueReceived(const DeviceValues &values_list)
{
	Status st = status;

	// in theory we should check for the presence of all the dimensions below; however
	// we know they are sent together in the same valueReceived() signal, hence checking
	// for just one of them suffices
	if (!values_list.contains(StopAndGoDevice::DIM_OPENED))
		return;

	if (!values_list[StopAndGoDevice::DIM_OPENED].toBool())
		st = Closed;
	else
	{
		if (values_list[StopAndGoDevice::DIM_LOCKED].toBool())
			st = Locked;
		else if (values_list[StopAndGoDevice::DIM_OPENED_LE_N].toBool())
			st = ShortCircuit;
		else if (values_list[StopAndGoDevice::DIM_OPENED_GROUND].toBool())
			st = GroundFail;
		else if (values_list[StopAndGoDevice::DIM_OPENED_VMAX].toBool())
			st = Overtension;
		else
			st = Opened;
	}

	if (st != status)
	{
		status = st;
		emit statusChanged(this);
	}

	bool active = !values_list[StopAndGoDevice::DIM_AUTORESET_DISACTIVE].toBool();

	if (active != auto_reset)
	{
		auto_reset = active;
		emit autoResetChanged();
	}
}

bool StopAndGo::getAutoReset() const
{
	return auto_reset;
}

void StopAndGo::setAutoReset(bool active)
{
	if (active)
		dev->sendAutoResetActivation();
	else
		dev->sendAutoResetDisactivation();
}


StopAndGoPlus::StopAndGoPlus(StopAndGoPlusDevice *_dev, QString name) :
	StopAndGo(_dev, name)
{
	dev = _dev;
	diagnostic = false;
}

bool StopAndGoPlus::getDiagnostic() const
{
	return diagnostic;
}

void StopAndGoPlus::setDiagnostic(bool active)
{
	if (active)
		dev->sendTrackingSystemActivation();
	else
		dev->sendTrackingSystemDisactivation();
}

void StopAndGoPlus::forceClosed()
{
	// TODO waiting for clarifications
}

void StopAndGoPlus::valueReceived(const DeviceValues &values_list)
{
	StopAndGo::valueReceived(values_list);

	// see comment in StopAndGo::valueReceived
	if (!values_list.contains(StopAndGoDevice::DIM_OPENED))
		return;

	bool diag = !values_list[StopAndGoDevice::DIM_TRACKING_DISACTIVE].toBool();
	if (diag != diagnostic)
	{
		diagnostic = diag;
		emit diagnosticChanged();
	}
}


StopAndGoBTest::StopAndGoBTest(StopAndGoBTestDevice *_dev, QString name) :
	StopAndGo(_dev, name)
{
	dev = _dev;
	auto_test = false;
	current[AUTO_TEST_FREQUENCY] = -1;
	reset();
}

bool StopAndGoBTest::getAutoTest() const
{
	return auto_test && current[AUTO_TEST_FREQUENCY] != -1;
}

void StopAndGoBTest::setAutoTest(bool active)
{
	if (active)
		dev->sendDiffSelftestActivation();
	else
		dev->sendDiffSelftestDisactivation();
}

int StopAndGoBTest::getAutoTestFrequency() const
{
	return to_apply[AUTO_TEST_FREQUENCY].toInt();
}

void StopAndGoBTest::setAutoTestFrequency(int frequency)
{
	if (to_apply[AUTO_TEST_FREQUENCY] != frequency)
	{
		to_apply[AUTO_TEST_FREQUENCY] = frequency;
		emit autoTestFrequencyChanged();
	}
}

void StopAndGoBTest::increaseAutoTestFrequency()
{
	if (getAutoTestFrequency() >= StopAndGoBTestDevice::SELF_TEST_FREQ_MAX)
		return;
	setAutoTestFrequency(getAutoTestFrequency() + 1);
}

void StopAndGoBTest::decreaseAutoTestFrequency()
{
	if (getAutoTestFrequency() <= StopAndGoBTestDevice::SELF_TEST_FREQ_MIN)
		return;
	setAutoTestFrequency(getAutoTestFrequency() - 1);
}

void StopAndGoBTest::valueReceived(const DeviceValues &values_list)
{
	StopAndGo::valueReceived(values_list);

	if (values_list.contains(StopAndGoBTestDevice::DIM_AUTOTEST_FREQ))
	{
		int freq = values_list[StopAndGoBTestDevice::DIM_AUTOTEST_FREQ].toInt();
		if (freq != current[AUTO_TEST_FREQUENCY])
		{
			bool enabled = getAutoTest();

			current[AUTO_TEST_FREQUENCY] = freq;
			reset();
			emit autoTestFrequencyChanged();

			if (!enabled && getAutoTest())
				emit autoTestChanged();
		}
	}

	// see comment in StopAndGo::valueReceived
	if (!values_list.contains(StopAndGoDevice::DIM_OPENED))
		return;

	bool enabled = getAutoTest();
	bool stat = !values_list[StopAndGoDevice::DIM_AUTOTEST_DISACTIVE].toBool();
	if (stat != auto_test)
	{
		auto_test = stat;

		if (enabled != getAutoTest())
			emit autoTestChanged();
	}
}

void StopAndGoBTest::apply()
{
	current = to_apply;
	dev->sendSelftestFreq(current[AUTO_TEST_FREQUENCY].toInt());
}

void StopAndGoBTest::reset()
{
	to_apply = current;
}
