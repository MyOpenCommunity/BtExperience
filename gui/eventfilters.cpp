#include "eventfilters.h"

#include <QInputContext>
#include <QEvent>
#include <QWidget>
#include <QApplication>


bool InputMethodEventFilter::eventFilter(QObject *obj, QEvent *event)
{
	QInputContext *ic = qApp->inputContext();

	if (ic)
	{
		const QWidget *focused = ic->focusWidget();

		if (focused == 0 && prevFocusWidget)
		{
			QEvent closeSIPEvent(QEvent::CloseSoftwareInputPanel);
			ic->filterEvent(&closeSIPEvent);
		}
		else if (prevFocusWidget == 0 && focused)
		{
			QEvent openSIPEvent(QEvent::RequestSoftwareInputPanel);
			ic->filterEvent(&openSIPEvent);
		}

		prevFocusWidget = focused;
	}

	return QObject::eventFilter(obj,event);
}



bool LastClickTime::pressed = false;

bool LastClickTime::eventFilter(QObject *obj, QEvent *ev)
{
	Q_UNUSED(obj)
	// Save last click time
	if (ev->type() == QEvent::MouseButtonPress || ev->type() == QEvent::MouseButtonDblClick)
	{
		emit updateTime();
		pressed = true;
	}

	if (ev->type() == QEvent::MouseButtonRelease)
	{
		emit updateTime();
		pressed = false;
	}

	return false;
}

