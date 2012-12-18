#ifndef SCREENSTATE_H
#define SCREENSTATE_H

#include <QObject>
#include <QMetaType>

class QTimer;


class ScreenState : public QObject
{
	friend class TestScreenState;

	Q_OBJECT

	Q_PROPERTY(State state READ getState NOTIFY stateChanged)

	Q_PROPERTY(int normalBrightness READ getNormalBrightness WRITE setNormalBrightness NOTIFY normalBrightnessChanged)

	/*!
		\brief Enable/disable password check

		For password check:
		- enable password check
		- in screensaver/screen off state, lock status is turned on
		- when lock is on, clicks are blocked and \ref displayPasswordCheck() emitted

		The GUI should respond to \ref displayPasswordCheck() by displaying password check screen
		and enabling \ref PasswordCheck state.

		if the user enters the correct password, call \ref unlockScreen() and hide the password check screen.
	*/
	Q_PROPERTY(bool passwordEnabled READ getPasswordEnabled WRITE setPasswordEnabled NOTIFY passwordEnabledChanged)

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

	void setNormalBrightness(int brightness);
	int getNormalBrightness() const;

	void setPasswordEnabled(bool enabled);
	bool getPasswordEnabled() const;

	Q_INVOKABLE void unlockScreen();

	Q_INVOKABLE void disableState(State state);
	Q_INVOKABLE void enableState(State state);

public slots:
	void simulateClick();

signals:
	void stateChanged(ScreenState::State old_state, ScreenState::State new_state);
	// QTBUG-27041 QML can't use enum values as signal arguments
	void stateChangedInt(int old_state, int new_state);
	void normalBrightnessChanged();
	void passwordEnabledChanged();
	void displayPasswordCheck();

protected:
	bool eventFilter(QObject *obj, QEvent *ev);

private slots:
	void startFreeze();
	void stopFreeze();
	void stopPassword();

private:
	void updateScreenState(State old_state, State new_state);
	void updateState();
	bool updatePressTime();

	QTimer *screensaver_timer;
	QTimer *freeze_timer;
	QTimer *password_timer;
	State current_state;
	int normal_brightness;
	bool states[StateCount];
	bool password_enabled, screen_locked;
};

Q_DECLARE_METATYPE(ScreenState::State)

#endif // SCREENSTATE_H
