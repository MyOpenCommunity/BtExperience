#include "inputcontextwrapper.h"

#include <QApplication>
#include <QInputContext>
#include <QtDeclarative>

InputContextWrapper::InputContextWrapper(QObject *parent) :
	QObject(parent)
{
	qmlRegisterType<QInputContext>();
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
