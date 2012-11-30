#include "calibration.h"

#include <QFile>
#include <QScreen>
#include <QWSServer>
#include <QMouseEvent>
#include <QDeclarativeView>

#include <QtDebug>


namespace
{
	QPoint fromDevice(const QPoint &p)
	{
#if defined(Q_WS_QWS)
		return qt_screen->mapFromDevice(p, QSize(qt_screen->deviceWidth(), qt_screen->deviceHeight()));
#else
		return p;
#endif
	}

	QString pointercalFile()
	{
		QString pointercal_file = "/etc/pointercal";
		if (char *pointercal_file_env = getenv("POINTERCAL_FILE"))
			pointercal_file = QString(pointercal_file_env);
		return pointercal_file;
	}

	QDeclarativeView *findDeclarativeView()
	{
		foreach (QWidget *w, qApp->topLevelWidgets())
			if (qobject_cast<QDeclarativeView *>(w))
				return static_cast<QDeclarativeView *>(w);

		return 0;
	}
}

Calibration::Calibration(QObject *parent) : QObject(parent)
{
	pointercal_file = pointercalFile();
}

bool Calibration::exists() const
{
	return QFile::exists(pointercalFile());
}

bool Calibration::eventFilter(QObject *obj, QEvent *evt)
{
	if (evt->type() != QEvent::MouseButtonRelease)
		return false;
	QMouseEvent *mouse_event = static_cast<QMouseEvent *>(evt);

	emit rawMousePress(mouse_event->pos().x(), mouse_event->pos().y());

	return false;
}

void Calibration::startCalibration()
{
	// Backup the old calibration file
	if (QFile::exists(pointercal_file))
		system(qPrintable(QString("cp %1 %1.calibrated").arg(pointercal_file)));
#if defined(Q_WS_QWS)
	QWSServer::mouseHandler()->clearCalibration();
	findDeclarativeView()->grabMouse();
#endif
	qApp->installEventFilter(this);
}

void Calibration::setCalibrationPoint(Point point, QPoint screen, QPoint touch)
{
	// Map from device coordinates in case the screen is transformed
#if defined(Q_WS_QWS)
	QSize screenSize(qt_screen->width(), qt_screen->height());
	QPoint p = qt_screen->mapToDevice(touch, screenSize);
#else
	QPoint p = touch;
#endif
	calibration_data.screenPoints[point] = screen;
	calibration_data.devPoints[point] = p;
}

bool Calibration::applyCalibration()
{
	if (!sanityCheck())
	{
		qWarning() << "Failed calibration consistency check";
		return false;
	}

	qDebug() << "Saving calibration data";
#if defined(Q_WS_QWS)
	QWSServer::mouseHandler()->calibrate(&calibration_data);
#endif
	return true;
}

void Calibration::resetCalibration()
{
	if (QFile::exists(QString("%1.calibrated").arg(pointercal_file)))
	{
		qDebug() << "Reset calibration file";
		system(qPrintable(QString("mv %1.calibrated %1").arg(pointercal_file)));
	}
}

void Calibration::saveCalibration()
{
	if (QFile::exists(QString("%1.calibrated").arg(pointercal_file)))
	{
		qDebug() << "Removed calibration backup file";
		system(qPrintable(QString("rm %1.calibrated").arg(pointercal_file)));
	}
#if defined(Q_WS_QWS)
	findDeclarativeView()->releaseMouse();
#endif
	qApp->removeEventFilter(this);
}

bool Calibration::sanityCheck()
{
	QPoint *points = calibration_data.devPoints;

	QPoint tl = points[QWSPointerCalibrationData::TopLeft];
	QPoint tr = points[QWSPointerCalibrationData::TopRight];
	QPoint bl = points[QWSPointerCalibrationData::BottomLeft];
	QPoint br = points[QWSPointerCalibrationData::BottomRight];

//	qDebug() << "TOP LEFT:" << tl.x() << tl.y();
//	qDebug() << "TOP RIGHT:" << tr.x() << tr.y();
//	qDebug() << "BOTTOM LEFT:" << bl.x() << bl.y();
//	qDebug() << "BOTTOM RIGHT:" << br.x() << br.y();

	// Calculate the error on the x axis
	int left_error = qAbs(tl.x() - bl.x());
	int right_error = qAbs(tr.x() - br.x());

	// We use the average point on the x axis as an approximation of the screen size
	// (we haven't the screen size in raw device coordinates)
	int avg = qMax((tl.x() + bl.x()) / 2, (tr.x() + br.x()) / 2);

	if (qMax(left_error, right_error) > avg / 10)
	{
		qDebug() << "Calibration: the error on the x axis is greater than 10%";
		return false;
	}

	// Calculate the error on the y axis
	left_error = qAbs(tl.y() - tr.y());
	right_error = qAbs(br.y() - bl.y());

	// See the comment above for the meaning of avg
	avg = qMax((tl.y() + tr.y()) / 2, (br.y() + bl.y()) / 2);

	if (qMax(left_error, right_error) > avg / 10)
	{
		qDebug() << "Calibration: the error on the y axis is greater than 10%";
		return false;
	}

#if defined(BT_HARDWARE_DM3730) || defined(BT_HARDWARE_X11)
	// The x on the left (in raw device coordinates) must be smaller than
	// the x on the right
	if (tl.x() > tr.x() || bl.x() > br.x())
#else
	// The x on the left (in raw device coordinates) must be greater than
	// the x on the right
	if (tl.x() < tr.x() || bl.x() < br.x())
#endif
	{
		qDebug() << "Calibration: left and right inverted";
		return false;
	}

#if defined(BT_HARDWARE_PXA270) || defined(BT_HARDWARE_DM365) || defined(BT_HARDWARE_DM3730)
	// The y on the top (in raw device coordinates) must be greater than
	// the y on the bottom
	if (tl.y() < bl.y() || tr.y() < br.y())
#else
	// The y on the top (in raw device coordinates) must be smaller than
	// the y on the bottom
	if (tl.y() > bl.y() || tr.y() > br.y())
#endif
	{
		qDebug() << "Calibration: top and bottom inverted";
		return false;
	}

#ifdef BT_HARDWARE_PXA270
	if (qMin(qAbs(tl.x() - tr.x()), qAbs(bl.x() - br.x())) < MINUMUM_RAW_X_SIZE)
	{
		qDebug() << "Calibration: the points on the left are too close to the points on the right.";
		return false;
	}

	if (qMin(qAbs(tl.y() - bl.y()), qAbs(tr.y() - br.y())) < MINUMUM_RAW_Y_SIZE)
	{
		qDebug() << "Calibration: the points on the top are too close to the points on the bottom.";
		return false;
	}
#endif

	return true;
}
