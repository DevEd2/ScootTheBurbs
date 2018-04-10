; ================================================================
; Macros
; ================================================================

if	!def(incMacros)
incMacros	set	1

; Copy a tileset to a specified VRAM address.
; USAGE: CopyTileset [tileset],[VRAM address],[number of tiles to copy]
CopyTileset:			macro
	ld	bc,$10*\3		; number of tiles to copy
	ld	hl,\1			; address of tiles to copy
	ld	de,$8000+\2		; address to copy to
	call	_CopyTileset
	endm
	
; Same as CopyTileset, but waits for VRAM accessibility.
CopyTilesetSafe:		macro
	ld	bc,$10*\3		; number of tiles to copy
	ld	hl,\1			; address of tiles to copy
	ld	de,$8000+\2		; address to copy to
	call	_CopyTilesetSafe
	endm
	
; Copy a 1BPP tileset to a specified VRAM address.
; USAGE: CopyTileset1BPP [tileset],[VRAM address],[number of tiles to copy]
CopyTileset1BPP:		macro
	ld	bc,$10*\3		; number of tiles to copy
	ld	hl,\1			; address of tiles to copy
	ld	de,$8000+\2		; address to copy to
	call	_CopyTileset1BPP
	endm
	
; Same as CopyTileset1BPP, but tiles are inverted.
CopyTileset1BPPInvert:	macro
	ld	bc,$10*\3		; number of tiles to copy
	ld	hl,\1			; address of tiles to copy
	ld	de,$8000+\2		; address to copy to
	call	_CopyTileset1BPPInvert
	endm
	
; Copy a compressed tileset to a specified VRAM address.
; USAGE: CopyCompressedTileset [tileset],[VRAM address]
CopyCompressedTileset:	macro
	ld	hl,\1
	ld	de,$8000+\2
	call	RNC_Unpack
	endm
	
; Defines a palette color:
; Usage: Color [red],[green],[blue]
Color:	macro
	dw	\1+(\2<<5)+(\3<<10)
	endm
	
LoadSprite:			macro
	ld	hl,\1
	ld	de,\2
	ld	b,\3
	call	MetaspriteToOAM
	endm
	
; Copy decompressed data to a specified RAM address.
; USAGE: DecompressToRAM [source],[destination]
DecompressToRAM:		macro
	ld	hl,\1
	ld	de,\2
	call	RNC_Unpack
	endm
	
; Define a sample.
; USAGE: Sample [sample],[size],[bank]
; "sample" refers to any sample pointer.
; Example: Sample Sample_Sega,Sample_SegaEnd-Sample_Sega,Bank(Sample_Sega)
Sample:					macro
	dw	\1,\2
	db	\3
	endm

;fade to white
Pal_FadeToWhite:	macro
	ld a,0
	ld [RGBG_first_pal_to_fade_bkg],a
	ld a,4
	ld [RGBG_pals_to_fade_bkg],a
	ld hl,Pal_White
	ld c,8
	ld b,1
	call	RGBG_RunComplexFadeBkg
	endm
	
Pal_FadeToPal:		macro
	ld a,0
	ld [RGBG_first_pal_to_fade_bkg],a
	ld a,\2
	ld [RGBG_pals_to_fade_bkg],a
	ld hl,\1
	ld c,\3
	ld b,1
	call RGBG_RunComplexFadeBkg
	endm
	
WaitForVBlank:			macro
	rst	$00
	endm
	
WaitForStat:			macro
	rst	$10
	endm
	
WaitForTimer:			macro
	rst	$20
	endm
	
str:					macro
	db	\1,0
	endm
	
strpos:					macro
	ld	de,$9800+(\1*$20)
	endm
	
ClearLine:				macro
	ld	hl,EmptyString
	ld	de,$9800+(\1*$20)
	call	PrintString
	endm
	
include	"Z80.asm"
	
endc