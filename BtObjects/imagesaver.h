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

#ifndef IMAGESAVER_H
#define IMAGESAVER_H


#include <QObject>
#include <QSize>
#include <QNetworkAccessManager>
#include <QImage>
#include <QTemporaryFile>


/**
  \ingroup Core

  \brief Maximum number of customized images per profile.

  Maximum number of customized images per type and per profile stored. Custom
  images are saved in the extra/12 folder. To avoid filling all the available
  space a limit on the number of images to retain is needed. This parameter is
  such a limit. Every time a user customizes her image a new image is created
  in the extra/12 folder. If images linked to that profile are more than this
  number, older images are deleted. It is suggested to set this parameter to
  a value of at least 2 to avoid "losing" the image in case of errors before
  the system saves the configuration (the saving is delayed).
  */
#define MAX_CUSTOMIZED_IMAGES_PROFILE 3


class QNetworkReply;


/**
  \ingroup Core

  \brief Computes the maximum id value part of file name passed in.

  When passing a file name in the form bg_uii.jpg, it looks the folder the
  file belongs to for all files following the same pattern (bg_uii_*.jpg). For
  such files it extracts the id part and computes the maximum value assuming
  the id part is an integer.

  \param no_id_name The absolute file name to use as base for the computation. It may not exist.
  \return The max id found
  */
int computeMaxId(QString no_id_name);

/**
  \ingroup Core

  \brief Computes the absolute file name.

  When passing a file name in the form bg_uii.jpg, it appends the id passed in
  to obtain the final file name (like bg_uii_7.jpg).

  \param no_id_name The absolute file name to use as base for the computation. It may not exist.
  \param id The id the file must have
  \return The file name to use to save the new file
  */
QString computeSaveFilePath(QString no_id_name, int id);

/**
  \ingroup Core

  \brief Cleans old files.

  When passing a file name in the form bg_uii_7.jpg, it looks the folder the
  file belongs to and cleans all older files. It uses the MAX_CUSTOMIZED_IMAGES_PROFILE
  parameter to decide what files to delete.

  \param id_name The absolute file name to use as base for the computation. It may not exist.
  \param id The id of the most recent file to save
  */
void cleanOldFiles(QString id_name, int id);


/**
  \ingroup Core

  \brief A class to save custom images.

  A class to save custom images. Images may be on a local folder, but they may
  reside on a remote path, too (like on a media server). The class is able to
  automatically manage if the file is local or remote.

  To use this class, create an instance and connect the jobDone signal to a
  slot. This slot is needed to call deleteLater to clean up the instance
  created above (you must be sure the instance is deleted when the download
  operation is completed). Then call the startDownload method and you are done.
  */
class ImageSaver : public QObject
{
	Q_OBJECT

public:
	explicit ImageSaver(QObject *parent = 0);

	/**
	\brief Starts a download operation

	Starts a download operation. If file is local the download is immediate.
	In case the file is remote a download operations begins and file is saved
	as soon as the download completes.

	\param object The object containing the property where to save new file name
	\param property The property where to save the new file name to
	\param download_url The url/path of file to copy in extra/12 folder
	\param save_file_path The relative file name without uii and without extension the file must have in the extra/12 folder
	\param size An optional argument in case an image rescaling to a desired size is wanted
	*/
	void startDownload(QObject *object, QString property, QString download_url, QString save_file_path, QSize size);

signals:
	/**
	Emitted when the image saving operation finishes. When signal is emitted
	all cleanings jobs are done, too.
	\param cleanee This instance in case a deleteLater operation is needed
	*/
	void jobDone(ImageSaver *cleanee);

private slots:
	void onFinished(QNetworkReply *);
	void onReadyRead();

private:
	void saveDestinationFile();

private:
	QNetworkAccessManager manager;
	QNetworkReply *reply;
	QTemporaryFile file;
	QSize size;
	QString save_file_path;
	QObject *object;
	QString property;
	QImage image_buffer;
	static unsigned int progressive_id;
};

#endif // IMAGESAVER_H
