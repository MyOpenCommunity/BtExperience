#ifndef THERMALPROBES_H
#define THERMALPROBES_H

/*!
	\defgroup ThermalRegulation Thermal regulation
*/

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
		\brief Gets the local status of the probe

		- Off forces the probe to off regardless of the status of the control unit
		- Antifreeze forces the probe to antifreeze regardless of the status of the control unit
		- Normal follows the status of the control unit
	*/
	Q_PROPERTY(ProbeStatus localProbeStatus READ getLocalProbeStatus NOTIFY localProbeStatusChanged)

	/*!
		\brief Gets the temperature measured by the probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

	/*!
		\brief Gets the target temperature for the probe (for manual mode)
	*/
	Q_PROPERTY(int setpoint READ getSetpoint WRITE setSetpoint NOTIFY setpointChanged)

	/*!
		\brief Gets the local offset temperature applied to set point value
	*/
	Q_PROPERTY(int localOffset READ getLocalOffset NOTIFY localOffsetChanged)

	/*!
		\brief Gets the central unit type (99 zones or 4 zones) associated to this probe
	*/
	Q_PROPERTY(CentralType centralType READ getCentralType CONSTANT)

	Q_ENUMS(ProbeStatus CentralType)

public:
	enum ProbeStatus
	{
		Unknown,    /*!< No state received yet (only during initialization). */
		Normal = Unknown, /*!< Probe status controlled by central unit (only returned by local probe status). */
		Manual,     /*!< Manual mode. */
		Auto,       /*!< Automatic mode. */
		Off,        /*!< Zone off. */
		Antifreeze  /*!< Antifreeze mode. */
	};

	enum CentralType
	{
		CentralUnit99Zones = 0, /*!< Probe associated to a 99-zone central. */
		CentralUnit4Zones = 1,  /*!< Probe associated to a 4-zone central. */
	};

	ThermalControlledProbe(QString name, QString key, CentralType centralType, ControlledProbeDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlledProbe;
	}

	virtual QString getObjectKey() const;

	ProbeStatus getProbeStatus() const;
	void setProbeStatus(ProbeStatus st);

	ProbeStatus getLocalProbeStatus() const;

	int getTemperature() const;

	int getSetpoint() const;
	void setSetpoint(int sp);

	int getLocalOffset() const;

	CentralType getCentralType() const;

signals:
	void probeStatusChanged();
	void temperatureChanged();
	void setpointChanged();
	void localOffsetChanged();
	void localProbeStatusChanged();

protected:
	ControlledProbeDevice *dev;

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	QString key;
	ProbeStatus plant_status, local_status;
	int setpoint;
	int temperature, local_offset;
	CentralType central_type;
};


/*!
	\ingroup ThermalRegulation
	\brief Manages thermal regulation controlled probes with fancoil

	The object id is \a ObjectInterface::IdThermalControlledProbeFancoil, the object key is the SCS where.
*/
class ThermalControlledProbeFancoil : public ThermalControlledProbe
{
	friend class TestThermalProbesFancoil;

	Q_OBJECT

	/*!
		\brief Sets or gets the fancoil status (only for probes associated with a fancoil)
	*/
	Q_PROPERTY(FancoilSpeed fancoil READ getFancoil WRITE setFancoil NOTIFY fancoilChanged)

	Q_ENUMS(FancoilSpeed)

public:
	enum FancoilSpeed
	{
		// these values are the same of the ControlledProbeDevice
		FancoilMin = 1,  /*!< Minimum speed */
		FancoilMed,      /*!< Medium speed */
		FancoilMax,      /*!< Maximum speed */
		FancoilAuto      /*!< Automatic speed */
	};

	ThermalControlledProbeFancoil(QString name, QString key, CentralType centralType, ControlledProbeDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlledProbeFancoil;
	}

	FancoilSpeed getFancoil() const;
	void setFancoil(FancoilSpeed s);

signals:
	void fancoilChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	FancoilSpeed fancoil_speed;
};

#endif // THERMALPROBES_H

