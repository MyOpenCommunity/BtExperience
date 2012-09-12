#ifndef RINGTONEMANAGER_H
#define RINGTONEMANAGER_H

#include <QObject>
#include <QHash>

class MultiMediaPlayer;
class AudioState;


class RingtoneManager : public QObject
{
	Q_OBJECT

	Q_ENUMS(Ringtone)

public:
	enum Ringtone
	{
		Alarm
	};

	RingtoneManager(QString ringtone_file, MultiMediaPlayer *player, AudioState *audio_state, QObject *parent);

	Q_INVOKABLE void playRingtone(QString path, int audio_state);
	Q_INVOKABLE void playRingtoneAndKeepState(QString path, int audio_state);
	Q_INVOKABLE void stopRingtone();

	Q_INVOKABLE QString ringtoneFromIndex(int index) const;
	Q_INVOKABLE QString ringtoneFromType(Ringtone type) const;

	Q_INVOKABLE void setRingtone(Ringtone type, int index);

	MultiMediaPlayer *getMediaPlayer() const;

signals:
	void ringtoneFinished();

private slots:
	void playerStateChange();
	void playRingtone();

private:
	QHash<int, QString> ringtone_to_file;
	QHash<Ringtone, int> type_to_ringtone;

	bool exit_state;
	int state;
	QString ringtone;
	MultiMediaPlayer *player;
	AudioState *audio_state;
};

#endif // RINGTONEMANAGER_H
