#ifndef DBCOMMON_H
#define DBCOMMON_H

#include "calc.h"

#include "dbreg.h"

const TCHAR * byte_to_binary(int x, BOOL isWord);
int xtoi(const TCHAR *xs);

#define Debug_UpdateWindow(hwnd) SendMessage(hwnd, WM_USER, DB_UPDATE, 0);
#define Debug_CreateWindow(hwnd) SendMessage(hwnd, WM_USER, DB_CREATE, 0);

typedef enum {
	HEX2,
	HEX4,
	FLOAT2,
	FLOAT4,
	DEC3,
	DEC5,
	BIN8,
	BIN16,
	CHAR1,
} VALUE_FORMAT;

typedef enum {
	HEX,
	DEC,
	BIN,
} DISPLAY_BASE;

typedef enum {
	REGULAR,			//view paged memory
	FLASH,				//view all flash pages
	RAM,				//view all ram pages
} ViewType;

typedef struct {
	int total;
	BOOL state[32];
} ep_state;

#ifndef MACVER
static const TCHAR* DisplayTypeString = _T("Disp_Type");
#endif

#define EN_CANCEL 0x9999

#endif /* DBCOMMON_H */
