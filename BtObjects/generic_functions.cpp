#include "generic_functions.h"

#include <QProcess>
#include <QTime>

#include <QtDebug>


namespace
{
	#define ARRAY_SIZE(x) int(sizeof(x) / sizeof((x)[0]))
	const char *audio_files[] = {"m3u", "mp3", "wav", "ogg", "wma", 0};
	const char *video_files[] = {"mpg", "avi", "mp4", 0};
	const char *image_files[] = {"png", "gif", "jpg", "jpeg", 0};
}


EntryInfo::EntryInfo(const QString &_name, EntryInfo::Type _type, const QString &_path, const EntryInfo::Metadata &_metadata)
	: name(_name), type(_type), path(_path), metadata(_metadata)
{
	is_null = false;
}

EntryInfo::EntryInfo()
{
	is_null = true;
}

bool EntryInfo::isNull()
{
	return is_null;
}


QStringList getFileExtensions(EntryInfo::Type type)
{
	QStringList exts;
	const char **files = 0;

	switch (type)
	{
	case EntryInfo::AUDIO:
		files = audio_files;
		break;
	case EntryInfo::VIDEO:
		files = video_files;
		break;
	case EntryInfo::IMAGE:
		files = image_files;
		break;
	case EntryInfo::UNKNOWN:
	case EntryInfo::DIRECTORY:
		break;
	default:
		Q_ASSERT_X(false, "getFileExtensions", qPrintable(QString("type %1 not handled").arg(type)));
	}

	if (files)
	{
		for (int i = 0; files[i] != 0; ++i)
			exts.append(files[i]);
	}

	return exts;
}


bool smartExecute(const QString &program, QStringList args)
{
#if DEBUG
	QTime t;
	t.start();
	bool ret = QProcess::execute(program, args);
	qDebug() << "Executed:" << program << args.join(" ") << "in:" << t.elapsed() << "ms";
	return ret;
#else
	return QProcess::execute(program, args);
#endif
}

bool silentExecute(const QString &program, QStringList args)
{
	args << "> /dev/null" << "2>&1";
	return smartExecute(program, args);
}
