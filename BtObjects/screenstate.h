#ifndef SCREENSTATE_H
#define SCREENSTATE_H

#include <QObject>

class QTimer;


class ScreenState : public QObject
{
	friend class TestScreenState;

	Q_OBJECT

	Q_PROPERTY(State state READ getState NOTIFY stateChanged)

	Q_ENUMS(State)

public:
	enum State
	{
		Invalid = -1,
		ScreenOff,
		Screensaver,
		Normal,
		Freeze,
		ForcedNormal,
		PasswordCheck,
		Calibration,
		// this must be last
		StateCount
	};

	ScreenState(QObject *parent = 0);
	~ScreenState();

	State getState() const;

	Q_INVOKABLE void disableState(State state);
	Q_INVOKABLE void enableState(State state);

signals:
	void stateChanged(ScreenState::State old_state, ScreenState::State new_state);

protected:
	bool eventFilter(QObject *obj, QEvent *ev);

private slots:
	void startFreeze();
	void freezeTick();

private:
	void updateScreenState(State old_state, State new_state);
	void updateState();
	bool updatePressTime();

	QTimer *screensaver_timer;
	QTimer *freeze_timer;
	State current_state;
	int freeze_tick, normal_brightness;
	bool states[StateCount];
};

#endif // SCREENSTATE_H
