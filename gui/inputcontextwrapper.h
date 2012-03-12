#ifndef INPUTCONTEXTWRAPPER_H
#define INPUTCONTEXTWRAPPER_H

#include <QObject>
#include <QRect>

class QInputContext;


// simple input context wrapper, required because QInputContext does not exposes
// methods/properties to QML
class InputContextWrapper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QInputContext *inputContext READ inputContext CONSTANT)
	Q_PROPERTY(QRect cursorRect READ cursorRect NOTIFY cursorRectChanged)

public:
	explicit InputContextWrapper(QObject *parent = 0);

	QInputContext *inputContext() const;
	QRect cursorRect() const;

signals:
	void cursorRectChanged();

private:
	QRect currentCursorRect;
};

#endif // INPUTCONTEXTWRAPPER_H
