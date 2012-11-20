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

	// transforms an extension to a pattern (es. "wav" -> "*.[wW][aA][vV]")
	void addFilters(QStringList &filters, const char **extensions, int size)
	{
		for (int i = 0; extensions[i] != 0; ++i)
		{
			QString pattern = "*.";

			for (const char *c = extensions[i]; *c; ++c)
			{
				QChar letter(*c);
				pattern += QString("[%1%2]").arg(letter).arg(letter.toUpper());
			}
			filters.append(pattern);
		}
	}
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

QStringList getFileFilter(EntryInfo::Type type)
{
	QStringList filters;
	const char **files = 0;

	switch (type)
	{
	case EntryInfo::UNKNOWN:
	case EntryInfo::DIRECTORY:
		break;
	case EntryInfo::AUDIO:
		files = audio_files;
		break;
	case EntryInfo::VIDEO:
		files = video_files;
		break;
	case EntryInfo::IMAGE:
		files = image_files;
		break;
#ifdef BUILD_EXAMPLES
	case EntryInfo::PDF:
		files = pdf_files;
		break;
#endif
	default:
		Q_ASSERT_X(false, "getFileFilter", qPrintable(QString("type %1 not handled").arg(type)));
	}

	if (files)
		addFilters(filters, files, ARRAY_SIZE(files));

	return filters;
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
	qDebug() << "Executing:" << program << args.join(" ");
	return QProcess::execute(program, args);
#endif
}

bool silentExecute(const QString &program, QStringList args)
{
	args << "> /dev/null" << "2>&1";
	return smartExecute(program, args);
}
