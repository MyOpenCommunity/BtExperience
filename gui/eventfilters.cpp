#include "eventfilters.h"

#include <QInputContext>
#include <QEvent>
#include <QWidget>
#include <QApplication>


InputMethodEventFilter::InputMethodEventFilter()
{
	prevFocusWidget = 0;
}

bool InputMethodEventFilter::eventFilter(QObject *obj, QEvent *event)
{
	QInputContext *ic = qApp->inputContext();

	if (ic)
	{
		const QWidget *focused = ic->focusWidget();
		const QWidget *prevFocused = prevFocusWidget;

		// set focus widget before forwarding the event, to avoid
		// an infinite loop when the filter is installed on QApplication
		prevFocusWidget = focused;

		if (focused == 0 && prevFocused)
		{
			QEvent closeSIPEvent(QEvent::CloseSoftwareInputPanel);
			ic->filterEvent(&closeSIPEvent);
		}
		else if (prevFocused == 0 && focused)
		{
			QEvent openSIPEvent(QEvent::RequestSoftwareInputPanel);
			ic->filterEvent(&openSIPEvent);
		}
	}

	return QObject::eventFilter(obj,event);
}


namespace
{
	QPoint lastPressPosition;
	QPoint maxDifferencesOnMove;

	void updateMaxDifferences(QPoint lastPosition)
	{
		int deltaX = abs(lastPosition.x() - lastPressPosition.x());
		int deltaY = abs(lastPosition.y() - lastPressPosition.y());

		if (maxDifferencesOnMove.x() < deltaX)
			maxDifferencesOnMove.setX(deltaX);

		if (maxDifferencesOnMove.y() < deltaY)
			maxDifferencesOnMove.setY(deltaY);
	}
}

bool LastClickTime::pressed = false;

bool LastClickTime::eventFilter(QObject *obj, QEvent *ev)
{
	Q_UNUSED(obj)

	QMouseEvent *mouseEvent = static_cast<QMouseEvent *>(ev);

	// Save last click time
	if (ev->type() == QEvent::MouseButtonPress || ev->type() == QEvent::MouseButtonDblClick)
	{
		emit updateTime();
		pressed = true;
	}

	if (ev->type() == QEvent::MouseButtonPress)
	{
		lastPressPosition = mouseEvent->pos();
		maxDifferencesOnMove.setX(0);
		maxDifferencesOnMove.setY(0);
	}

	if (ev->type() == QEvent::MouseButtonRelease)
	{
		emit updateTime();
		pressed = false;
		emit maxTravelledDistanceOnLastMove(maxDifferencesOnMove);
	}

	if (ev->type() == QEvent::MouseMove)
	{
		updateMaxDifferences(mouseEvent->pos());
	}

	return false;
}

