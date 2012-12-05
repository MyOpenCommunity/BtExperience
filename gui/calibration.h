#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <QObject>
#include <QPoint>
#include <QWSPointerCalibrationData>


/*!
	\brief Set calibration points

	To perform calibration, call \ref startCalibration() to put the screen
	in raw mode.  Ask the user to click the 4 corners and the center of the screen
	and set the coordinates using \ref setCalibrationPoint().  If \ref applyCalibration()
	returns \c false, repeat the procedure.
*/
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

	/// Check whether the calibration data file exists
	Q_INVOKABLE bool exists() const;

public slots:
	/*!
		\brief Put the screen in raw mode and save a backup of the calibration file
	*/
	void startCalibration();

	/*!
		\brief Set the screen and raw coordinates for one point.
		\param screen the screen coordinate where the user should have clicked
		\param touch the raw coordinates from the mouse event
	*/
	void setCalibrationPoint(Point point, QPoint screen, QPoint touch);

	/*!
		\brief Apply the calibration

		Before applying the calibration, the function performs a simple sanity check
		of the coordinates.
	*/
	bool applyCalibration();

	/*!
		\brief Restores the calibration saved by \ref startCalibration()
	*/
	void resetCalibration();

	/*!
		\brief Deletes the backup file created by \ref startCalibration()
	*/
	void saveCalibration();

signals:
	void rawMousePress(int x, int y);

protected:
	bool eventFilter(QObject *obj, QEvent *evt);

private slots:
	void grabDeclarativeViewMouse();

private:
	bool sanityCheck();

	QString pointercal_file;
	QWSPointerCalibrationData calibration_data;
};

#endif // CALIBRATION_H
