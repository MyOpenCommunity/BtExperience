#include "inputcontextwrapper.h"

#include <QApplication>
#include <QInputContext>


InputContextWrapper::InputContextWrapper(QObject *parent) :
	QObject(parent)
{
}

QInputContext *InputContextWrapper::inputContext() const
{
	return qApp->inputContext();
}

QRect InputContextWrapper::cursorRect() const
{
	if (!inputContext()->focusWidget())
		return QRect();

	return inputContext()->focusWidget()->inputMethodQuery(Qt::ImMicroFocus).toRect();
}
