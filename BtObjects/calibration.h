#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <QObject>
#include <QPoint>
#include <QWSPointerCalibrationData>


class Calibration : public QObject
{
	Q_OBJECT

	Q_ENUMS(Point)

public:
	enum Point
	{
		// must match the values in QWSPointerCalibrationData
		TopLeft,
		BottomLeft,
		BottomRight,
		TopRight,
		Center,
		// must be last
		PointCount
	};

	Calibration(QObject *parent = 0);

public slots:
	void startCalibration();
	void setCalibrationPoint(Point point, QPoint screen, QPoint touch);
	bool applyCalibration();
	void resetCalibration();
	void saveCalibration();

private:
	bool sanityCheck();

	QString pointercal_file;
	QWSPointerCalibrationData calibration_data;
};

#endif // CALIBRATION_H
