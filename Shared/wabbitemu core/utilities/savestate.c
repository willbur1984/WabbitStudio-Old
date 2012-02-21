#include "stdafx.h"

#include "core.h"
#include "savestate.h"
#include "lcd.h"
#include "link.h"
#include "calc.h"
//#include "stdint.h"
#include "83psehw.h"
#ifdef WINVER
#include "fileutilities.h"
#endif

extern int def(FILE *, FILE *, int);
extern int inf(FILE *, FILE *);

static BOOL cmpTags(char *str1, char *str2) {
	int i;
	for(i = 0; i < 4; i++) {
		if (str1[i] != str2[i]) return FALSE;
	}
	return TRUE;
}

static int fputi(unsigned int integer, FILE* stream) {
	int r;
	r = fputc(integer & 0xFF, stream);
	if (r == EOF) return EOF;
	r = fputc((integer >> 8) & 0xFF, stream);
	if (r == EOF) return EOF;
	r = fputc((integer >> 16) & 0xFF, stream);
	if (r == EOF) return EOF;
	r = fputc((integer >> 24) & 0xFF, stream);
	return r;
}
	
static int fgeti(FILE* stream) {
	int r;
	r  = fgetc(stream);
	r += fgetc(stream)<<8;
	r += fgetc(stream)<<16;
	r += fgetc(stream)<<24;
	return r;
}

SAVESTATE_t* CreateSave(TCHAR *author, TCHAR *comment , int model) {
	SAVESTATE_t* save = (SAVESTATE_t*) malloc(sizeof(SAVESTATE_t));
	if (!save) return NULL;

	save->version_major = CUR_MAJOR;
	save->version_minor = CUR_MINOR;
	save->version_build = CUR_BUILD;

	memset(save->author, 0, sizeof(save->author));
	memset(save->comment, 0, sizeof(save->comment));
#ifdef WINVER
#ifdef _UNICODE
	char buffer[64];
	size_t numConv;
	wcstombs_s(&numConv, save->author, author, sizeof(save->author));
	wcstombs_s(&numConv, save->comment, comment, sizeof(save->author));
#else
	StringCbCopy(save->author, sizeof(save->author), author);
	StringCbCopy(save->comment, sizeof(save->comment), comment);
#endif
#else
	strncpy(save->author, author, sizeof(save->author));
	strncpy(save->comment, comment, sizeof(save->comment));
#endif
	
	save->model = model;
	save->chunk_count = 0;
	
	u_int i;
	for(i = 0; i < NumElm(save->chunks); i++) {
		save->chunks[i] = NULL;
	}
	return save;
}

static void ClearSave(SAVESTATE_t* save) {
	int i;
	
	if (save == NULL) return;

	for(i = 0; i < save->chunk_count; i++) {
		if (save->chunks[i]) {
			if (save->chunks[i]->data) {
				free(save->chunks[i]->data);
				save->chunks[i]->data = NULL;
			}
			free(save->chunks[i]);

			save->chunks[i] = NULL;
		}
	}

}

void FreeSave(SAVESTATE_t* save) {
	ClearSave(save);
	free(save);
}

static CHUNK_t* FindChunk(SAVESTATE_t* save, char* tag) {
	int i;
	for(i = 0; i < save->chunk_count; i++) {
		if (cmpTags(save->chunks[i]->tag, tag) == TRUE) {
			save->chunks[i]->pnt = 0;
			return save->chunks[i];
		}
	}	
	return NULL;
}

static CHUNK_t* NewChunk(SAVESTATE_t* save, char* tag) {
	int chunk = save->chunk_count;

	if (FindChunk(save, tag) != NULL) {
		printf("Error: chunk '%s' already exists", tag);
		return NULL;
	}

	if (save->chunks[chunk] != NULL) {
		puts("Error new chunk was not null.");
	}
	save->chunks[chunk] = (CHUNK_t *) malloc(sizeof(CHUNK_t));
	if (!save->chunks[chunk]) {
		puts("Chunk could not be created");
		return NULL;
	}

	save->chunks[chunk]->tag[0]	= tag[0];
	save->chunks[chunk]->tag[1]	= tag[1];
	save->chunks[chunk]->tag[2]	= tag[2];
	save->chunks[chunk]->tag[3]	= tag[3];
	save->chunks[chunk]->size	= 0;
	save->chunks[chunk]->data	= NULL;
	save->chunks[chunk]->pnt	= 0;
	save->chunk_count++;
	return save->chunks[chunk];
}

static BOOL DelChunk(SAVESTATE_t *save, char *tag) {
	int i;
	for(i = 0; i < save->chunk_count; i++) {
		if (cmpTags(save->chunks[i]->tag, tag) == TRUE) {
			if (save->chunks[i]->data) free(save->chunks[i]->data);
			if (save->chunks[i]) free(save->chunks[i]);
			for(; i < (save->chunk_count - 1); i++) {
				save->chunks[i] = save->chunks[i+1];
			}
			save->chunks[i] = NULL;
			save->chunk_count--;
			return TRUE;
		}
	}	
	return FALSE;
}


static BOOL CheckPNT(CHUNK_t* chunk) {
	if (chunk->size < chunk->pnt) {
		return FALSE;
	}
	return TRUE;
}

static BOOL WriteChar(CHUNK_t* chunk, char value) {
	unsigned char * tmppnt;
	tmppnt = (unsigned char *) realloc(chunk->data, chunk->size + sizeof(char));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
	chunk->data[chunk->size] = value;
	chunk->size += sizeof(char);
	return TRUE;
}


static BOOL WriteShort(CHUNK_t* chunk, uint16_t value) {
	int i;
	unsigned char  *tmppnt;
	unsigned char  *pnt = (unsigned char *)(&value);
	tmppnt = (unsigned char *) realloc(chunk->data,chunk->size + sizeof(value));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
#ifdef __BIG_ENDIAN__
	for(i=sizeof(value)-1;i>=0;i--) {
#else
	for(i=0;i<sizeof(value);i++) {
#endif	
		chunk->data[i+chunk->size] = *pnt++;
	}
	chunk->size += sizeof(value);
	return TRUE;
}
static BOOL WriteInt(CHUNK_t* chunk, uint32_t value) {
	int i;
	unsigned char *tmppnt;
	unsigned char *pnt = (unsigned char *)(&value);
	tmppnt = (unsigned char *) realloc(chunk->data,chunk->size + sizeof(value));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
#ifdef __BIG_ENDIAN__
	for(i=sizeof(value)-1;i>=0;i--) {
#else
	for(i = 0;i < sizeof(value); i++) {
#endif
		chunk->data[i+chunk->size] = *pnt++;
	}
	chunk->size += sizeof(uint32_t);
	return TRUE;
}

static BOOL WriteLong(CHUNK_t* chunk, uint64_t value) {
	int i;
	unsigned char *tmppnt;
	unsigned char *pnt = (unsigned char *)(&value);
	tmppnt = (unsigned char  *) realloc(chunk->data, chunk->size + sizeof(value));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
#ifdef __BIG_ENDIAN__
	for(i=sizeof(value)-1;i>=0;i--) {
#else
	for(i = 0; i < sizeof(value); i++) {
#endif
		chunk->data[i+chunk->size] = *pnt++;
	}
	chunk->size += sizeof(value);
	return TRUE;
}

static BOOL WriteFloat(CHUNK_t* chunk, float value) {
	int i;
	unsigned char *tmppnt;
	unsigned char *pnt = (unsigned char *)(&value);
	tmppnt = (unsigned char *) realloc(chunk->data,chunk->size + sizeof(value));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
#ifdef __BIG_ENDIAN__
	for(i=sizeof(value)-1;i>=0;i--) {
#else
	for(i = 0; i < sizeof(value); i++) {
#endif
		chunk->data[i+chunk->size] = *pnt++;
	}
	chunk->size += sizeof(value);
	return TRUE;
}	
static BOOL WriteDouble(CHUNK_t* chunk, double value) {
	int i;
	unsigned char *tmppnt;
	unsigned char *pnt = (unsigned char *)(&value);
	tmppnt = (unsigned char *) realloc(chunk->data,chunk->size + sizeof(value));
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
#ifdef __BIG_ENDIAN__
	for(i=sizeof(value)-1;i>=0;i--) {
#else
	for(i = 0;i < sizeof(value); i++) {
#endif
		chunk->data[i+chunk->size] = *pnt++;
	}
	chunk->size += sizeof(value);
	return TRUE;
}

static BOOL WriteBlock(CHUNK_t* chunk, unsigned char *pnt, int length) {
	int i;
	unsigned char *tmppnt;
	tmppnt = (unsigned char *) realloc(chunk->data,chunk->size+length);
	if (tmppnt == NULL) {
		_putts(_T("Error could not realloc data"));
		return FALSE;
	}
	chunk->data = tmppnt;
	for(i = 0; i < length; i++) {
		chunk->data[i+chunk->size] = pnt[i];
	}
	chunk->size += length;
	return TRUE;
}		
	

	
static unsigned char ReadChar(CHUNK_t* chunk, BOOL *valOK) {
	unsigned char value;
	value = chunk->data[chunk->pnt];
	chunk->pnt += sizeof(unsigned char);
	if (valOK) {
		*valOK = CheckPNT(chunk);
	}
	return value;
}

static unsigned short ReadShort(CHUNK_t* chunk, BOOL *valOK) {
	int i;
	uint16_t value;
	unsigned char *pnt = (unsigned char *)(&value);
#ifdef __BIG_ENDIAN__
	for(i = sizeof(value) - 1; i >= 0; i--) {
#else
	for(i = 0;i < sizeof(value); i++) {
#endif
		*pnt++ = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += sizeof(value);
	if (valOK) {
		*valOK = CheckPNT(chunk);
	}
	return value;
}

static unsigned int ReadInt(CHUNK_t* chunk, BOOL *valOK) {
	int i;
	uint32_t value;
	unsigned char *pnt = (unsigned char *)(&value);
#ifdef __BIG_ENDIAN__
	for(i = sizeof(value) - 1; i >= 0; i--) {
#else
	for(i = 0; i < sizeof(value); i++) {
#endif
		*pnt++ = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += sizeof(value);
	if (valOK) {
		*valOK = CheckPNT(chunk);
	}
	return value;
}

static float ReadFloat(CHUNK_t* chunk) {
	int i;
	float value;
	unsigned char *pnt = (unsigned char *)(&value);
#ifdef __BIG_ENDIAN__
	for(i=sizeof(float)-1;i>=0;i--) {
#else
	for(i = 0; i < sizeof(float); i++) {
#endif
		*pnt++ = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += sizeof(float);
	CheckPNT(chunk);
	return value;
}


static double ReadDouble(CHUNK_t* chunk) {
	int i;
	double value;
	unsigned char *pnt = (unsigned char *)(&value);
#ifdef __BIG_ENDIAN__
	for(i=sizeof(double)-1;i>=0;i--) {
#else
	for(i = 0; i < sizeof(double); i++) {
#endif
		*pnt++ = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += sizeof(double);
	CheckPNT(chunk);
	return value;
}

static uint64_t ReadLong(CHUNK_t* chunk)
{
	int i;
	uint64_t value;
	unsigned char *pnt = (unsigned char *)(&value);
#ifdef __BIG_ENDIAN__
	for(i = sizeof(value) - 1; i >= 0; i--) {
#else
	for(i = 0;i < sizeof(value); i++) {
#endif
		*pnt++ = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += sizeof(value);
	CheckPNT(chunk);
	return value;
}

static void ReadBlock(CHUNK_t* chunk, unsigned char *pnt, int length) {
	int i;
	for(i = 0; i < length; i++) {
		pnt[i] = chunk->data[i+chunk->pnt];
	}
	chunk->pnt += length;
	CheckPNT(chunk);
}


static void SaveCPU(SAVESTATE_t* save, CPU_t* cpu) {
	int i;
	if (!cpu) return;
	CHUNK_t* chunk = NewChunk(save,CPU_tag);
	
	WriteChar(chunk, cpu->a);
	WriteChar(chunk, cpu->f);
	WriteChar(chunk, cpu->b);
	WriteChar(chunk, cpu->c);
	WriteChar(chunk, cpu->d);
	WriteChar(chunk, cpu->e);
	WriteChar(chunk, cpu->h);
	WriteChar(chunk, cpu->l);
	
	WriteChar(chunk, cpu->ap);
	WriteChar(chunk, cpu->fp);
	WriteChar(chunk, cpu->bp);
	WriteChar(chunk, cpu->cp);
	WriteChar(chunk, cpu->dp);
	WriteChar(chunk, cpu->ep);
	WriteChar(chunk, cpu->hp);
	WriteChar(chunk, cpu->lp);
	
	WriteChar(chunk, cpu->ixl);
	WriteChar(chunk, cpu->ixh);
	WriteChar(chunk, cpu->iyl);
	WriteChar(chunk, cpu->iyh);

	WriteShort(chunk, cpu->pc);
	WriteShort(chunk, cpu->sp);

	WriteChar(chunk, cpu->i);
	WriteChar(chunk, cpu->r);
	WriteChar(chunk, cpu->bus);
	
	WriteInt(chunk, cpu->imode);

	WriteInt(chunk, cpu->interrupt);
	WriteInt(chunk, cpu->ei_block);
	WriteInt(chunk, cpu->iff1);
	WriteInt(chunk, cpu->iff2);
	WriteInt(chunk, cpu->halt);
	
	WriteInt(chunk, cpu->read);
	WriteInt(chunk, cpu->write);
	WriteInt(chunk, cpu->output);
	WriteInt(chunk, cpu->input);
	WriteInt(chunk, cpu->prefix);

	
	/* pio */
	for(i = 0; i < 256; i++) {
		interrupt_t *val = &cpu->pio.interrupt[i];
		WriteInt(chunk, val->interrupt_val);
		WriteInt(chunk, val->skip_factor);
		WriteInt(chunk, val->skip_count);
	}
}
	
static void SaveMEM(SAVESTATE_t* save, memc* mem) {
	int i;
	if (!mem) return;
	CHUNK_t *chunk = NewChunk(save, MEM_tag);

	WriteInt(chunk, mem->flash_size);
	WriteInt(chunk, mem->flash_pages);
	WriteInt(chunk, mem->ram_size);
	WriteInt(chunk, mem->ram_pages);
	WriteInt(chunk, mem->step);
	WriteChar(chunk, mem->cmd);
	
	WriteInt(chunk, mem->boot_mapped);
	WriteInt(chunk, mem->flash_locked);
	WriteInt(chunk, mem->flash_version);	

	for(i = 0; i < 5; i++) {
		WriteInt(chunk, mem->normal_banks[i].page);
		WriteInt(chunk, mem->normal_banks[i].read_only);
		WriteInt(chunk, mem->normal_banks[i].ram);
		WriteInt(chunk, mem->normal_banks[i].no_exec);
	}
	
	WriteInt(chunk, mem->read_OP_flash_tstates);
	WriteInt(chunk, mem->read_NOP_flash_tstates);
	WriteInt(chunk, mem->write_flash_tstates);
	WriteInt(chunk, mem->read_OP_ram_tstates);
	WriteInt(chunk, mem->read_NOP_ram_tstates);
	WriteInt(chunk, mem->write_ram_tstates);
	
	WriteInt(chunk, mem->flash_upper);
	WriteInt(chunk, mem->flash_lower);

	chunk = NewChunk(save, ROM_tag);
	WriteBlock(chunk, mem->flash, mem->flash_size);

	chunk = NewChunk(save, RAM_tag);
	WriteBlock(chunk, mem->ram, mem->ram_size);
	
	chunk = NewChunk(save, REMAP_tag);
	WriteInt(chunk, mem->port27_remap_count);
	WriteInt(chunk, mem->port28_remap_count);

	chunk = NewChunk(save, RAM_LIMIT_tag);
	WriteInt(chunk, mem->ram_upper);
	WriteInt(chunk, mem->ram_lower);

	int count = 0;
	chunk = NewChunk(save, FLASH_BREAKS_tag);
	for (int i = 0; i < mem->flash_size; i++)
	{
		if (mem->flash_break[i])
		{
			count++;
			WriteInt(chunk, i);
			WriteInt(chunk, mem->flash_break[i]);
		}
	}
	chunk = NewChunk(save, NUM_FLASH_BREAKS_tag);
	WriteInt(chunk, count);

	count = 0;
	chunk = NewChunk(save, RAM_BREAKS_tag);
	for (int i = 0; i < mem->ram_size; i++)
	{
		if (mem->ram_break[i])
		{
			count++;
			WriteInt(chunk, i);
			WriteInt(chunk, mem->ram_break[i]);
		}
	}
	chunk = NewChunk(save, NUM_RAM_BREAKS_tag);
	WriteInt(chunk, count);
}

static void SaveTIMER(SAVESTATE_t *save, timerc *time) {
	if (!time) return;
	CHUNK_t* chunk = NewChunk(save,TIMER_tag);
	WriteLong(chunk, time->tstates);
	WriteLong(chunk, time->freq);
	WriteDouble(chunk, tc_elapsed(time));
	WriteDouble(chunk, time->lasttime);
}

static void SaveLINK(SAVESTATE_t* save, link_t* link) {
	CHUNK_t* chunk = NewChunk(save, LINK_tag);
	WriteChar(chunk, link->host);
}

static void SaveSTDINT(SAVESTATE_t* save, STDINT_t *stdint) {
	int i;
	if (!stdint) return;
	CHUNK_t* chunk = NewChunk(save, STDINT_tag);
	WriteChar(chunk, stdint->intactive);

	WriteDouble(chunk, stdint->lastchk1);
	WriteDouble(chunk, stdint->timermax1);
	WriteDouble(chunk, stdint->lastchk2);
	WriteDouble(chunk, stdint->timermax2);
	for(i = 0; i < 4; i++) {
		WriteDouble(chunk, stdint->freq[i]);
	}
	WriteInt(chunk, stdint->mem);
	WriteInt(chunk, stdint->xy);
}

static void SaveSE_AUX(SAVESTATE_t* save, SE_AUX_t *se_aux) {
	int i;
	if (!se_aux) return;
	CHUNK_t* chunk = NewChunk(save, SE_AUX_tag);
	
	if (save->model > TI_83P) {
		WriteChar(chunk, se_aux->clock.enable);
		WriteInt(chunk, (uint32_t)se_aux->clock.set);
		WriteInt(chunk, (uint32_t)se_aux->clock.base);
		WriteDouble(chunk, se_aux->clock.lasttime);
	
		for(i = 0; i < 7; i++) {
			WriteChar(chunk, se_aux->delay.reg[i]);
		}
	
		for(i = 0; i < 6; i++) {
			WriteInt(chunk, se_aux->md5.reg[i]);
		}
		WriteChar(chunk, se_aux->md5.s);
		WriteChar(chunk, se_aux->md5.mode);
	}
	
	
	WriteChar(chunk, se_aux->linka.link_enable);
	WriteChar(chunk, se_aux->linka.in);
	WriteChar(chunk, se_aux->linka.out);
	WriteChar(chunk, se_aux->linka.working);
	WriteInt(chunk, se_aux->linka.receiving);
	WriteInt(chunk, se_aux->linka.read);
	WriteInt(chunk, se_aux->linka.ready);
	WriteInt(chunk, se_aux->linka.error);
	WriteInt(chunk, se_aux->linka.sending);
	WriteDouble(chunk, se_aux->linka.last_access);
	WriteInt(chunk, se_aux->linka.bit);

	if (save->model < TI_83PSE)
		return;
	
	WriteDouble(chunk, se_aux->xtal.lastTime);
	WriteLong(chunk, se_aux->xtal.ticks);
	for(i = 0; i < 3; i++) {
		WriteLong(chunk, se_aux->xtal.timers[i].lastTstates);
		WriteDouble(chunk, se_aux->xtal.timers[i].lastTicks);
		WriteDouble(chunk, se_aux->xtal.timers[i].divsor);
		WriteInt(chunk, se_aux->xtal.timers[i].loop);
		WriteInt(chunk, se_aux->xtal.timers[i].interrupt);
		WriteInt(chunk, se_aux->xtal.timers[i].underflow);
		WriteInt(chunk, se_aux->xtal.timers[i].generate);
		WriteInt(chunk, se_aux->xtal.timers[i].active);
		WriteChar(chunk, se_aux->xtal.timers[i].clock);
		WriteChar(chunk, se_aux->xtal.timers[i].count);
		WriteChar(chunk, se_aux->xtal.timers[i].max);
	}
	WriteInt(chunk, se_aux->model_bits);
	chunk = NewChunk(save, USB_tag);
	WriteInt(chunk, se_aux->usb.USBLineState);
	WriteInt(chunk, se_aux->usb.USBEvents);
	WriteInt(chunk, se_aux->usb.USBEventMask);
	WriteInt(chunk, se_aux->usb.LineInterrupt);
	WriteInt(chunk, se_aux->usb.ProtocolInterrupt);
	WriteInt(chunk, se_aux->usb.ProtocolInterruptEnabled);
	WriteInt(chunk, se_aux->usb.DevAddress);
	WriteChar(chunk, se_aux->usb.Port4A);
	WriteChar(chunk, se_aux->usb.Port4C);
	WriteChar(chunk, se_aux->usb.Port54);
}

static void SaveLCD(SAVESTATE_t* save, LCD_t* lcd) {
	if (!lcd) return;
	CHUNK_t* chunk = NewChunk(save, LCD_tag);

	WriteInt(chunk, lcd->active);
	WriteInt(chunk, lcd->word_len);
	WriteInt(chunk, lcd->x);
	WriteInt(chunk, lcd->y);
	WriteInt(chunk, lcd->z);
	WriteInt(chunk, lcd->cursor_mode);
	WriteInt(chunk, lcd->contrast);
	WriteInt(chunk, lcd->base_level);
	WriteBlock(chunk, lcd->display, DISPLAY_SIZE);

	WriteInt(chunk, lcd->front);
	WriteBlock(chunk, (unsigned char *) lcd->queue, LCD_MAX_SHADES * DISPLAY_SIZE);
	
	WriteInt(chunk, lcd->shades);
	WriteInt(chunk, lcd->mode);
	WriteDouble(chunk, lcd->time);
	WriteDouble(chunk, lcd->ufps);
	WriteDouble(chunk, lcd->ufps_last);
	WriteDouble(chunk, lcd->lastgifframe);
	WriteDouble(chunk, lcd->write_avg);
	WriteDouble(chunk, lcd->write_last);
}

SAVESTATE_t* SaveSlot(void *lpInput) {
	LPCALC lpCalc = (LPCALC) lpInput;
	SAVESTATE_t* save;
	BOOL runsave;
	if (lpCalc->active == FALSE) return NULL;

	runsave = lpCalc->running;
	lpCalc->running = FALSE;
	
	save = CreateSave(_T("Revsoft"), _T("Test save"), lpCalc->model);

	SaveCPU(save, &lpCalc->cpu);
	SaveMEM(save, &lpCalc->mem_c);
	SaveTIMER(save, &lpCalc->timer_c);
	SaveLCD(save, lpCalc->cpu.pio.lcd);
	SaveLINK(save, lpCalc->cpu.pio.link);
	SaveSTDINT(save, lpCalc->cpu.pio.stdint);
	SaveSE_AUX(save, lpCalc->cpu.pio.se_aux);

	lpCalc->running = runsave;
	return save;
}

static void LoadCPU(SAVESTATE_t* save, CPU_t* cpu) {
	CHUNK_t* chunk = FindChunk(save, CPU_tag);
	chunk->pnt = 0;
	
	cpu->a = ReadChar(chunk, NULL);
	cpu->f = ReadChar(chunk, NULL);
	cpu->b = ReadChar(chunk, NULL);
	cpu->c = ReadChar(chunk, NULL);
	cpu->d = ReadChar(chunk, NULL);
	cpu->e = ReadChar(chunk, NULL);
	cpu->h = ReadChar(chunk, NULL);
	cpu->l = ReadChar(chunk, NULL);
	
	cpu->ap = ReadChar(chunk, NULL);
	cpu->fp = ReadChar(chunk, NULL);
	cpu->bp = ReadChar(chunk, NULL);
	cpu->cp = ReadChar(chunk, NULL);
	cpu->dp = ReadChar(chunk, NULL);
	cpu->ep = ReadChar(chunk, NULL);
	cpu->hp = ReadChar(chunk, NULL);
	cpu->lp = ReadChar(chunk, NULL);

	cpu->ixl = ReadChar(chunk, NULL);
	cpu->ixh = ReadChar(chunk, NULL);
	cpu->iyl = ReadChar(chunk, NULL);
	cpu->iyh = ReadChar(chunk, NULL);
	
	cpu->pc = ReadShort(chunk, NULL);
	cpu->sp = ReadShort(chunk, NULL);

	cpu->i = ReadChar(chunk, NULL);
	cpu->r = ReadChar(chunk, NULL);
	cpu->bus = ReadChar(chunk, NULL);

	cpu->imode = ReadInt(chunk, NULL);

	cpu->interrupt = ReadInt(chunk, NULL);
	cpu->ei_block = ReadInt(chunk, NULL);
	cpu->iff1 = ReadInt(chunk, NULL);
	cpu->iff2 = ReadInt(chunk, NULL);
	cpu->halt = ReadInt(chunk, NULL);
	
	cpu->read = ReadInt(chunk, NULL);
	cpu->write = ReadInt(chunk, NULL);
	cpu->output = ReadInt(chunk, NULL);
	cpu->input = ReadInt(chunk, NULL);
	
	cpu->prefix = ReadInt(chunk, NULL);
	int i;
	for(i = 0; i < 256; i++) {
		interrupt_t *val = &cpu->pio.interrupt[i];
		val->interrupt_val = ReadInt(chunk, NULL);
		val->skip_factor = ReadInt(chunk, NULL);
		val->skip_count = ReadInt(chunk, NULL);
	}
	
}



static void LoadMEM(SAVESTATE_t* save, memc* mem) {
	int i;
	CHUNK_t* chunk = FindChunk(save, MEM_tag);
	chunk->pnt = 0;

	mem->flash_size	= ReadInt(chunk, NULL);
	mem->flash_pages= ReadInt(chunk, NULL);
	mem->ram_size	= ReadInt(chunk, NULL);
	mem->ram_pages	= ReadInt(chunk, NULL);
	mem->step		= ReadInt(chunk, NULL);
	mem->cmd		= ReadChar(chunk, NULL);
	mem->boot_mapped= ReadInt(chunk, NULL);
	mem->flash_locked= ReadInt(chunk, NULL);
	mem->flash_version = ReadInt(chunk, NULL);
	
	for(i = 0; i < 5; i++) {
		mem->normal_banks[i].page		= ReadInt(chunk, NULL);
		mem->normal_banks[i].read_only	= ReadInt(chunk, NULL);
		mem->normal_banks[i].ram		= ReadInt(chunk, NULL);
		mem->normal_banks[i].no_exec	= ReadInt(chunk, NULL);
		if (mem->normal_banks[i].ram) {
			mem->normal_banks[i].addr = mem->ram+(mem->normal_banks[i].page*PAGE_SIZE);
		} else {
			mem->normal_banks[i].addr = mem->flash+(mem->normal_banks[i].page*PAGE_SIZE);
		}
	}
	if (mem->boot_mapped) {
		update_bootmap_pages(mem);
		mem->banks = mem->bootmap_banks;
	} else
		mem->banks = mem->normal_banks;
	
	mem->read_OP_flash_tstates	= ReadInt(chunk, NULL);
	mem->read_NOP_flash_tstates	= ReadInt(chunk, NULL);
	mem->write_flash_tstates	= ReadInt(chunk, NULL);
	mem->read_OP_ram_tstates	= ReadInt(chunk, NULL);
	mem->read_NOP_ram_tstates	= ReadInt(chunk, NULL);
	mem->write_ram_tstates		= ReadInt(chunk, NULL);

	mem->flash_upper = ReadInt(chunk, NULL);
	mem->flash_lower = ReadInt(chunk, NULL);

	chunk = FindChunk(save, ROM_tag);
	chunk->pnt = 0;
	ReadBlock(chunk, (unsigned char *)mem->flash, mem->flash_size);
	
	chunk = FindChunk(save, RAM_tag);
	chunk->pnt = 0;
	ReadBlock(chunk, (unsigned char *)mem->ram, mem->ram_size);	

	
	chunk = FindChunk(save, REMAP_tag);
	if (chunk) {
		chunk->pnt = 0;
		mem->port27_remap_count = ReadInt(chunk, NULL);
		mem->port28_remap_count = ReadInt(chunk, NULL);
	}
	chunk = FindChunk(save, RAM_LIMIT_tag);
	if (chunk) {
		chunk->pnt = 0;
		mem->ram_upper = ReadInt(chunk, NULL);
		mem->ram_lower = ReadInt(chunk, NULL);
	}

	chunk = FindChunk(save, NUM_FLASH_BREAKS_tag);
	if (chunk) {
		int num_flash_breaks = ReadInt(chunk, NULL);
		chunk = FindChunk(save, FLASH_BREAKS_tag);
		if (chunk) {
			for (int i = 0; i < num_flash_breaks; i++)
			{
				int addr = ReadInt(chunk, NULL);
				waddr_t waddr;
				waddr.addr = addr % PAGE_SIZE;
				waddr.page = addr / PAGE_SIZE;
				waddr.is_ram = FALSE;
				BREAK_TYPE type = (BREAK_TYPE) ReadInt(chunk, NULL);
				switch (type) {
				case MEM_READ_BREAK:
					set_mem_read_break(mem, waddr);
					break;
				case MEM_WRITE_BREAK:
					set_mem_read_break(mem, waddr);
					break;
				default:
					set_break(mem, waddr);
					break;
				}
			}
		}
	}

	chunk = FindChunk(save, NUM_RAM_BREAKS_tag);
	if (chunk) {
		int num_ram_breaks = ReadInt(chunk, NULL);
		chunk = FindChunk(save, FLASH_BREAKS_tag);
		if (chunk) {
			for (int i = 0; i < num_ram_breaks; i++)
			{
				BOOL valOk;
				int addr = ReadInt(chunk, &valOk);
				if (valOk) {
					waddr_t waddr;
					waddr.addr = addr % PAGE_SIZE;
					waddr.page = addr / PAGE_SIZE;
					waddr.is_ram = TRUE;
					BREAK_TYPE type = (BREAK_TYPE) ReadInt(chunk, NULL);
					switch (type) {
					case MEM_READ_BREAK:
						set_mem_read_break(mem, waddr);
						break;
					case MEM_WRITE_BREAK:
						set_mem_read_break(mem, waddr);
						break;
					default:
						set_break(mem, waddr);
						break;
					}
				}
			}
		}
	}
}

static void LoadTIMER(SAVESTATE_t* save, timerc* time) {
	CHUNK_t* chunk = FindChunk(save,TIMER_tag);
	chunk->pnt = 0;

	time->tstates	= ReadLong(chunk);
	time->freq		= (uint32_t) ReadLong(chunk);
	time->elapsed	= ReadDouble(chunk);
	time->lasttime	= ReadDouble(chunk);	// this isn't used.
}

void LoadLCD(SAVESTATE_t* save, LCD_t* lcd) {
	CHUNK_t* chunk = FindChunk(save,LCD_tag);
	chunk->pnt = 0;

	lcd->active		= ReadInt(chunk, NULL);
	lcd->word_len	= ReadInt(chunk, NULL);
	lcd->x			= ReadInt(chunk, NULL);
	lcd->y			= ReadInt(chunk, NULL);
	lcd->z			= ReadInt(chunk, NULL);
	lcd->cursor_mode		= (LCD_CURSOR_MODE) ReadInt(chunk, NULL);
	lcd->contrast	= ReadInt(chunk, NULL);
	lcd->base_level	= ReadInt(chunk, NULL);

	ReadBlock(chunk, lcd->display, DISPLAY_SIZE);
	lcd->front		= ReadInt(chunk, NULL);
	ReadBlock(chunk,  (unsigned char *) lcd->queue, LCD_MAX_SHADES * DISPLAY_SIZE);
	lcd->shades		= ReadInt(chunk, NULL);
	lcd->mode		= (LCD_MODE) ReadInt(chunk, NULL);
	lcd->time		= ReadDouble(chunk);
	lcd->ufps		= ReadDouble(chunk);
	lcd->ufps_last	= ReadDouble(chunk);
	lcd->lastgifframe= ReadDouble(chunk);
	lcd->write_avg	= ReadDouble(chunk);
	lcd->write_last = ReadDouble(chunk);
}



static void LoadLINK(SAVESTATE_t* save, link_t* link) {
	CHUNK_t* chunk	= FindChunk(save,LINK_tag);
	chunk->pnt = 0;

	link->host		= ReadChar(chunk, NULL);
}

static void LoadSTDINT(SAVESTATE_t* save, STDINT_t* stdint) {
	int i;
	CHUNK_t* chunk		= FindChunk(save,STDINT_tag);
	chunk->pnt = 0;

	stdint->intactive	= ReadChar(chunk, NULL);
	stdint->lastchk1	= ReadDouble(chunk);
	stdint->timermax1	= ReadDouble(chunk);
	stdint->lastchk2	= ReadDouble(chunk);
	stdint->timermax2	= ReadDouble(chunk);
	for(i = 0; i < 4; i++) {
		stdint->freq[i]	= ReadDouble(chunk);
	}
	stdint->mem			= ReadInt(chunk, NULL);
	stdint->xy			= ReadInt(chunk, NULL);
}

static void LoadSE_AUX(SAVESTATE_t* save, SE_AUX_t *se_aux) {
	int i;
	if (!se_aux) {
		return;
	}
	CHUNK_t* chunk = FindChunk(save, SE_AUX_tag);
	if (!chunk) {
		return;
	}
	
	BOOL is_83p = save->model < TI_83PSE && save->version_minor == 1;
	if (is_83p) {
		LINKASSIST_t *linka = (LINKASSIST_t *) se_aux;
		linka->link_enable	= ReadChar(chunk, NULL);
		linka->in			= ReadChar(chunk, NULL);
		linka->out			= ReadChar(chunk, NULL);
		linka->working		= ReadChar(chunk, NULL);
		linka->receiving	= ReadInt(chunk, NULL);
		linka->read			= ReadInt(chunk, NULL);
		linka->ready		= ReadInt(chunk, NULL);
		linka->error		= ReadInt(chunk, NULL);
		linka->sending		= ReadInt(chunk, NULL);
		linka->last_access	= ReadDouble(chunk);
		linka->bit			= ReadInt(chunk, NULL);
		return;
	}
	
	se_aux->clock.enable		= ReadChar(chunk, NULL);
	se_aux->clock.set			= ReadInt(chunk, NULL);
	se_aux->clock.base			= ReadInt(chunk, NULL);
	se_aux->clock.lasttime		= ReadDouble(chunk);
	
	for(i = 0; i < 7; i++) {
		se_aux->delay.reg[i]	= ReadChar(chunk, NULL);
	}
	
	for(i = 0; i < NumElm(se_aux->md5.reg); i++)
	{
		se_aux->md5.reg[i]		= ReadInt(chunk, NULL);
	}
	se_aux->md5.s				= ReadChar(chunk, NULL);
	se_aux->md5.mode			= ReadChar(chunk, NULL);
	
	se_aux->linka.link_enable	= ReadChar(chunk, NULL);
	se_aux->linka.in			= ReadChar(chunk, NULL);
	se_aux->linka.out			= ReadChar(chunk, NULL);
	se_aux->linka.working		= ReadChar(chunk, NULL);
	se_aux->linka.receiving		= ReadInt(chunk, NULL);
	se_aux->linka.read			= ReadInt(chunk, NULL);
	se_aux->linka.ready			= ReadInt(chunk, NULL);
	se_aux->linka.error			= ReadInt(chunk, NULL);
	se_aux->linka.sending		= ReadInt(chunk, NULL);
	se_aux->linka.last_access	= ReadDouble(chunk);
	se_aux->linka.bit			= ReadInt(chunk, NULL);

	se_aux->xtal.lastTime		= ReadDouble(chunk);
	se_aux->xtal.ticks			= ReadLong(chunk);

	for(i = 0; i < 3; i++) {
		se_aux->xtal.timers[i].lastTstates	= ReadLong(chunk);
		se_aux->xtal.timers[i].lastTicks	= ReadDouble(chunk);
		se_aux->xtal.timers[i].divsor		= ReadDouble(chunk);
		se_aux->xtal.timers[i].loop			= ReadInt(chunk, NULL);
		se_aux->xtal.timers[i].interrupt	= ReadInt(chunk, NULL);
		se_aux->xtal.timers[i].underflow	= ReadInt(chunk, NULL);
		se_aux->xtal.timers[i].generate		= ReadInt(chunk, NULL);
		se_aux->xtal.timers[i].active		= ReadInt(chunk, NULL);
		se_aux->xtal.timers[i].clock		= ReadChar(chunk, NULL);
		se_aux->xtal.timers[i].count		= ReadChar(chunk, NULL);
		se_aux->xtal.timers[i].max			= ReadChar(chunk, NULL);
	}
	if (save->version_minor >= 1)
		se_aux->model_bits = ReadInt(chunk, NULL);
	else
		se_aux->model_bits = save->model == TI_84P ? 0 : 1;
	chunk = FindChunk(save, USB_tag);
	if (!chunk) return;
	chunk->pnt = 0;

	se_aux->usb.USBLineState = ReadInt(chunk, NULL);
	se_aux->usb.USBEvents = ReadInt(chunk, NULL);
	se_aux->usb.USBEventMask = ReadInt(chunk, NULL);
	se_aux->usb.LineInterrupt = ReadInt(chunk, NULL);
	se_aux->usb.ProtocolInterrupt = ReadInt(chunk, NULL);
	se_aux->usb.ProtocolInterruptEnabled = ReadInt(chunk, NULL);
	se_aux->usb.DevAddress = ReadInt(chunk, NULL);
	se_aux->usb.Port4A = ReadChar(chunk, NULL);
	se_aux->usb.Port4C = ReadChar(chunk, NULL);
	se_aux->usb.Port54 = ReadChar(chunk, NULL);
}


void LoadSlot(SAVESTATE_t *save, void *lpInput) {
	BOOL runsave;
	LPCALC lpCalc = (LPCALC) lpInput;
	
	if (lpCalc->active == FALSE){
		puts("Slot was not active");
		return;
	}
	if (save == NULL) {
		puts("Save was null");
		return;
	}
	
	runsave = lpCalc->running;
	lpCalc->running = FALSE;
	
	LoadCPU(save, &lpCalc->cpu);
	LoadMEM(save, &lpCalc->mem_c);
	LoadTIMER(save, &lpCalc->timer_c);
	LoadLCD(save, lpCalc->cpu.pio.lcd);
	LoadLINK(save, lpCalc->cpu.pio.link);
	LoadSTDINT(save, lpCalc->cpu.pio.stdint);
	LoadSE_AUX(save, lpCalc->cpu.pio.se_aux);
	lpCalc->running = runsave;
}

char* GetRomOnly(SAVESTATE_t *save, int *size) {
	CHUNK_t* chunk = FindChunk(save, ROM_tag);
	*size = 0;
	if (!chunk) return NULL;
	*size = chunk->size;
	return (char *) chunk->data;
}


void WriteSave(const TCHAR *fn, SAVESTATE_t* save, int compress) {
	int i;
	FILE* ofile;
	FILE* cfile;
	TCHAR tmpfn[L_tmpnam];
	TCHAR temp_save[MAX_PATH];
	
	if (!save) {
		_putts(_T("Save was null for write"));
		return;
	}
	if (compress == 0) {
#ifdef WINVER
		_tfopen_s(&ofile, fn, _T("wb"));
#else
		ofile = fopen(fn,"wb");
#endif
	} else {
#ifdef WINVER
		tmpnam_s(tmpfn, sizeof(tmpfn));
		GetAppDataString(temp_save, sizeof(temp_save));
		StringCbCat(temp_save, sizeof(temp_save), tmpfn);
		_tfopen_s(&ofile, temp_save, _T("wb"));
#else
		tmpnam(tmpfn);
		strcpy(temp_save, getenv("appdata"));
		strcat(temp_save, tmpfn);
		ofile = fopen(temp_save,"wb");
#endif
	}
		
	if (!ofile) {
		_putts(_T("Could not open save file for write"));
		return;
	}

	fputs(DETECT_STR, ofile);

	fputi(SAVE_HEADERSIZE, ofile);	
	
	fputi(save->version_major, ofile);
	fputi(save->version_minor, ofile);
	fputi(save->version_build, ofile);
	fputi(save->model, ofile);
	fputi(save->chunk_count, ofile);
	fwrite(save->author, 1,32, ofile);
	fwrite(save->comment, 1, 64, ofile);
	
	for(i = 0; i < save->chunk_count; i++) {
		fputc(save->chunks[i]->tag[0], ofile);
		fputc(save->chunks[i]->tag[1], ofile);
		fputc(save->chunks[i]->tag[2], ofile);
		fputc(save->chunks[i]->tag[3], ofile);
		fputi(save->chunks[i]->size,ofile);
		fwrite(save->chunks[i]->data, 1, save->chunks[i]->size, ofile);
	}
	fclose(ofile);
	
	if (compress) {
#ifdef WINVER
		_tfopen_s(&cfile, fn, _T("wb"));
#else
		cfile = fopen(fn,"wb");
#endif
		if (!cfile) {
			_putts(_T("Could not open compress file for write"));
			return;
		}
#ifdef WINVER
		_tfopen_s(&ofile, temp_save, _T("rb"));
#else
		ofile = fopen(temp_save,"rb");
#endif
		if (!ofile) {
			_putts(_T("Could not open temp file for read"));
			return;
		}
		//int error;
		fputs(DETECT_CMP_STR, cfile);
		switch(compress) {
#ifdef ZLIB_WINAPI
			case ZLIB_CMP:
				{
					fputc(ZLIB_CMP, cfile);
				
					int error = def(ofile, cfile, 9);
					break;
				}
#endif
			default:
				_putts(_T("Error bad compression format selected."));
				break;
		}
		fclose(ofile);
		fclose(cfile);
#ifdef _WINDOWS
		_tremove(temp_save);
#else
		remove(temp_save);
#endif
	}
}

SAVESTATE_t* ReadSave(FILE *ifile) {
	int i;
	int compressed = FALSE;
	int chunk_offset,chunk_count;
	char string[128];
	TCHAR tmpfn[L_tmpnam];
	TCHAR temp_save[MAX_PATH];
	SAVESTATE_t *save;
	CHUNK_t *chunk;
	FILE *tmpfile;

	fread(string, 1, 8, ifile);
	string[8] = 0;
	if (strncmp(DETECT_CMP_STR, string, 8) == 0) {
		i = fgetc(ifile);
#ifdef WINVER
		_ttmpnam_s(tmpfn);
		GetAppDataString(temp_save, sizeof(temp_save));
		StringCbCat(temp_save, sizeof(temp_save), tmpfn);
		_tfopen_s(&tmpfile, temp_save, _T("wb"));
#else
		tmpnam(tmpfn);
		strcpy(temp_save, getenv("appdata"));
		strcat(temp_save, tmpfn);
		tmpfile = fopen(temp_save,"wb");
#endif
		if (!tmpfile) {
			return NULL;
		}
		//int error;
		switch(i) {
#ifdef ZLIB_WINAPI
			case ZLIB_CMP:
				{
					int error = inf(ifile,tmpfile);
					break;
				}
#endif
			default:
				fclose(tmpfile);
#ifdef _WINDOWS
				_tremove(tmpfn);
#else
				remove(tmpfn);
#endif
				return NULL;
		}
		
		fclose(tmpfile);
#ifdef WINVER
		_tfopen_s(&ifile, temp_save, _T("rb"));	//this is not a leak, file gets closed
											// outside of this routine.
#else
		ifile = fopen(temp_save,"rb");	//this is not a leak, file gets closed
										// outside of this routine.
#endif
		if (!ifile) {
			_putts(_T("Could not open temp file for read"));
			return NULL;
		}
		compressed = TRUE;
		fread(string, 1, 8, ifile);
	}
		
	if (strncmp(DETECT_STR, string, 8) != 0){

		_putts(_T("Readsave detect string failed."));
		if (compressed == TRUE) fclose(ifile);
		return NULL;
	}		
	
	save = (SAVESTATE_t *) malloc(sizeof(SAVESTATE_t));
	if (!save) {
		_putts(_T("Save could not be allocated"));
		if (compressed == TRUE) fclose(ifile);
		return NULL;
	}

	chunk_offset = fgeti(ifile);
	
	save->version_major = fgeti(ifile);
	save->version_minor = fgeti(ifile);
	save->version_build = fgeti(ifile);


	if (save->version_major != CUR_MAJOR) {
		fclose(ifile);
		_putts(_T("Save not compatible at all, sorry\n"));
		free(save);
		return NULL;
	}

	save->model = fgeti(ifile);

	chunk_count = fgeti(ifile);
	fread(save->author,1,32,ifile);
	fread(save->comment,1,64,ifile);

	fseek(ifile, chunk_offset + 8 + 4, SEEK_SET);
	
	for(i = 0; i < 512; i++) {
		save->chunks[i] = NULL;
	}
	save->chunk_count = 0;
	for(i = 0; i < chunk_count; i++) {
		string[0]	= fgetc(ifile);
		string[1]	= fgetc(ifile);
		string[2]	= fgetc(ifile);
		string[3]	= fgetc(ifile);
		string[4]	= 0;
		chunk		= NewChunk(save,string);
		chunk->size	= fgeti(ifile);
		chunk->data	= (unsigned char *) malloc(chunk->size);
		fread(chunk->data,1,chunk->size,ifile);
	}
	if (compressed == TRUE) {
		fclose(ifile);
#ifdef _WINDOWS
		_tremove(temp_save);
#else
		remove(temp_save);
#endif
	}
/* check for read errors... */
	return save;
}
