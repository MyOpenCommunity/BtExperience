#ifndef THERMALPROBES_H
#define THERMALPROBES_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QString>

class ControlledProbeDevice;


class ThermalControlledProbe : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(ProbeStatus probeStatus READ getProbeStatus WRITE setProbeStatus NOTIFY probeStatusChanged)
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)
	Q_PROPERTY(int setpoint READ getSetpoint WRITE setSetpoint NOTIFY setpointChanged)
	Q_PROPERTY(FancoilSpeed fancoil READ getFancoil WRITE setFancoil NOTIFY fancoilChanged)
	Q_ENUMS(ProbeStatus)
	Q_ENUMS(FancoilSpeed)

public:
	enum ProbeStatus
	{
		Unknown,
		Manual,
		Auto,
		Antifreeze,
		Off
	};

	enum FancoilSpeed
	{
		FancoilMin = 1, // this values are the same of the ControlledProbeDevice
		FancoilMed,
		FancoilMax,
		FancoilAuto
	};

	ThermalControlledProbe(QString name, QString key, ControlledProbeDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlledProbe;
	}

	virtual QString getObjectKey() const;

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::ThermalRegulation;
	}

	virtual QString getName() const;

	ProbeStatus getProbeStatus() const;
	void setProbeStatus(ProbeStatus st);

	int getTemperature() const;

	int getSetpoint() const;
	void setSetpoint(int sp);

	FancoilSpeed getFancoil() const;
	void setFancoil(FancoilSpeed s);

signals:
	void probeStatusChanged();
	void temperatureChanged();
	void setpointChanged();
	void fancoilChanged();

private slots:
	void valueReceived(const DeviceValues &values_list);

private:
	QString name;
	QString key;
	ProbeStatus probe_status;
	FancoilSpeed fancoil_speed;
	int setpoint;
	int temperature;
	ControlledProbeDevice *dev;
};


#endif // THERMALPROBES_H

