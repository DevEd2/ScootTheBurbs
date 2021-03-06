; ================================================================
; Scoot the Burbs
; ================================================================

; Debug flag
; If set to 1, enable debugging features.

DebugFlag	set	1

; ================================================================
; Project includes
; ================================================================

include	"Variables.asm"
include	"Constants.asm"
include	"Macros.asm"
include	"hardware.inc"

; ================================================================
; Reset vectors (actual ROM starts here)
; ================================================================

SECTION	"Reset $00",ROM0[$00]
Reset00:
	halt
	ldh	a,[sys_VBlankIRQ]
	and	a
	jr	z,Reset00
	xor	a
	ldh	[sys_VBlankIRQ],a
	ret

SECTION	"Reset $10",ROM0[$10]
Reset10:
	halt
	ldh	a,[sys_StatIRQ]
	and	a
	jr	z,Reset10
	xor	a
	ldh	[sys_StatIRQ],a
	ret

SECTION	"Reset $20",ROM0[$20]
Reset20:
	halt
	ldh	a,[sys_TimerIRQ]
	and	a
	jr	z,Reset20
	xor	a
	ldh	[sys_TimerIRQ],a
	ret

SECTION	"Reset $30",ROM0[$30]
Reset30:	jp	ShowError

SECTION	"Reset $38",ROM0[$38]
Reset38:	jp	ErrorHandler

; ================================================================
; Interrupt vectors
; ================================================================

SECTION	"VBlank interrupt",ROM0[$40]
IRQ_VBlank:	jp	DoVBlank

SECTION	"LCD STAT interrupt",ROM0[$48]
IRQ_STAT:	jp	DoStat

SECTION	"Timer interrupt",ROM0[$50]
IRQ_Timer:	jp	DoSample

SECTION	"Serial interrupt",ROM0[$58]
IRQ_Serial:	reti

SECTION	"Joypad interrupt",ROM0[$60]
IRQ_Joypad:	reti
	
; ================================================================
; System routines
; ================================================================

include	"SystemRoutines.asm"

; ================================================================
; ROM header
; ================================================================

SECTION	"ROM header",ROM0[$100]

EntryPoint:
	nop
	jp	ProgramStart

NintendoLogo:	; DO NOT MODIFY OR ROM WILL NOT BOOT!!!
	db	$ce,$ed,$66,$66,$cc,$0d,$00,$0b,$03,$73,$00,$83,$00,$0c,$00,$0d
	db	$00,$08,$11,$1f,$88,$89,$00,$0e,$dc,$cc,$6e,$e6,$dd,$dd,$d9,$99
	db	$bb,$bb,$67,$63,$6e,$0e,$ec,$cc,$dd,$dc,$99,$9f,$bb,$b9,$33,$3e

ROMTitle:		db	"SCOOT THE BURBS"	; ROM title (15 bytes)
GBCSupport:		db	$c0					; GBC support (0 = DMG only, $80 = DMG/GBC, $C0 = GBC only)
NewLicenseCode:	db	"DS"				; new license code (2 bytes)
SGBSupport:		db	0					; SGB support
CartType:		db	$19					; Cart type, see hardware.inc for a list of values
ROMSize:		ds	1					; ROM size (handled by post-linking tool)
RAMSize:		db	0					; RAM size
DestCode:		db	1					; Destination code (0 = Japan, 1 = All others)
OldLicenseCode:	db	$33					; Old license code (if $33, check new license code)
ROMVersion:		db	0					; ROM version
HeaderChecksum:	ds	1					; Header checksum (handled by post-linking tool)
ROMChecksum:	ds	2					; ROM checksum (2 bytes) (handled by post-linking tool)

; ================================================================
; Start of program code
; ================================================================

ProgramStart:
	di
	ld	sp,$dffe
	push	bc
	push	af
	
.wait						; wait for VBlank before disabling the LCD
	ldh	a,[rLY]
	cp	$90
	jr	nz,.wait
	xor	a
	ldh	[rLCDC],a			; disable LCD
	
	call	ClearWRAM
	call	ClearVRAM

	; clear HRAM
	ld	bc,$8080
.hramClearLoop
	ld	[c],a
	inc	c
	djnz	.hramClearLoop
	
	xor	a
	ldh	[rSCY],a
	ldh	[rSCX],a
	ldh	[rWY],a
	ldh	[rWX],a
	
	call	CopyDMARoutine
	
	pop	af
	cp	$11					; are we on GBC?
	ld	[GBCFlag],a
	jp	z,DoInit			; if we are, jump to main init routine
	CopyTileset1BPP	DebugFont,0,97
	xor	a
	ldh	[rSCX],a
	ldh	[rSCY],a
	ld	hl,.dmgTilemap
	call	LoadMapText
	
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ld	a,%10010001
	ldh	[rLCDC],a
	ld	a,%11100100
	ldh	[rBGP],a
	ei
	
.dmgwaitloop
	halt
	jr	.dmgwaitloop
	
.dmgTilemap
;		 ####################
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"- SCOOT THE BURBS - "
	db	"                    "
	db	"This game will not  "
	db	"work on this system."
	db	"                    "
	db	"Please use a Game   "
	db	"Boy Color or Game   "
	db	"Boy Advance to play "
	db	"this game.          "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
;		 ####################
	
DoInit:
	; check if we are running in a bad emulator
	ld	a,$ed				; this value isn't important
	ld	[EmuCheck],a
	ld	b,a
	ld	a,[EmuCheck+$2000]	; read back value from echo RAM (which VBA doesn't support)
	cp	b
	jp	z,NoEmu

	CopyTileset1BPP	DebugFont,0,97
	ld	hl,.emuTilemap
	call	LoadMapText
	ld	hl,Pal_Grayscale
	xor	a
	call	LoadBGPalLine	; GBC default palette
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ld	a,%10010001
	ldh	[rLCDC],a			; enable LCD
	ei
.loop
	halt
	jr	.loop
	
.emuTilemap
;		 ####################
	db	"- SCOOT THE BURBS - "
	db	"                    "	
	db	"Isn't it time you   "
	db	"ditched VBA already?"
	db	"                    "
	db	"Unfortunately, VBA  "
	db	"has a large number  "
	db	"accuracy issues, so "
	db	"we can't let you    "
	db	"play the game until "
	db	"you get a better    "
	db	"emulator. We would  "
	db	"recommend either BGB"
	db	"or Gambatte for the "
	db	"best experience if  "
	db	"you can't run this  "
	db	"ROM on a real Game  "
	db	"Boy.                "
;		 ####################
	
NoEmu:
	pop	bc
	ld	a,b
	ld	[GBAFlag],a

;	ld	a,1
;	ldh	[sys_GameMode],a
	
	ld	a,IEF_TIMER+IEF_VBLANK
	ldh	[rIE],a				; set interrupt flags
	
	xor	a
	ldh	[rTIMA],a
	ldh	[rTMA],a
	or	%00000110
	ldh	[rTAC],a			; initialize timer (for sample playback)
	
	; initialize sample pointer and bank
	ld	a,$40
	ldh	[SamplePtr+1],a
	ld	a,1
	ldh	[SampleBank],a
	
	; init sound output
	ld	c,rNR51-$ff00
	ld	a,$ff
	ld	[c],a
	dec	c
	xor	%10001000
	ld	[c],a
	ld	a,$20
	ldh	[rNR32],a


	ld	hl,Pal_White
	call	LoadBGPal
	ld	hl,Pal_White
	call	LoadObjPal
	
	call	CPUToggleSpeed
;	call	comm_not_ready
	ei
ShowDevsoftSplash:
	CopyCompressedTileset		DevSoftTiles,0
	CopyTileset	BlankTiles,$600,(BlankTiles_End-BlankTiles)/16
	
	ld	hl,DevSoftMap
	call	LoadMap
;	ld	a,$62
;	ld	hl,$9a40
;	push	hl
;	call	LoadRow
;	ld	a,1
;	ldh	[rVBK],a
;	pop	hl
;	call	LoadRow
;	xor	a
;	ldh	[rVBK],a
	
	ld	a,$62			; black tile
	call	.loadloop	; load BG map
	ld	a,1
	ldh	[rVBK],a		; set VRAM bank 1
	call	.loadloop	; load attributes
	jr	.continue		; jump ahead
	
.loadloop
	ld	d,a				; save tile/attribute ID
	ld	hl,$9c00		; window map address
	ld	bc,$800			; size of tilemap
.copyloop
	ld	[hl+],a			; copy byte
	dec	bc
	ld	a,b
	or	c
	ld	a,d				; restore tile/attribute ID
	jr	nz,.copyloop	; loop until all bytes are copied
	ret
	
.continue
	xor	a
	ldh	[rVBK],a		; set VRAM bank 0
	
	ld	a,%10010001			; LCD on + BG on + BG $8000
	ldh	[rLCDC],a			; enable LCD
	Pal_FadeToPal	Pal_Grayscale,1,8
	ld	a,1
	ld	hl,Pal_Vinesauce
	call	LoadBGPalLine

	call	ShowSplash
	
	ld	a,%11110001
	ldh	[rLCDC],a			; enable window
	ld	a,176
	ld	[WindowBasePos],a
	di
	ld	a,IEF_VBLANK+IEF_LCDC
	ldh	[rIE],a
	ld	a,%01000000
	ldh	[rSTAT],a
	xor	a
	ldh	[rLYC],a
	ld	a,1
	ld	[StatID],a
	ei
.scrollLoop
	WaitForVBlank

	ld	a,[WindowBasePos]
	dec	a
	ld	[WindowBasePos],a
	ld	a,[WindowTransitionOffset]
	inc	a
	ld	[WindowTransitionOffset],a
	ld	[WindowTransitionPos1],a
	ld	[WindowTransitionPos2],a
	ld	a,[WindowBasePos]
	cp	$e0
	jr	nz,.scrollLoop
	di
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	xor	a
	ld	[SpritesDisabled],a
	ei
	WaitForVBlank
	
;	WaitForVBlank
;	xor	a
;	ldh	[rLCDC],a
	
ShowVinesauceSplash:
	CopyTilesetSafe	VinesauceTextTiles,$1000,29
	CopyTilesetSafe	VineshroomTiles,0,2
	ld	hl,VinesauceTextMap
	call	LoadMapSafe
	di
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ei
	ld	a,80
	ldh	[rSCY],a
	ld	a,%10000111
	ldh	[rLCDC],a

	xor	a
	ld	hl,Pal_Vinesauce
	call	LoadBGPalLine
	xor	a
	ld	hl,Pal_Vineshroom
	call	LoadObjPalLine
	xor	a
	ld	[ScrollTablePos],a
	ld	a,Bank(FXHammer)
	ld	[rROMB0],a
	
.loop1
	call	FXHammer_Update
	halt
	; make logo fall
	ld	hl,VinesauceScrollTableY
	ld	a,[ScrollTablePos]
	add	l
	ld	l,a
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl]
	cp	$80
	jr	z,.endScrollIn
	ldh	[rSCY],a
	ld	a,[ScrollTablePos]
	cp	$16
	jr	nz,.noplay
	push	af
	ld	a,SFX_BigThud
	call	FXHammer_Trig
	pop	af
.noplay
	inc	a
	ld	[ScrollTablePos],a
	jr	.loop1
	
.endScrollIn
	; wait a bit before moving logo
	ld	a,45
	ld	[ScreenTimer],a
.loop2
	call	FXHammer_Update
	halt
	ld	a,[ScreenTimer]
	dec	a
	ld	[ScreenTimer],a
	and	a
	jr	nz,.loop2
	; move logo right to make room for vineshroom
	ld	a,8
	ld	[ScreenTimer],a
.loop3
	call	FXHammer_Update
	halt
	ldh	a,[rSCX]
	dec	a
	ldh	[rSCX],a
	ld	a,[ScreenTimer]
	dec	a
	ld	[ScreenTimer],a
	and	a
	jr	nz,.loop3
	
	LoadSprite	Sprite_Vineshroom,OAMBuffer,Sprite_Vineshroom_End-Sprite_Vineshroom
	
	ld	a,15
	ld	[ScreenTimer],a
.loop4
	call	FXHammer_Update
	halt
	ld	a,[ScreenTimer]
	dec	a
	ld	[ScreenTimer],a
	and	a
	jr	nz,.loop4
	xor	a
	ld	[ScrollTablePos],a
	
.loop5
	call	FXHammer_Update
	halt
	
	ld	hl,VineshroomScrollTable
	
	ld	a,[ScrollTablePos]
	add	l
	ld	l,a
	jr	nc,.nocarry2
	inc	h
.nocarry2
	ld	a,[hl]
	cp	$80
	jr	z,.endScrollIn2
	cp	80
	jr	nz,.noSFX
	push	af
	ld	a,SFX_Bounce
	call	FXHammer_Trig
	pop	af
.noSFX
	ld	[VineshroomPosY1],a
	ld	[VineshroomPosY2],a
	ld	a,[ScrollTablePos]
	inc	a
	ld	[ScrollTablePos],a
	jr	.loop5
	
.endScrollIn2
	
	
	ld	a,120
	ld	[ScreenTimer],a
.loop6
	call	FXHammer_Update
	halt
	ld	a,[ScreenTimer]
	dec	a
	ld	[ScreenTimer],a
	and	a
	jr	nz,.loop6
	
	ld	a,1
	ld	[RGBG_fade_to_color],a
	call	RGBG_SimpleFadeOut
ShowTitleScreen:
	WaitForVBlank
	xor	a
	ldh	[rLCDC],a

	CopyTileset1BPP	DebugFont,0,97
	ld	hl,TitleMap
	call	LoadMapTitle
	
	ld	a,1
	ld	[rROMB0],a
	xor	a
	ld	[FadeType],a
	call	DS_Init
	xor	a
	ldh	[rSCX],a
	ldh	[rSCY],a

	
;	Pal_FadeToPal	Pal_Grayscale,1,8
	ld	a,0
	ld	hl,Pal_Grayscale
	call	LoadBGPalLine
	ld	a,1
	ld	hl,Pal_Grayscale
	call	LoadBGPalLine
	ld	a,%11110111
	ldh	[rLCDC],a
	di
	ld	a,IEF_VBLANK;+IEF_LCDC
	ldh	[rIE],a
;	ld	a,%01000000
;	ldh	[rSTAT],a
;	ld	a,48
;	ldh	[rLYC],a
;	ld	a,2
;	ld	[StatID],a
	ei
	jr	TitleLoop
	
VinesauceScrollTableY:
	db	80,80,80,80,80,80,80,80
	db	74,68,62,56,50,44,38,32,26,20,14,8,2,0
	db	4,-4,4,-4
	db	3,-3,3,-3
	db	2,-2,2,-2
	db	1,-1,1,-1
	db	0,$80	; $80 = end
	
VineshroomScrollTable:
	db	0,6,12,18,24,30,36,42,48,54,60,66,72,78,80
	db	78,76,74,73,72,72,71,71,71,72,72,73,74,76,78
	db	80,$80	; $80 = end
	
	
Sprite_Vineshroom:
	db	0,22,0,%00000000
	db	0,30,0,%00100000
Sprite_Vineshroom_End

; ================================================================

TitleLoop::
	WaitForVBlank
	call	DS_Play
	
	call	CheckInput
	ld	a,[sys_btnPress]
	bit	btnStart,a
	jr	nz,.exitTitle
	bit	btnSelect,a
	jp	nz,InitSoundTest
	jr	TitleLoop
	
.exitTitle
	call	DS_Stop
	ld	a,Bank(FXHammer)
	ld	[rROMB0],a
	ld	a,SFX_MenuSelect
	call	FXHammer_Trig
	ld	b,30
.loop1
	push	bc
	call	FXHammer_Update
	WaitForVBlank
	pop	bc
	dec	b
	jr	nz,.loop1
	
	ld	a,1
	ld	[RGBG_fade_to_color],a
	call	RGBG_SimpleFadeOut
	WaitForVBlank
	xor	a
	ldh	[rLCDC],a

ShowCharSelect:
	di
	CopyTileset	CharSelectTiles,0,(CharSelectTiles_End-CharSelectTiles)/16
	ld	hl,CharSelectMap
	call	LoadMapFull
	ld	a,1
	ld	[SpritesDisabled],a
	ldh	[rVBK],a
	; TODO: Fix pics not fading in properly
	ld	hl,Pic_Dummy
	call	LoadPic
	
	ld	a,%10010001
	ldh	[rLCDC],a
	Pal_FadeToPal	Pal_CharSelectMain,1,8

	ld	a,3
	ld	[StatID],a
	ld	a,STATF_LYC
	ldh	[rSTAT],a
	ld	a,IEF_VBLANK+IEF_LCDC
	ldh	[rIE],a
	
	ld	a,1
	ld	[rROMB0],a
	call	DS_Init
	ei
.loop
	rst	$00
	
	xor	a
	ldh	[rLYC],a
	
	jr	.loop
	
ProcessCharSelect:
	ld	hl,rROMB0
	ld	[hl],1
	call	DS_Play
	ld	[hl],2
	call	FXHammer_Update
	
	call	CheckInput
	ld	a,[sys_btnPress]
	bit	btnA,a
	jr	nz,.select
	bit	btnB,a
	jr	nz,.back
	bit	btnStart,a
	jr	nz,.select
	bit	btnLeft,a
	jr	nz,.prev
	bit	btnRight,a
	jr	z,.continue
.next
	ld	a,SFX_MenuCursor
	call	FXHammer_Trig
	ld	hl,CharSel_CharID
	inc	[hl]
	jr	.continue
.prev
	ld	a,SFX_MenuCursor
	call	FXHammer_Trig
	ld	hl,CharSel_CharID
	dec	[hl]
	jr	.continue
.select
	ld	[hl],1		; hl should still be ROM bank select
	call	DS_Stop	; stop music
	; mute all channels to prevent notes from sustaining (why does it do this?)
	xor	a
	ldh	[rNR12],a
	ldh	[rNR22],a
	ldh	[rNR30],a
	ldh	[rNR42],a
	or	$80
	ldh	[rNR14],a
	ldh	[rNR24],a
	ldh	[rNR44],a
	ld	[hl],2
	ld	a,SFX_MenuSelect
	call	FXHammer_Trig
	ld	a,1
	ld	[DoExitCharSelect],a
	
	di
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	xor	a
	ldh	[rSCX],a
	ei
	
	ld	b,45
.loop
	push	bc
	call	FXHammer_Update
	pop	bc
	WaitForVBlank
	dec	b
	jr	nz,.loop
	di
	ld	a,IEF_TIMER+IEF_VBLANK+IEF_LCDC
	ldh	[rIE],a
	ei
	; init CH3 to prevent samples from being too quiet (isn't DS_Stop supposed to take care of this???)
	ld	a,$80
	ldh	[rNR30],a
	ld	a,%00100000
	ldh	[rNR32],a
	ld	a,[CharSel_CharID]
	and	$3
	call	PlaySample
	jr	.sampleLoop
	

.back
	ld	a,SFX_MenuBack
	call	FXHammer_Trig
.continue
	ret

.sampleLoop
	WaitForVBlank
	ld	a,[SamplePlaying]
	and	a
	jr	nz,.sampleLoop
.samplebreak
	di
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ei
	ld	a,1
	ld	[RGBG_fade_to_color],a
	call	RGBG_SimpleFadeOut
	jr	InitGame

CharacterNames:
	dw	.vinny
	dw	.joel
	dw	.thicc
	dw	.sonic
	
.vinny	str	"VINNY"
.joel	str	"JOEL"
.thicc	str	"HE THICC"
.sonic	str	"SONIC"
	
InitGame:
	WaitForVBlank
	xor	a
	ldh	[rLCDC],a
	
.loop
	halt
	jr	.loop

; ================================================================
; Graphics routines
; ================================================================

_CopyTileset:						; WARNING: Do not use while LCD is on!
	ld	a,[hl+]						; get byte
	ld	[de],a						; write byte
	inc	de
	dec	bc
	ld	a,b							; check if bc = 0
	or	c
	jr	nz,_CopyTileset				; if bc != 0, loop
	ret
	
_CopyTilesetSafe:					; same as _CopyTileset, but waits for VRAM accessibility before writing data
	ldh	a,[rSTAT]
	and	2							; check if VRAM is accessible
	jr	nz,_CopyTilesetSafe			; if it isn't, loop until it is
	ld	a,[hl+]						; get byte
	ld	[de],a						; write byte
	inc	de
	dec	bc
	ld	a,b							; check if bc = 0
	or	c
	jr	nz,_CopyTilesetSafe			; if bc != 0, loop
	ret
	
_CopyTileset1BPP:
	ld	a,[hl+]						; get byte
	ld	[de],a						; write byte
	inc	de							; increment destination address
	ld	[de],a						; write byte again
	inc	de							; increment destination address again
	dec	bc
	dec	bc							; since we're copying two bytes, we need to dec bc twice
	ld	a,b							; check if bc = 0
	or	c
	jr	nz,_CopyTileset1BPP			; if bc != 0, loop
	ret
	
_CopyTileset1BPPInvert:
	ld	a,[hl+]						; get byte
	cpl								; flip all bits
	ld	[de],a						; write byte
	inc	de							; increment destination address
	ld	[de],a						; write byte again
	inc	de							; increment destination address again
	dec	bc
	dec	bc							; since we're copying two bytes, we need to dec bc twice
	ld	a,b							; check if bc = 0
	or	c
	jr	nz,_CopyTileset1BPPInvert	; if bc != 0, loop
	ret
	
include	"FadeRoutines.asm"
	
; Pic format:
; $000 - Tileset pointer (two bytes)
; $002 - Size of tileset (two bytes)
; $004 - Palette pointer (two bytes)
; $006 - Map data (280 bytes)
; $11e - Attribute data (280 bytes)
	
LoadPic:	
	push	hl
	push	hl
	inc	hl
	inc	hl
	ld	a,[hl+]
	ld	b,[hl]
	ld	c,a
	ld	de,$8000
	pop	hl
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	call	_CopyTilesetSafe
	
	pop	hl
	ld	a,l
	add	4
	ld	l,a
	jr	nc,.nocarry
	inc	h
.nocarry
	push	hl
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	call	LoadPalPic
	
	pop	hl
	ld	a,l
	inc	hl
	inc	hl
	xor	a
	ldh	[rVBK],a
	call	LoadMapPic
	ld	a,1
	ldh	[rVBK],a
	call	LoadMapPic
	xor	a
	ldh	[rVBK],a
	ret

LoadMapPic:
	ld	de,$9840
	ld	bc,$0e14
.loop
	ldh	a,[rSTAT]
	and	2
	jr	nz,.loop
	ld	a,[hl+]						; get tile ID
	ld	[de],a						; copy to BG map
	inc	de							; go to next tile
	dec	c
	jr	nz,.loop			; loop until current row has been completely copied
	ld	c,$14						; reset C
	ld	a,e
	add	$c							; go to next row
	jr	nc,.continue				; if carry isn't set, continue
	inc	d
.continue
	ld	e,a
	dec	b
	jr	nz,.loop			; loop until all rows have been copied
	ret

	
; temp routine
LoadMapTitle:
	ld	de,_SCRN1
	ld	bc,$614
	jp	LoadMapText_loop

LoadMap:
	ld	de,_SCRN0					; BG map address in VRAM
	ld	bc,$1214					; size of map (YX)
LoadMap_loop:
	ld	a,[hl+]						; get tile ID
	ld	[de],a						; copy to BG map
	inc	de							; go to next tile
	dec	c
	jr	nz,LoadMap_loop				; loop until current row has been completely copied
	ld	c,$14						; reset C
	ld	a,e
	add	$c							; go to next row
	jr	nc,.continue				; if carry isn't set, continue
	inc	d
.continue
	ld	e,a
	dec	b
	jr	nz,LoadMap_loop				; loop until all rows have been copied
	ret
	
LoadMapFull:
	ld	de,_SCRN0
	ld	bc,$400
.loop
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,.loop
	ret
	
LoadRow:
	ld	e,a
	ld	b,$20
.loop
	ld	a,e
	ld	[hl+],a
	dec	b
	jr	nz,.loop
	ret
	
LoadMapSafe:
	ld	de,_SCRN0					; BG map address in VRAM
	ld	bc,$1214					; size of map (YX)
LoadMapSafe_loop:
	ldh	a,[rSTAT]
	and	2
	jr	nz,LoadMapSafe_loop
	ld	a,[hl+]						; get tile ID
	ld	[de],a						; copy to BG map
	inc	de							; go to next tile
	dec	c
	jr	nz,LoadMapSafe_loop				; loop until current row has been completely copied
	ld	c,$14						; reset C
	ld	a,e
	add	$c							; go to next row
	jr	nc,.continue				; if carry isn't set, continue
	inc	d
.continue
	ld	e,a
	dec	b
	jr	nz,LoadMapSafe_loop			; loop until all rows have been copied
	ret
	
WaitStat:							; wait for LCD status to change (prevents tearing when using STAT interrupts)
	push	af
.wait
	ldh	a,[rSTAT]
	and	2
	jr	z,.wait
.wait2
	ldh	a,[rSTAT]
	and	2
	jr	nz,.wait2
	pop	af
	ret
	
; Input: hl = palette data	
LoadBGPal:
	ld	a,0
	call	LoadBGPalLine
LoadPalPic:
	ld	a,1
	call	LoadBGPalLine
	ld	a,2
	call	LoadBGPalLine
	ld	a,3
	call	LoadBGPalLine
	ld	a,4
	call	LoadBGPalLine
	ld	a,5
	call	LoadBGPalLine
	ld	a,6
	call	LoadBGPalLine
	ld	a,7
	call	LoadBGPalLine
	ret
	
; Input: hl = palette data	
LoadObjPal:
	ld	a,0
	call	LoadObjPalLine
	ld	a,1
	call	LoadObjPalLine
	ld	a,2
	call	LoadObjPalLine
	ld	a,3
	call	LoadObjPalLine
	ld	a,4
	call	LoadObjPalLine
	ld	a,5
	call	LoadObjPalLine
	ld	a,6
	call	LoadObjPalLine
	ld	a,7
	call	LoadObjPalLine
	ret

LoadBGColor:
	swap	a	; \  multiply
	rrca		; /  palette by 8
	or	$80		; auto increment
	push	af
	RGBG_WaitForVRAM
	pop	af
	ld	[rBCPS],a
	ld	a,d
	ld	[rBCPD],a
	ld	a,e
	ld	[rBCPD],a
	ret
	
; Input: hl = palette data
LoadBGPalLine:
	swap	a	; \  multiply
	rrca		; /  palette by 8
	or	$80		; auto increment
	push	af
	RGBG_WaitForVRAM
	pop	af
	ld	[rBCPS],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	ret
	
; Input: hl = palette data
LoadObjPalLine:
	swap	a	; \  multiply
	rrca		; /  palette by 8
	or	$80		; auto increment
	push	af
	RGBG_WaitForVRAM
	pop	af
	ld	[rOCPS],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	ret
	
OAM_DMA:
	ld	a,high(OAMBuffer)
	ldh	[rDMA],a
	ld	a,$28
.wait
	dec	a
	jr	nz,.wait
	ret
OAM_DMA_End

CopyDMARoutine:
	ld	hl,OAM_DMA
	ld	bc,(OAM_DMA_End-OAM_DMA)<<8+low(_OAM_DMA)
.loop
	ld	a,[hl+]
	ld	[c],a
	inc	c
	dec	b
	jr	nz,.loop
	ret

ClearOAM:
	xor	a
	ld	hl,OAMBuffer
	ld	b,$9f
.clearloop
	ld	[hl+],a
	dec	b
	jr	nz,.clearloop
	jp	$ff80			; do OAM DMA then exit
	
ShowSplash:
	ld	a,120
	ld	[ScreenTimer],a
	
.loop
	WaitForVBlank
	call	CheckInput
	ld	a,[sys_btnPress]
	bit	btnStart,a
	jr	nz,.break
	
	ld	a,[ScreenTimer]
	dec	a
	ld	[ScreenTimer],a
	jr	nz,.loop
	
.break
	ret
	
MetaspriteToOAM:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	b
	jr	nz,MetaspriteToOAM
	ret
	
; ================================================================
; Interrupt routines
; ================================================================	
	
DoVBlank:
	push	af
	ld	a,1
	ldh	[sys_VBlankIRQ],a
	ld	a,[SpritesDisabled]
	and	a
	call	z,_OAM_DMA
	
.done
	pop	af
	reti
	
DoStat:
	push	af
	push	hl
	ld	a,[StatID]
	add	a
	ld	hl,StatTable
	add	l
	ld	l,a
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	bit	7,h
	jr	z,.noerr
	ld	a,err_DestOutsideROM
	rst	$30	; show error message
.noerr
	jp	hl
	
StatTable:
	dw	Stat_None
	dw	Stat_WindowTransition
	dw	Stat_Title
	dw	Stat_CharSelect
StatTable_End
	
Stat_None	; because reti nz doesn't exist
	pop	hl
	pop	af
	reti
	
Stat_WindowTransition:
	; init
	push	bc
	push	de
	ld	c,rWX-$ff00
	ld	a,[WindowTransitionOffset]
	rra
	rra
	ld	d,a
	ld	a,[WindowBasePos]
	ld	e,a
	ld	b,0
	; get first offset
	ld	hl,WindowTransitionLookupTable1
	ld	a,[WindowTransitionPos1]
	inc	a
	ld	[WindowTransitionPos1],a
	add	d
	add	l
	ld	l,a
	jr	nc,.nocarry1
	inc	h
.nocarry1
	ld	a,[hl+]
	ld	b,a
	; get second offset
	ld	hl,WindowTransitionLookupTable2
	ld	a,[WindowTransitionPos2]
	dec	a
	ld	[WindowTransitionPos2],a
	add	d
	add	l
	ld	l,a
	jr	nc,.nocarry2
	inc	h
.nocarry2
	ld	a,[hl+]
	add	b
	add	e
	cp	$c0
	jr	c,.noUnderflow
	ld	a,7
.noUnderflow
	; wait for HBlank
	ld	e,a
	ldh	a,[rSTAT]
	and	2
	jr	nz,@-4
	ld	a,e
	
	ld	[c],a
	ldh	a,[rLYC]
	inc	a
	cp	144
	jr	c,.noOverflow
	xor	a
.noOverflow
	ldh	[rLYC],a
	pop	de
	pop	bc
	pop	hl
	pop	af
	reti
	
WindowTransitionLookupTable1:
	rept	4
		db	0,1,2,2,3,4,4,5,6,6,7,7,7,8,8,8
		db	8,8,8,8,7,7,7,6,6,5,4,4,3,2,2,1
		db	0,-1,-2,-2,-3,-4,-4,-5,-6,-6,-7,-7,-7,-8,-8,-8
		db	-8,-8,-8,-8,-7,-7,-7,-6,-6,-5,-4,-4,-3,-2,-2,-1
	endr
WindowTransitionLookupTable2:


	rept	2
		db	0,0,1,1,2,2,2,3,3,3,4,4,4,5,5,5
		db	6,6,6,6,7,7,7,7,7,8,8,8,8,8,8,8
		db	8,8,8,8,8,8,8,8,7,7,7,7,7,6,6,6
		db	6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,0
		db	0,0,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-5,-5,-5
		db	-6,-6,-6,-6,-7,-7,-7,-7,-7,-8,-8,-8,-8,-8,-8,-8
		db	-8,-8,-8,-8,-8,-8,-8,-8,-7,-7,-7,-7,-7,-6,-6,-6
		db	-6,-5,-5,-5,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,0
	endr
	
Stat_Title:	; TODO: Fix this!
	push	bc
	push	de
	ldh	a,[rLY]
	cp	48
	jr	z,.doGradient
	ld	a,%10000111
	ldh	[rLCDC],a
	ld	a,112
	ldh	[rLYC],a
	reti
.doGradient
	ld	hl,Pal_VineshroomDark
	ld	a,[hl+]
	ld	e,[hl]
	ld	d,a
	call	RGBG_ConvertColor24to15
	ld	b,a
	ld	a,[Gradient_CurrentBlue]
	inc	a
	ld	[Gradient_CurrentBlue],a
	ld	h,a
	ld	a,b
	call	RGBG_ConvertColor15to24
	xor	a
	call	LoadBGColor
	ldh	a,[rLYC]
	cp	142
	jr	nz,.done
	add	2
	ldh	[rLYC],a
.done
	ld	a,48
	ldh	[rLYC],a
	ld	a,%11100111
	ldh	[rLCDC],a
	pop	de
	pop	bc
	pop	hl
	pop	af
	reti
	
Stat_CharSelect:
	push	bc
	push	de
	; get current scanline
	ldh	a,[rLY]
	cp	0
	jr	z,.scrollCharSelText
	cp	15
	jr	z,.scrollPic
;	cp	128
;	jr	z,.doDitherEffect
;	cp	130
;	jr	z,.noscroll1
;	cp	142
;	jr	nz,.done
	jr	.done
.doDitherEffect
	ld	a,[CharSel_TitleTextScroll]
	ldh	[rSCX],a
	ldh	a,[rLY]
	add	2
	ldh	[rLYC],a
.noscroll2
	xor	a
	ldh	[rSCX],a
	ld	a,0
	ldh	[rLYC],a
	jr	.done
.noscroll1
	xor	a
	ldh	[rSCX],a
	ld	a,142
	ldh	[rLYC],a
	jr	.done
.scrollCharSelText
	ld	a,[CharSel_TitleTextScroll]
	inc	a
	ld	[CharSel_TitleTextScroll],a
	ldh	[rSCX],a
	
	ld	a,[DoExitCharSelect]
	and	a
	call	z,ProcessCharSelect
	
	ld	a,15
	ldh	[rLYC],a
	jr	.done
.scrollPic
	ld	a,[CharSel_PicScroll]
	ldh	[rSCX],a
	ld	a,128
	ldh	[rLYC],a
.done
	pop	de
	pop	bc
	pop	hl
	pop	af
	reti
	
; ================================================================
; Switching CPU speeds on the GBC
;  written for RGBASM
; ================================================================

;  This is the code needed to switch the GBC
; speed from single to double speed or from
; double speed to single speed.
;
; Note: The 'nop' below is ONLY required if
; you are using RGBASM version 1.10c or earlier
; and older versions of the GBDK assembly
; language compiler. If you are not sure if
; you need it or not then leave it in.
;
;  The real opcodes for 'stop' are $10,$00.
; Some older assemblers just compiled 'stop'
; to $10 hence the need for the extra byte $00.
; The opcode for 'nop' is $00 so no harm is
; done if an extra 'nop' is included

; *** Set single speed mode ***

SingleSpeedMode:
	ld      a,[rKEY1]
	rlca	    ; Is GBC already in single speed mode?
	ret     nc      ; yes, exit
	jr      CPUToggleSpeed

; *** Set double speed mode ***

DoubleSpeedMode:
	ld      a,[rKEY1]
	rlca	    ; Is GBC already in double speed mode?
	ret     c       ; yes, exit

CPUToggleSpeed:
	di
	ld      hl,rIE
	ld      a,[hl]
	push    af
	xor     a
	ld      [hl],a	 ;disable interrupts
	ld      [rIF],a
	ld      a,$30
	ld      [rP1],a
	ld      a,1
	ld      [rKEY1],a
	stop
	pop     af
	ld      [hl],a
	ei
	ret

; Sample playback system (must be called during timer interrupt!)
; Sample playback system.
; Make sure to set TMA to $00, set TAC to $06, and enable timer interrupt!
DoSample:
	push	af
	ld	a,[SamplePlaying]
	and	a
	jr	nz,.doplay
	xor	a
	ld	[SampleVolume],a
	ld	a,1
	ld	[sys_TimerIRQ],a
	pop	af
	reti
.doplay
	push	de
	push	hl
	ld	hl,SampleSize
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	ld	d,h
	ld	e,l
	ld	hl,SamplePtr
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	ld	a,[SampleBank]
	ld	[rROMB0],a
	
	ldh	a,[rNR51]
	ld	c,a
	and	%10111011
	ldh	[rNR51],a	; prevents spike on GBA
	xor	a
	ldh	[rNR30],a
	ld	a,[hl+]
	push	af
	ldh	[$ff30],a
	ld	a,[hl+]
	ldh	[$ff31],a
	ld	a,[hl+]
	ldh	[$ff32],a
	ld	a,[hl+]
	ldh	[$ff33],a
	ld	a,[hl+]
	ldh	[$ff34],a
	ld	a,[hl+]
	ldh	[$ff35],a
	ld	a,[hl+]
	ldh	[$ff36],a
	ld	a,[hl+]
	ldh	[$ff37],a
	ld	a,[hl+]
	ldh	[$ff38],a
	ld	a,[hl+]
	ldh	[$ff39],a
	ld	a,[hl+]
	ldh	[$ff3a],a
	ld	a,[hl+]
	ldh	[$ff3b],a
	ld	a,[hl+]
	ldh	[$ff3c],a
	ld	a,[hl+]
	ldh	[$ff3d],a
	ld	a,[hl+]
	ldh	[$ff3e],a
	ld	a,[hl+]
	ldh	[$ff3f],a
	ld	a,%10000000
	ldh	[rNR30],a
	ld	a,c
	ldh	[rNR51],a
;	if	!def(DoubleSpeed)
;	xor	a
;	else
	ld	a,$80
;	endc
	ldh	[rNR33],a
	ld	a,$87
	ldh	[rNR34],a
	; optimization by pigdevil2010 (was originally 16x dec de)
	ld	a,e
	sub	16
	ld	e,a
	jr	nc,.nocarry
	dec	d
.nocarry
	
	
	ld	a,h
	cp	$80
	jr	nz,.noreset
	ld	a,[SampleBank]
	inc	a
	ld	[SampleBank],a
	ld	a,$40
.noreset
	ld	[SamplePtr+1],a
	ld	a,l
	ld	[SamplePtr],a
	
	ld	a,d
	cp	$ff
	jr	nz,.noreset2
	xor	a
	ld	[SamplePlaying],a
	ldh	[rNR30],a
.noreset2
	ld	a,d
	ld	[SampleSize+1],a
	ld	a,e
	ld	[SampleSize],a
	
	pop	af
	swap	a
	and	$f
	ld	[SampleVolume],a
	ld	a,1
	ld	[sys_TimerIRQ],a
	pop	hl
	pop	de
	pop	af
	reti	

; ================================================================
; Sound test
; ================================================================

InitSoundTest:
	WaitForVBlank
	di
	xor	a
	ldh	[rLCDC],a
	
	CopyTileset1BPP	DebugFont,0,97
	ld	hl,SoundTestMap
	call	LoadMapText
		
	ld	a,1
	ld	[rROMB0],a
	call	DS_Stop
	
	call	ClearAttribute
	
	ld	hl,Pal_Grayscale
	xor	a
	call	LoadBGPalLine
	
	ld	a,%10010001
	ldh	[rLCDC],a
	
	ld	a,IEF_VBLANK;+IEF_TIMER
	ldh	[rIE],a
	ei
	
	xor	a
	ld	hl,CursorPos
	ld	[hl+],a	; CursorPos = 0
	ld	[hl+],a	; SoundTest_SongID = 0
	ld	[hl+],a	; SoundTest_SFXID = 0
	ld	[hl+],a	; SoundTest_SampleID = 0
	
	
SoundTestLoop:
	ld	hl,rROMB0
	WaitForVBlank
	ld	[hl],1	; load DevSound bank
	call	DS_Play
	ld	[hl],2	; load FX Hammer bank
	call	FXHammer_Update
	; sample playback happens on timer interrupt
	
	push	hl
	ld	a,[CursorPos]
	and	a
	jr	z,.drawSongID
	dec	a
	jr	z,.drawSFXID
	dec	a
	jr	z,.drawSampleID
.drawSongID
	ld	hl,$9871
	ld	a,[SoundTest_SongID]
	ld	b,a
	call	DrawHex
	ClearLine	6
	ld	a,b
	cp	(SoundTest_SongNames_End-SoundTest_SongNames)/2
	jr	nc,.blank
	ld	hl,SoundTest_SongNames
	jr	.doPrint
.drawSFXID
	ld	hl,$9891
	ld	a,[SoundTest_SFXID]
	ld	b,a
	call	DrawHex
	ClearLine	6
	ld	a,b
	cp	(SoundTest_SFXNames_End-SoundTest_SFXNames)/2
	jr	nc,.blank
	ld	hl,SoundTest_SFXNames
	jr	.doPrint
.drawSampleID
	ld	hl,$98b1
	ld	a,[SoundTest_SampleID]
	ld	b,a
	call	DrawHex
	ClearLine	6
	ld	a,b
	cp	(SoundTest_SampleNames_End-SoundTest_SampleNames)/2
	jr	nc,.blank
	ld	hl,SoundTest_SampleNames
	jr	.doPrint
.blank
	ld	hl,EmptyString
	jr	.doPrintSkipPointer
.doPrint
	call	GetPointerFromTable
.doPrintSkipPointer
	strpos	6
	call	PrintString
.checkInput
	pop	hl
	call	CheckInput
	ld	a,[sys_btnPress]
	bit	btnA,a
	jr	nz,.doPlay
	bit	btnB,a
	jr	nz,.doStop
	bit	btnLeft,a
	jp	nz,.dec
	bit	btnRight,a
	jp	nz,.inc
	bit	btnUp,a
	jp	nz,.cursorUp
	bit	btnDown,a
	jp	nz,.cursorDown
	bit	btnStart,a
	jp	z,SoundTestLoop
.exitSoundTest
	jp	ShowTitleScreen

.doPlay
	ld	a,[CursorPos]
	and	a
	jr	z,.playSong
	dec	a
	jr	z,.playSFX
	dec	a
	jp	nz,SoundTestLoop
.playSample
	ld	a,[SoundTest_SampleID]
	call	PlaySample
	jp	SoundTestLoop
.playSFX
	ld	[hl],2	; load FX Hammer bank
	ld	a,[SoundTest_SFXID]
	call	FXHammer_Trig
	jp	SoundTestLoop		; from here out SoundTestLoop is too far for jr to reach
.playSong
	ld	[hl],1	; load DevSound bank
	ld	a,[SoundTest_SongID]
	call	DS_Init
	jp	SoundTestLoop
	
.doStop
	ld	a,[CursorPos]
	and	a
	jr	z,.stopSong
	dec	a
	jp	nz,SoundTestLoop
.stopSFX
	ld	[hl],2	; load FX Hammer bank
	call	FXHammer_Stop
	jp	SoundTestLoop
.stopSong
	ld	[hl],1	; load DevSound bank
	call	DS_Stop
	jp	SoundTestLoop
	
.inc
	ld	a,[CursorPos]
	and	a
	jr	z,.incSong
	dec	a
	jr	z,.incSFX
	dec	a
	jp	nz,SoundTestLoop
.incSample
	ld	a,[SoundTest_SampleID]
	inc	a
	ld	[SoundTest_SampleID],a
	jp	SoundTestLoop
.incSFX
	ld	a,[SoundTest_SFXID]
	inc	a
	ld	[SoundTest_SFXID],a
	jp	SoundTestLoop
.incSong
	ld	a,[SoundTest_SongID]
	inc	a
	ld	[SoundTest_SongID],a
	jp	SoundTestLoop
	
.dec
	ld	a,[CursorPos]
	and	a
	jr	z,.decSong
	dec	a
	jr	z,.decSFX
	dec	a
	jp	nz,SoundTestLoop
.decSample
	ld	a,[SoundTest_SampleID]
	dec	a
	ld	[SoundTest_SampleID],a
	jp	SoundTestLoop
.decSFX
	ld	a,[SoundTest_SFXID]
	dec	a
	ld	[SoundTest_SFXID],a
	jp	SoundTestLoop
.decSong
	ld	a,[SoundTest_SongID]
	dec	a
	ld	[SoundTest_SongID],a
	jp	SoundTestLoop
	
.cursorUp
	ld	a," "
	call	SoundTest_SetCursor
	ld	a,[CursorPos]
	dec	a
	cp	$ff
	jr	nz,.noUnderflow
	ld	a,2
.noUnderflow
	ld	[CursorPos],a
	ld	a,">"
	call	SoundTest_SetCursor
	jp	SoundTestLoop

.cursorDown
	ld	a," "
	call	SoundTest_SetCursor
	ld	a,[CursorPos]
	inc	a
	cp	3
	jr	nz,.noOverflow
	xor	a
.noOverflow
	ld	[CursorPos],a
	ld	a,">"
	call	SoundTest_SetCursor
	jp	SoundTestLoop
	
SoundTestMap:
;		 ####################
	db	"                    "
	db	"   - SOUND TEST -   "
	db	"                    "
	db	"> MUSIC         $00 "
	db	"  SFX           $00 "
	db	"  SAMPLE        $00 "
	db	"(Song/sfx name here)"
	db	"                    "
	db	"Press Start to exit."
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"                    "
;		 ####################

SoundTest_SetCursor:
	push	hl
	sub	$20
	ld	e,a
	ld	a,[CursorPos]
	and	a
	jr	z,.pos0
	dec	a
	jr	z,.pos1
	dec	a
	ret	nz
.pos2
	ld	hl,$98a0
	jr	.continue
.pos1
	ld	hl,$9880
	jr	.continue
.pos0
	ld	hl,$9860
.continue
	ldh	a,[rSTAT]
	and	2
	jr	nz,.continue
	ld	[hl],e
	pop	hl
	ret
	
SoundTest_SongNames:
	dw	SoundTest_Track1
	dw	SoundTest_Track2
	dw	SoundTest_Track3
SoundTest_SongNames_End
	
SoundTest_Track1	str	"Main theme"
SoundTest_Track2	str	"Character select"
SoundTest_Track3	str	"You lose"

SoundTest_SFXNames:
	dw	SoundTest_SFX1
	dw	SoundTest_SFX2
	dw	SoundTest_SFX3
	dw	SoundTest_SFX4
	dw	SoundTest_SFX5
	dw	SoundTest_SFX6
	dw	SoundTest_SFX7
	dw	SoundTest_SFX8
	dw	SoundTest_SFX9
	dw	SoundTest_SFX10
	dw	SoundTest_SFX11
	dw	SoundTest_SFX12
	dw	SoundTest_SFX13
	dw	SoundTest_SFX14
	dw	SoundTest_SFX15
	dw	SoundTest_SFX16
SoundTest_SFXNames_End
	
SoundTest_SFX1	str	"Collectable 1"
SoundTest_SFX2	str	"Menu select"
SoundTest_SFX3	str	"Pause (old)"
SoundTest_SFX4	str	"Big thud"
SoundTest_SFX5	str	"Trill"
SoundTest_SFX6	str	"Pause"
SoundTest_SFX7	str	"Menu cursor"
SoundTest_SFX8	str	"Jump"
SoundTest_SFX9	str	"Menu back"
SoundTest_SFX10	str	"Spin"
SoundTest_SFX11	str	"Small thud"
SoundTest_SFX12	str	"Bounce"
SoundTest_SFX13	str	"Meow"
SoundTest_SFX14	str	"Bark"
SoundTest_SFX15	str	"Collectable 2"
SoundTest_SFX16	str	"Collectable 3"

SoundTest_SampleNames:
	dw	SoundTest_Sample1
	dw	SoundTest_Sample2
	dw	SoundTest_Sample3
	dw	SoundTest_Sample4
	dw	SoundTest_Sample5
SoundTest_SampleNames_End

SoundTest_Sample1	str	"Scoot the burbs"
SoundTest_Sample2	str	"Hell yeah"
SoundTest_Sample3	str	"EXTRA THICC"
SoundTest_Sample4	str	"You're too slow!"
SoundTest_Sample5	str	"BEE SEVUNTEEN BAWMER"

; ================================================================
; Error handler
; ================================================================

	include	"ErrorHandler.asm"

; ================================================================
; Misc routines and data
; ================================================================

ClearAttribute:
	ld	a,1
	ldh	[rVBK],a
	ld	hl,$9800
	ld	bc,$800
.loop
	xor	a
	ld	[hl+],a
	dec	bc
	ld	a,b
	or	c
	jr	nz,.loop
	xor	a
	ldh	[rVBK],a
	ret
	
include	"DecompressionRoutines.asm"

PlaySample:
	ld	hl,SampleTable
	add	a
	ld	b,0
	ld	c,a
	add	hl,bc
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	
	ld	a,[hl+]
	ldh	[SamplePtr],a
	ld	a,[hl+]
	ldh	[SamplePtr+1],a
	ld	a,[hl+]
	ldh	[SampleSize],a
	ld	a,[hl+]
	ldh	[SampleSize+1],a
	ld	a,[hl+]
	ldh	[SampleBank],a
	ld	a,1
	ldh	[SamplePlaying],a
	ret

SampleTable:
	dw	.vinnysel
	dw	.joelsel
	dw	.thiccsel
	dw	.sonicsel
	dw	.b17bomber
	
.vinnysel	Sample	Sample_VinnySelect,	Sample_VinnySelect_End-Sample_VinnySelect,	Bank(Sample_VinnySelect)
.joelsel	Sample	Sample_JoelSelect,	Sample_JoelSelect_End-Sample_JoelSelect,	Bank(Sample_JoelSelect)
.thiccsel	Sample	Sample_ThiccSelect,	Sample_ThiccSelect_End-Sample_ThiccSelect,	Bank(Sample_ThiccSelect)
.sonicsel	Sample	Sample_SonicSelect,	Sample_SonicSelect_End-Sample_SonicSelect,	Bank(Sample_SonicSelect)
.b17bomber	Sample	Sample_B17BomberA,	(Sample_B17Bomber_End-Sample_B17BomberB)+$4000,Bank(Sample_B17BomberA)	; sample too big for one bank lel

; =====================
; Error message routine
; =====================

ShowError:
	push	af
	ld	a,1
	ld	[rROMB0],a
	call	DS_Stop
.wait
	ldh	a,[rLY]
	cp	$90
	jr	nz,.wait
	xor	a
	ldh	[rLCDC],a	; disable LCD
	di
	;call	ClearVRAM
	CopyTileset1BPP	DebugFont,0,97
	
	pop	af
	ld	hl,ErrorMessageTable
	add	a
	add	l
	ld	l,a
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	strpos	0
	call	PrintString
	
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	xor	a
	ldh	[rSCX],a
	ldh	[rSCY],a
	ldh	[rWX],a
	ldh	[rWY],a
	ld	a,%10010001
	ldh	[rLCDC],a
	ei
	
.loop
	halt
	jr	.loop
	
PrintString:
.loop
	; wait for VRAM accessibility
	ldh	a,[rSTAT]
	and	2
	jr	nz,.loop
	ld	a,[hl+]		; get char
	and	a			; is it zero?
	ret	z			; if yes, return
	sub	32			; subtract 32 for printing
	ld	[de],a		; copy char to VRAM
	inc	de			; increment dest pointer
	jr	.loop		; loop
	
ErrorMessageTable:
	dw	.unknown
	dw	.invalidCharID
	dw	.spriteOver
	dw	.frameOver
	dw	.destOutsideROM
	
.unknown		str	"Unknown error"
.invalidCharID	str	"Invalid character ID"
.spriteOver		str	"Too many sprites!"
.frameOver		str	"Frame time exceeded"
.destOutsideROM	str	"JP dest. outside ROM"

; ================================================================
; Graphics data
; ================================================================

DebugFont:				incbin	"Font.bin"						; 1bpp font data
DebugFont_End

VinesauceTextTiles:		incbin	"GFX/VinesauceTextTiles.bin"
VinesauceTextTiles_End

VinesauceTextMap:		incbin	"GFX/VinesauceTextMap.bin"

VineshroomTiles:		incbin	"GFX/Vineshroom.bin"

DevSoftTiles:			incbin	"GFX/DevSoftTiles.rnc"			; 2bpp tile data (RNC compressed)
DevSoftTiles_End

DevSoftMap:				incbin	"GFX/DevSoftMap.bin"			; tilemap

BlankTiles:				incbin	"GFX/BlankTiles.bin"
BlankTiles_End

; GBC palettes
Pal_White:
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
	dw	$7fff,$7fff,$7fff,$7fff
Pal_Grayscale:
	dw	$7fff,$6e94,$354a,$0000
Pal_Vinesauce:
	dw	$7fff,$6e94,$354a,$1cc6
Pal_Vineshroom:	
	dw	$7c1f,$7fff,$2778,$4680
Pal_VineshroomDark:
	Color	0,0,0		; bg color
	Color	15,15,15	; white
	Color	12,13,4		; light shade
	Color	0,10,8		; dark shade
	
Pal_CharSelectMain:
	dw	$7fff,$7e9c,$554a,$2c84
	
CharSelectTiles:	incbin	"GFX/CharSelectTiles.bin"
CharSelectTiles_End
	
CharSelectMap:		incbin	"GFX/CharSelectMap.bin"

TitleMap:	; placeholder for now
;		 ####################
	db	"                    "
	db	"- SCOOT THE BURBS - "
	db	"Pre-alpha build v0.1"
	db	"                    "
	db	" PLACEHOLDER TITLE! "
	db	"    PRESS START.    "
;		 ####################

; ================================================================
; Character select pics
; ================================================================

Pic_Dummy:	include	"Pics/Dummy.pic"

; ================================================================
; Misc data
; ================================================================

EmptyString:
	str	"                    "
	
; ================================================================
; GBS Header
; ================================================================

if def(GBS)
	include	"gbs.asm"
endc
	
; ================================================================
; Other data banks
; ================================================================

include	"FXHammer.asm"	; SFX
include	"DevSound.asm"	; music

; ================================================================
; Sample banks
; ================================================================

section	"Sample bank 1",romx,bank[3]

Sample_VinnySelect:	incbin	"Samples/CharSel_Vinny.aud"
Sample_VinnySelect_End

section	"Sample bank 2",romx,bank[4]

Sample_JoelSelect:	incbin	"Samples/CharSel_Joel.aud"
Sample_JoelSelect_End

section	"Sample bank 3",romx,bank[5]

Sample_ThiccSelect:	incbin	"Samples/CharSel_HeThicc.aud"
Sample_ThiccSelect_End

section	"Sample bank 4",romx,bank[6]

Sample_SonicSelect:	incbin	"Samples/CharSel_Sonic.aud"
Sample_SonicSelect_End

section	"Sample bank 5",romx,bank[7]
Sample_B17BomberA:	incbin	"Samples/B17BomberA.aud"


section "Sample bank 6",romx,bank[8]
Sample_B17BomberB:	incbin	"Samples/B17BomberB.aud"
Sample_B17Bomber_End