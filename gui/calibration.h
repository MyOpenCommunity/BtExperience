/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
	bool capacitive;
	QString pointercal_file;
	QWSPointerCalibrationData calibration_data;
	QList<QPoint> raw_events;
};

#endif // CALIBRATION_H
