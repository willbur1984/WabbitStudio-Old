#include "calc.h"

#ifdef WITH_BACKUPS
void do_backup(LPCALC lpCalc)
{
	if (!lpCalc->running)
		return;
	if (number_backup > MAX_BACKUPS)
	{
		debugger_backup* oldestBackup = backups[lpCalc->slot];
		while(oldestBackup->prev != NULL)
			oldestBackup = oldestBackup->prev;
		oldestBackup->next->prev = NULL;
		free_backup(oldestBackup);
	}
	debugger_backup *backup = (debugger_backup *) malloc(sizeof(debugger_backup));
	backup->save = SaveSlot(lpCalc);
	backup->next = NULL;
	backup->prev = backups[lpCalc->slot];
	if (backups[lpCalc->slot] != NULL)
		backups[lpCalc->slot]->next = backup;
	backups[lpCalc->slot] = backup;
	number_backup++;
}

void restore_backup(int index, LPCALC lpCalc)
{
	debugger_backup* backup = backups[lpCalc->slot];
	while (index > 0) {
		if (backup->prev == NULL)
			break;
		backup = backup->prev;
		free_backup(backup->next);
		index--;
	}
	//shouldnt happen
	if (backup != NULL)
		LoadSlot(backup->save, lpCalc);
	backups[lpCalc->slot] = backup;
}

void init_backups()
{
	int i;
	number_backup = 0;
	for(i = 0; i < MAX_CALCS; i++)
		backups[i] = NULL;
}

void free_backup(debugger_backup* backup)
{
	if (backup == NULL)
		return;
	FreeSave(backup->save);
	free(backup);
	number_backup--;
}

/*
 * Frees all backups from memory
 */
void free_backups(LPCALC lpCalc)
{
	debugger_backup *backup_prev, *backup = backups[lpCalc->slot];
	if (backup == NULL)
		return;
	do {
		backup_prev = backup->prev;
		free_backup(backup);
		backup = backup_prev;
	} while(backup != NULL);
	backups[lpCalc->slot] = NULL;
	number_backup = 0;
}

#endif
