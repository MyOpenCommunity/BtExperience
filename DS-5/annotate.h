#ifndef _ANNOTATE_
#define _ANNOTATE_

#include <stdio.h>
extern FILE *annotate;
extern int color;

#define ANNOTATE_DEFINE FILE *annotate; int color;
#define ANNOTATE_SETUP { annotate = fopen("/dev/gator/annotate", "wb"); \
if (annotate) {setvbuf(annotate, (char *)NULL, _IONBF, 0); }}
#define ANNOTATE(...) { if (annotate) {fprintf(annotate, __VA_ARGS__); \
fputc('\0', annotate); }}
#define ANNOTATE_COLOR(setColor, ...) { if (annotate) {color = setColor; \
fwrite((char*)&color, 1, sizeof(color), annotate); \
fprintf(annotate, __VA_ARGS__); \
fputc('\0', annotate); }}

// ESC character, hex RGB (little endian)

int ANNOTATE_RED = 0x0000ff1b;
int ANNOTATE_BLUE = 0xff00001b;
int ANNOTATE_GREEN = 0x00ff001b;
int ANNOTATE_PURPLE = 0xff00ff1b;
int ANNOTATE_YELLOW = 0x00ffff1b;
int ANNOTATE_CYAN = 0xffff001b;

int ANNOTATE_WHITE = 0xffffff1b;
int ANNOTATE_LTGRAY = 0xbbbbbb1b;
int ANNOTATE_DKGRAY = 0x5555551b;
int ANNOTATE_BLACK = 0x0000001b;

#endif // _ANNOTATE_
