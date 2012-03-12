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


// Process the mouse events to recognize if the gui is in idle
// See the comment on main.cpp
class LastClickTime : public QObject
{
	Q_OBJECT
public:
	static bool isPressed() { return pressed; }

signals:
	void updateTime();

protected:
	bool eventFilter(QObject *obj, QEvent *ev);


private:
	static bool pressed;
};



#endif // EVENTFILTERS_H
