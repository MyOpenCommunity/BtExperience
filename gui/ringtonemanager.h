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

	/**
	  \brief Enters the given audio state and plays the ringtone

	  The state is automatically left when the playback is finished.
	*/
	Q_INVOKABLE void playRingtone(QString path, int audio_state);

	/**
	  \brief Enters the given audio state and plays the ringtone.

	  The state is maintained when playback is finished.
	*/
	Q_INVOKABLE void playRingtoneAndKeepState(QString path, int audio_state);

	/**
	  \brief Stop the playback of the current playing ringtone.
	*/
	Q_INVOKABLE void stopRingtone();

	Q_INVOKABLE QString ringtoneFromIndex(int index) const;
	Q_INVOKABLE QString ringtoneFromType(Ringtone type) const;
	Q_INVOKABLE QString descriptionFromType(Ringtone type) const;

	Q_INVOKABLE void setRingtone(Ringtone type, int index, QString description);
	Q_INVOKABLE void setRingtoneFromFilename(Ringtone type, QString ringtone);

	Q_INVOKABLE QStringList ringtoneList() const;

	MultiMediaPlayer *getMediaPlayer() const;

signals:
	void ringtoneFinished();
	void ringtoneChanged(int type, int index, QString description);

private slots:
	void playerStateChange();
	void playRingtone();

private:
	void exitStateIfNeeded();

	QHash<int, QString> ringtone_to_file;
	QHash<Ringtone, int> type_to_ringtone;
	QHash<Ringtone, QString> type_to_description;


	bool exit_state;
	int state;
	QString ringtone;
	MultiMediaPlayer *player;
	AudioState *audio_state;
};

#endif // RINGTONEMANAGER_H
