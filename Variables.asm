; ================================================================
; Variables
; ================================================================

if !def(incVars)
incVars	set	1

SECTION "Virtual zeropage",WRAM0

GBCFlag					ds	1
GBAFlag					ds	1
EmuCheck				ds	1
ScrollTablePos			ds	1
StatID					ds	1
WindowTransitionPos1	ds	1
WindowTransitionPos2	ds	1
WindowBasePos			ds	1
WindowTransitionOffset	ds	1
SpritesDisabled			ds	1
Gradient_CurrentRed		ds	1
Gradient_CurrentGreen	ds	1
Gradient_CurrentBlue	ds	1
CursorPos				ds	1
CharSel_CharID			ds	1

SoundTest_SongID		ds	1
SoundTest_SFXID			ds	1
SoundTest_SampleID		ds	1

SECTION	"OAM buffer",WRAM0[$c100]
OAMBuffer				ds	$100

SECTION	"RGBGrafx fade routine RAM",WRAM0[$c200]
RGBG_fade_to_color				ds	1
;I know, this fuction suite is a memory hog. sorry.
RGBG_fade_work_ram_bkg::		DS 8*4*3*3 ;8 pals x 4 colors x	3 components X 3 bytes for each	components
RGBG_fade_current_pals_bkg::	DS 64
RGBG_fade_status_bkg::			DS 1
RGBG_fade_steps_left_bkg::		DS 1
RGBG_pals_to_fade_bkg::			DS 1
RGBG_first_pal_to_fade_bkg::	DS 1
RGBG_fade_work_ram_obj::		DS 8*4*3*3 ;8 pals x 4 colors x	3 components X 3 bytes for each	components
RGBG_fade_current_pals_obj::	DS 64
RGBG_fade_status_obj::			DS 1
RGBG_fade_steps_left_obj::		DS 1
RGBG_pals_to_fade_obj::			DS 1
RGBG_first_pal_to_fade_obj::	DS 1

SECTION	"System variables",HRAM

; ================================================================
; Global variables
; ================================================================

_OAM_DMA				ds	16
sys_btnHold				ds	1	; held buttons
sys_btnPress			ds	1	; pressed buttons
sys_VBlankIRQ			ds	1
sys_StatIRQ				ds	1
sys_TimerIRQ			ds	1
sys_SerialIRQ			ds	1
sys_GameMode			ds	1
sys_ErrorType			ds	1

SerialType				ds	1
SerialTransferredData	ds	1
SerialRecievedData		ds	1

SamplePlaying			ds	1
SamplePtr				ds	2
SampleSize				ds	2
SampleBank				ds	1
SampleBankCount			ds	1
SampleVolume			ds	1

CurrentSample			ds	1

ScreenTimer				ds	1

; ================================================================

SECTION "Temporary register storage space",HRAM

tempAF				ds	2
tempBC				ds	2
tempDE				ds	2
tempHL				ds	2
tempBC2				ds	2
tempDE2				ds	2
tempHL2				ds	2
tempHL3				ds	2
tempSP				ds	2
tempPC				ds	2
tempIF				ds	1
tempIE				ds	1

; ================================================================

endc
