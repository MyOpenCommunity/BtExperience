/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef EVENTFILTERS_H
#define EVENTFILTERS_H


#include <QObject>
#include <QPoint>

class QEvent;
class QWidget;


// Work around a bug with input context handling in WebKit/Maliit.  See discussion at
// - https://bugs.webkit.org/show_bug.cgi?id=60161
class InputMethodEventFilter : public QObject
{
public:
	InputMethodEventFilter();

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
	void maxTravelledDistanceOnLastMove(QPoint pos);

protected:
	bool eventFilter(QObject *obj, QEvent *ev);

private:
	static bool pressed;
};



#endif // EVENTFILTERS_H
