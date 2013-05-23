#include "paths.h"


// I need to find the top QDeclarativeView to obtain the root context;
// from the root context I will have access to the global property which
// contains paths for extra dirs
QDeclarativeView *getDeclarativeView()
{
	foreach (QWidget *w, qApp->topLevelWidgets())
		if (qobject_cast<QDeclarativeView *>(w))
			return static_cast<QDeclarativeView *>(w);

	return 0;
}

QString getPath(QString property_name)
{
	QDeclarativeView *view = getDeclarativeView();

	if (!view)
		return QString();

	// defines a property on global object to retrieve the path variant list
	QDeclarativeProperty property(qvariant_cast<QObject *>(view->rootContext()->contextProperty("global")), property_name);
	QVariantList path_list = property.read().value<QVariantList>();
	// last 2 elements are meaningless to us
	path_list.removeLast();
	path_list.removeLast();

	// reconstructs the path string skipping empty values
	QString result;
	foreach (QVariant v, path_list) {
		QString s = v.value<QString>();

		if (s.isEmpty())
			continue;

		result.append("/");
		result.append(s);
	}

	result.append("/");

	return result;
}
