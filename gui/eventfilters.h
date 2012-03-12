#ifndef EVENTFILTERS_H
#define EVENTFILTERS_H


#include <QObject>

class QEvent;
class QWidget;


// Work around a bug with input context handling in WebKit/Maliit.  See discussion at
// - https://bugs.webkit.org/show_bug.cgi?id=60161
class InputMethodEventFilter : public QObject
{
protected:
	bool eventFilter(QObject *obj, QEvent *event);

private:
	const QWidget *prevFocusWidget;
};


#endif // EVENTFILTERS_H
