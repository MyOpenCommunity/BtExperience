#ifndef APPLICATIONCOMMON_H
#define APPLICATIONCOMMON_H

#include <QObject>

class GlobalPropertiesCommon;
class QmlApplicationViewer;
class QGraphicsScene;


// Manage the boot (or reboot) of the gui part
class ApplicationCommon : public QObject
{
	Q_OBJECT

public:
	ApplicationCommon();
	~ApplicationCommon();

	void initialize();
	void start(GlobalPropertiesCommon *g, QString qml_file);

public slots:
	void handleSignal(int signal_number);

private:
	void addMaliitSurfaces(QGraphicsScene *scene, QWidget *root);

	QmlApplicationViewer *viewer;
	GlobalPropertiesCommon *global;
};

#endif // APPLICATIONCOMMON_H
