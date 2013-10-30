#ifndef GENERIC_FUNCTIONS_H
#define GENERIC_FUNCTIONS_H

#include <QStringList>

/*!
	\ingroup Core
	\brief A wrapper around the QProcess::execute that shows the time elapsed in DEBUG mode.
	Executes the program and then waits to it for finishing before returning.
*/
bool smartExecute_synch(const QString &program, QStringList args = QStringList());

/*!
	\ingroup Core
	\brief A wrapper around the QProcess::execute that shows the time elapsed in DEBUG mode.
*/
bool smartExecute(const QString &program, QStringList args = QStringList());

/*!
	\ingroup Core
	\brief A \em silent wrapper around the QProcess::execute.
	Shows the time elapsed in DEBUG mode and appends some extra args to the process
	in order to silent its output & error messages.
*/
bool silentExecute(const QString &program, QStringList args = QStringList());


#endif // GENERIC_FUNCTIONS_H
