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
class ThermalControlUnit;
class NonControlledProbeDevice;
class QDomNode;

QList<ObjectPair> parseExternalNonControlledProbes(const QDomNode &obj, ObjectInterface::ObjectId type);


/*!
	\ingroup ThermalRegulation
	\brief Manages thermal regulation external probes

	The object id is \ref ObjectInterface::IdThermalExternalProbe or \ref ObjectInterface::IdThermalNonControlledProbe,
	the object key is the SCS where.
*/
class ThermalNonControlledProbe : public DeviceObjectInterface
{
	friend class TestThermalNonControlledProbes;

	Q_OBJECT

	/*!
		\brief Gets the temperature measured by the probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

public:
	ThermalNonControlledProbe(QString name, QString key, ObjectId object_id, NonControlledProbeDevice *dev);

	virtual QString getObjectKey() const;

	virtual int getObjectId() const
	{
		return object_id;
	}

	int getTemperature() const;

signals:
	void temperatureChanged();

private slots:
	void valueReceived(const DeviceValues &values_list);

private:
	QString key;
	int object_id;
	NonControlledProbeDevice *dev;
	int temperature;
};


/*!
	\ingroup ThermalRegulation
	\brief Manages thermal regulation controlled probes

	The object id is \a ObjectInterface::IdThermalControlledProbe, the object key is the SCS where.
*/
class ThermalControlledProbe : public DeviceObjectInterface
{
	friend class TestThermalControlledProbes;

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

	/*!
		\brief Gets the mimimum allowed temperature for manual mode (in Celsius degrees * 10)
	*/
	Q_PROPERTY(int minimumManualTemperature READ getMinimumManualTemperature CONSTANT)

	/*!
		\brief Gets the maximum allowed temperature for manual mode (in Celsius degrees * 10)
	*/
	Q_PROPERTY(int maximumManualTemperature READ getMaximumManualTemperature CONSTANT)

	/*!
		\brief Gets the control unit for this probe
	*/
	Q_PROPERTY(ThermalControlUnit *controlUnit READ getControlUnit CONSTANT)

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

	ThermalControlledProbe(QString name, QString key, ThermalControlUnit *control_unit, ControlledProbeDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlledProbe;
	}

	virtual QString getObjectKey() const;

	ProbeStatus getProbeStatus() const;
	void setProbeStatus(ProbeStatus st);

	ProbeStatus getLocalProbeStatus() const;

	int getTemperature() const;

	int getMinimumManualTemperature() const;
	int getMaximumManualTemperature() const;

	int getSetpoint() const;
	void setSetpoint(int sp);

	int getLocalOffset() const;

	CentralType getCentralType() const;

	ThermalControlUnit *getControlUnit() const;

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
	ThermalControlUnit *control_unit;
};


/*!
	\ingroup ThermalRegulation
	\brief Manages thermal regulation controlled probes with fancoil

	The object id is \a ObjectInterface::IdThermalControlledProbeFancoil, the object key is the SCS where.
*/
class ThermalControlledProbeFancoil : public ThermalControlledProbe
{
	friend class TestThermalControlledProbesFancoil;

	Q_OBJECT

	/*!
		\brief Sets or gets the fancoil status (only for probes associated with a fancoil)
	*/
	Q_PROPERTY(FancoilSpeed fancoil READ getFancoil WRITE setFancoil NOTIFY fancoilChanged)
	Q_PROPERTY(FancoilSpeed fancoilMinValue READ fancoilMinValue CONSTANT)
	Q_PROPERTY(FancoilSpeed fancoilMaxValue READ fancoilMaxValue CONSTANT)

	Q_ENUMS(FancoilSpeed)

public:
	enum FancoilSpeed
	{
		// these values are the same of the ControlledProbeDevice
		FancoilAuto = 0, /*!< Automatic speed */
		FancoilMin,      /*!< Minimum speed */
		FancoilMed,      /*!< Medium speed */
		FancoilMax       /*!< Maximum speed */
	};

	ThermalControlledProbeFancoil(QString name, QString key, ThermalControlUnit *control_unit, ControlledProbeDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlledProbeFancoil;
	}

	FancoilSpeed getFancoil() const;
	FancoilSpeed fancoilMinValue() const { return FancoilAuto; }
	FancoilSpeed fancoilMaxValue() const { return FancoilMax; }
	void setFancoil(FancoilSpeed s);

signals:
	void fancoilChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	FancoilSpeed fancoil_speed;
};

#endif // THERMALPROBES_H

