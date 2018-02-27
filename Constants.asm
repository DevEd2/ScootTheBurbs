; ================================================================
; Constants
; ================================================================

if !def(incConsts)
incConsts	set	1

; ================================================================
; Global constants
; ================================================================

sys_DMG		equ	0
sys_GBP		equ	1
sys_SGB		equ	2
sys_SGB2	equ	3
sys_GBC		equ	4
sys_GBA		equ	5

btnA		equ	0
btnB		equ	1
btnSelect	equ	2
btnStart	equ	3
btnRight	equ	4
btnLeft		equ	5
btnUp		equ	6
btnDown		equ	7

_A			equ	1
_B			equ	2
_Select		equ	4
_Start		equ	8
_Right		equ	16
_Left		equ	32
_Up			equ	64
_Down		equ	128

; ================================================================
; Sound constants
; ================================================================

BGM_ScootTheBurbs	equ	0
BGM_Title			equ	1
BGM_CharacterSelect	equ	2

SFX_Collect			equ	0
SFX_MenuSelect		equ	1
SFX_CheatOK			equ	2
SFX_BigThud			equ	3
SFX_Denied			equ	4
SFX_Pause			equ	5
SFX_MenuCursor		equ	6
SFX_Jump			equ	7
SFX_MenuBack		equ	8
SFX_FlipTrick		equ	9
SFX_Land			equ	10
SFX_Bounce			equ	11

; ================================================================
; Serial constants
; ================================================================

Packet_PrinterInit	equ	1
Packet_PrinterStart	equ	2
Packet_PrinterFill	equ	4
Packet_PrinterRead	equ	$f

; ================================================================
; GB printer status constants
; ================================================================

PBit_ChecksumError	equ	0
PBit_Printing		equ	1
PBit_PrintRequested	equ	2
PBit_ReadyToPrint	equ	3
PBit_LowBattery		equ	4
PBit_Timeout		equ	5
PBit_PaperJam		equ	6
PBit_BadTem			equ	7

; ================================================================
; Error IDs
; ================================================================

err_Unknown			equ	0
err_InvalidCharID	equ	1
err_TooManySprites	equ	2
err_FrameTimeOver	equ	3
err_DestOutsideROM	equ	4

; ================================================================
; Project-specific constants
; ================================================================

VineshroomPosY1	equ	$c100
VineshroomPosY2	equ	$c104
VineshroomPosX1	equ	$c101
VineshroomPosX2	equ	$c105

endc