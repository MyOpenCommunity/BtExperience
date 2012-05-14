#ifndef THERMALPROBES_H
#define THERMALPROBES_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QString>

class ControlledProbeDevice;


/*!
	\ingroup ThermalRegulation
	\brief Manages thermal regulation controlled probes

	The object id is \a ObjectInterface::IdThermalControlledProbe, the object key is the SCS where.
*/
class ThermalControlledProbe : public ObjectInterface
{
	friend class TestThermalProbes;

	Q_OBJECT

	/*!
		\brief Sets or gets the status of the probe
	*/
	Q_PROPERTY(ProbeStatus probeStatus READ getProbeStatus WRITE setProbeStatus NOTIFY probeStatusChanged)

	/*!
		\brief Gets the temperature measured by the probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

	/*!
		\brief Gets the target temperature for the probe (for manual mode)
	*/
	Q_PROPERTY(int setpoint READ getSetpoint WRITE setSetpoint NOTIFY setpointChanged)

	/*!
		\brief Sets or gets the fancoil status (only for probes associated with a fancoil)
	*/
	Q_PROPERTY(FancoilSpeed fancoil READ getFancoil WRITE setFancoil NOTIFY fancoilChanged)

	Q_ENUMS(ProbeStatus)
	Q_ENUMS(FancoilSpeed)

public:
	enum ProbeStatus
	{
		Unknown,    /*!< No state received yet (only during initialization). */
		Manual,     /*!< Manual mode. */
		Auto,       /*!< Automatic mode. */
		Off,        /*!< Zone off. */
		Antifreeze  /*!< Antifreeze mode. */
	};

	enum FancoilSpeed
	{
		// these values are the same of the ControlledProbeDevice
		FancoilMin = 1,  /*!< Minimum speed */
		FancoilMed,      /*!< Medium speed */
		FancoilMax,      /*!< Maximum speed */
		FancoilAuto      /*!< Automatic speed */
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
	virtual void valueReceived(const DeviceValues &values_list);

private:
	QString key;
	ProbeStatus probe_status;
	FancoilSpeed fancoil_speed;
	int setpoint;
	int temperature;
	ControlledProbeDevice *dev;
};


#endif // THERMALPROBES_H

