#ifndef RINGTONEMANAGER_H
#define RINGTONEMANAGER_H

#include <QObject>
#include <QHash>

#include "vct.h"

class MultiMediaPlayer;
class AudioState;


class RingtoneManager : public QObject
{
	Q_OBJECT

	Q_ENUMS(Ringtone)

public:
	enum Ringtone
	{
		Alarm,
		Message,
		// VCT
		CCTVExternalPlace1 = CCTV::ExternalPlace1,
		CCTVExternalPlace2 = CCTV::ExternalPlace2,
		CCTVExternalPlace3 = CCTV::ExternalPlace3,
		CCTVExternalPlace4 = CCTV::ExternalPlace4,
		// Intercom
		InternalIntercom = Intercom::Internal,
		ExternalIntercom = Intercom::External,
		IntercomFloorcall = Intercom::Floorcall
	};

	RingtoneManager(QString ringtone_file, MultiMediaPlayer *player, AudioState *audio_state, QObject *parent);

	Q_INVOKABLE void playRingtone(QString path, int audio_state);
	Q_INVOKABLE void playRingtoneAndKeepState(QString path, int audio_state);
	Q_INVOKABLE void stopRingtone();

	Q_INVOKABLE QString ringtoneFromIndex(int index) const;
	Q_INVOKABLE QString ringtoneFromType(Ringtone type) const;

	Q_INVOKABLE void setRingtone(Ringtone type, int index, QString description);

	MultiMediaPlayer *getMediaPlayer() const;

signals:
	void ringtoneFinished();
	void ringtoneChanged(int type, int index, QString description);

private slots:
	void playerStateChange();
	void playRingtone();

private:
	QHash<int, QString> ringtone_to_file;
	QHash<Ringtone, int> type_to_ringtone;
	QHash<Ringtone, QString> type_to_description;


	bool exit_state;
	int state;
	QString ringtone, description;
	MultiMediaPlayer *player;
	AudioState *audio_state;
};

#endif // RINGTONEMANAGER_H
