INCLUDE	"RGBGRAFX.INC"

INCLUDE	"HARDWARE.INC"
INCLUDE	"INCDEC.INC"
;INCLUDE	"DEBUGMSG.INC"

RGBG_MakeLighter::
	cp	31
	adc	0
	ld	d,a

	ld	a,l ;a
	cp	31
	adc	0
	ld	l,a

	ld	a,h
	cp	31
	adc	0
	ld	h,a

	ld	a,d
	ret

RGBG_MakeDarker::
	or	a
	jr	z, .skip1
	dec	a
.skip1:
	ld	d,a

	xor	a
	cp	l
	jr	z,.skip2
	dec	l
.skip2:

	cp	h
	jr	z,.skip3
	dec	h
.skip3:

	ld	a,d
	ret

RGBG_SimpleFadeOut::

	ld	b,32
.loop0:

	push	bc

; Wait for next	screen redraw
.skip:
	ld	a,[rLY]
	or	a
	jr	nz,.skip

	ld	b,$80
.loop1:
	ld	c,$69

; Read BG color	register pair

	ld	a,b
	ld	[rBCPS],a

	di
	RGBG_WaitForVRAM

	ld	a,[c]
	ld	e,a

	ld	a,b
	inc	a
	ld	[rBCPS],a

	ld	a,[c]
	ei

	ld	d,a

; Fade color register pair

	ld A,[RGBG_fade_to_color]
	cp RGBG_WHITE
	jp nz, .black1

	call	RGBG_ConvertColor15to24
	call	RGBG_MakeLighter
	call	RGBG_ConvertColor24to15
	jp .skip1

.black1	call	RGBG_ConvertColor15to24
	call	RGBG_MakeDarker
	call	RGBG_ConvertColor24to15
.skip1

; Write	BG color register pair

	ld	a,b
	ld	[rBCPS],a

	di
	RGBG_WaitForVRAM

	ld	a,e
	ld	[c],a

	ld	a,d
	ld	[c],a

	ei

	ld	c,$6b

; Read OBJ color register pair

	ld	a,b
	ld	[rOCPS],a

	di
	RGBG_WaitForVRAM

	ld	a,[c]
	ld	e,a

	ld	a,b
	inc	a
	ld	[rOCPS],a

	ld	a,[c]
	ei

	ld	d,a

; Fade color register pair to white

	ld A,[RGBG_fade_to_color]
	cp RGBG_WHITE
	jp nz, .black2

	call	RGBG_ConvertColor15to24
	call	RGBG_MakeLighter
	call	RGBG_ConvertColor24to15
	jp .skip2

.black2	call	RGBG_ConvertColor15to24
	call	RGBG_MakeDarker
	call	RGBG_ConvertColor24to15
.skip2

; Write	OBJ color register pair

	ld	a,b
	ld	[rOCPS],a

	di
	RGBG_WaitForVRAM

	ld	a,e
	ld	[c],a

	ld	a,d
	ld	[c],a

	ei

	inc	b
	inc	b
	
	ld	a,$80+$40 ;-16
	cp	b		; Are we done?
	jp	nz,.loop1	; not yet
	
	ld	a,Bank(DevSound)
	ld	[rROMB0],a
	call	DS_Play
	ld	a,Bank(FXHammer)
	ld	[rROMB0],a
	call	FXHammer_Update
	
	pop	bc
	dec	b		; Are we done yet?
	jp	nz,.loop0	; not yet
	ret

RGBG_InitComplexFadeBkg::
;input:
;HL = palettes to fade to

	;this is the third time	I've coded this	routine	from scratch.  Third time's a charm, though!

	push HL

	ld DE,RGBG_fade_work_ram_bkg

	ld A,[RGBG_first_pal_to_fade_bkg]
	sla A ;2
	sla A ;4
	sla A ;8
	or %10000000
	ld [rBCPS],A

	ld A,[RGBG_pals_to_fade_bkg]
	sla A ;x2
	sla A ;x4
	ld B,A

.readpalsloop

	push DE

	vld A,[rBCPD]
	ld [rBCPD],A ;so that rBCPS is incremented
	ld E,A
	vld A,[rBCPD]
	ld [rBCPD],A ;so that rBCPS is incremented
	ld D,A

	call RGBG_ConvertColor15to24

	pop DE

	push AF	;we store the red byte last, (beleive me, it's easier later)

	ld A,H ;blue
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	ld A,L ;green
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	pop AF ;red
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	dec B
	jp NZ, .readpalsloop

;now it's time to calculate the	deltas.

	pop HL

	ld DE,RGBG_fade_work_ram_bkg

	ld A,[RGBG_pals_to_fade_bkg]
	sla A ;x2
	sla A ;x4
	ld B,A
	
.calcdeltasloop

	push HL
	push DE
	
	ld A,[HL+]
	ld E,A
	ld A,[HL]
	ld D,A

	call RGBG_ConvertColor15to24

	pop DE

	push AF

	;blue
	ld A,[DE]
	ld C,A	;what it is now
	ld A,H	;what is should	become
	sub C
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	;green
	ld A,[DE]
	ld C,A	;what it is now
	ld A,L	;what is should	become
	sub C
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	;red
	ld A,[DE]
	ld C,A	;what it is now
	pop AF	;what is should	become
	sub C
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	pop HL
	inc HL
	inc HL

	dec B
	jp NZ, .calcdeltasloop
	
	ld A,255
	ld [RGBG_fade_steps_left_bkg],A

	ret

RGBG_RunComplexFadeStepBkg::
;no input

	;dont run a step if we're done with the fade
	ld A,[RGBG_fade_steps_left_bkg] 
	and $FF
	jp z, .bail

	ld HL,RGBG_fade_work_ram_bkg

	ld A,[RGBG_pals_to_fade_bkg]
	sla A ;x2
	sla A ;x4
	ld B,A
	add B ;x8
	add B ;x12
	ld B,A
	

.adddeltas
	ld A,[HL+] ;to data.l
	add A,[HL]
	ld [HL+],A ;to data.h
	ld A,0
	adc A,[HL]
	ld [HL],A

	dec HL ;back to	data.l
	ld A,$80
	add A,[HL]
	ld A, [HL+] ;to	data.h
	ld A,$FF
	adc A,[HL]
	ld [HL+],A ;to delta
	;back to data.l
	
	dec B
	jp nz, .adddeltas
	
	ld HL,RGBG_fade_steps_left_bkg
	dec [HL]

.bail	ret
	
RGBG_DecodeComplexFadePalsBkg::
;no input

	ld DE,RGBG_fade_work_ram_bkg+2 ;set it to data.h, since thats all we work with
	
	ld HL,RGBG_fade_current_pals_bkg
	
	ld A,[RGBG_pals_to_fade_bkg]
	sla A ;x2
	sla A ;x4
	ld B,A

.decodepals
	push DE
	push HL

	;green
	ld A,[DE]
	ld H,A
	inc DE
	inc DE
	inc DE
	
	;blue
	ld A,[DE]
	ld L,A
	inc DE
	inc DE
	inc DE
	
	;red
	ld A,[DE]
	
	call RGBG_ConvertColor24to15
	
	pop HL
	
	ld A,E
	ld [HL+],A
	ld A,D
	ld [HL+],A
	
	pop DE
	
	ld A,9
	add E
	ld E,A
	xor A,A
	adc D
	ld D,A
	
	dec B
	jp nz, .decodepals
	ret
	
	
RGBG_UpdateComplexFadePalsBkg::
;no input

	ld HL,RGBG_fade_current_pals_bkg
	
	ld A,[RGBG_first_pal_to_fade_bkg]
	sla A ;2
	sla A ;4
	sla A ;8
	or %10000000
	ld [rBCPS],A

	ld A,[RGBG_pals_to_fade_bkg]
	sla A ;x2
	sla A ;x4
	ld B,A

.setpals
	vld A,[HL+]
	ld [rBCPD],A
	ld A,[HL+]
	ld [rBCPD],A
	
	dec B
	jp nz, .setpals
	
	ret

RGBG_InitComplexFadeObj::
;input:
;HL = palettes to fade to

	;this is the third time	I've coded this	routine	from scratch.  Third time's a charm, though!

	push HL

	ld DE,RGBG_fade_work_ram_obj

	ld A,[RGBG_first_pal_to_fade_obj]
	sla A ;2
	sla A ;4
	sla A ;8
	or %10000000
	ld [rOCPS],A

	ld A,[RGBG_pals_to_fade_obj]
	sla A ;x2
	sla A ;x4
	ld B,A

.readpalsloop

	push DE

	vld A,[rOCPD]
	ld [rOCPD],A ;so that rOCPS is incremented
	ld E,A
	vld A,[rOCPD]
	ld [rOCPD],A ;so that rOCPS is incremented
	ld D,A

	call RGBG_ConvertColor15to24

	pop DE

	push AF	;we store the red byte last, (beleive me, it's easier later)

	ld A,H ;blue
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	ld A,L ;green
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	pop AF ;red
	ld [DE],A
	inc DE
	inc DE
	ld [DE],A
	inc DE

	dec B
	jp NZ, .readpalsloop

;now it's time to calculate the	deltas.

	pop HL

	ld DE,RGBG_fade_work_ram_obj

	ld A,[RGBG_pals_to_fade_obj]
	sla A ;x2
	sla A ;x4
	ld B,A
	
.calcdeltasloop

	push HL
	push DE
	
	ld A,[HL+]
	ld E,A
	ld A,[HL]
	ld D,A

	call RGBG_ConvertColor15to24

	pop DE

	push AF

	;blue
	ld A,[DE]
	ld C,A	;what it is now
	ld A,H	;what is should	become
	sub C
	sla A ;x2
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	;green
	ld A,[DE]
	ld C,A	;what it is now
	ld A,L	;what is should	become
	sub C
	sla A ;x2
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	;red
	ld A,[DE]
	ld C,A	;what it is now
	pop AF	;what is should	become
	sub C
	sla A ;x2
	add $80	;makes 8-bit signed + 16-but unsigned addition easier
	ld [DE],A ;what	needs to be added 128 times
	inc DE
	inc DE
	inc DE

	pop HL
	inc HL
	inc HL

	dec B
	jp NZ, .calcdeltasloop
	
	ld A,128
	ld [RGBG_fade_steps_left_obj],A

	ret

RGBG_RunComplexFadeStepObj::
;no input

	ld HL,RGBG_fade_work_ram_obj

	ld A,[RGBG_pals_to_fade_obj]
	sla A ;x2
	sla A ;x4
	ld B,A
	add B ;x8
	add B ;x12
	ld B,A
	

.adddeltas
	ld A,[HL+] ;to data.l
	add A,[HL]
	ld [HL+],A ;to data.h
	ld A,0
	adc A,[HL]
	ld [HL],A

	dec HL ;back to	data.l
	ld A,$80
	add A,[HL]
	ld A, [HL+] ;to	data.h
	ld A,$FF
	adc A,[HL]
	ld [HL+],A ;to delta
	;back to data.l
	
	dec B
	jp nz, .adddeltas
	
	ld HL,RGBG_fade_steps_left_obj
	dec [HL]

	ret
	
RGBG_DecodeComplexFadePalsObj::
;no input

	ld DE,RGBG_fade_work_ram_obj+2 ;set it to data.h, since thats all we work with
	
	ld HL,RGBG_fade_current_pals_obj
	
	ld A,[RGBG_pals_to_fade_obj]
	sla A ;x2
	sla A ;x4
	ld B,A

.decodepals
	push DE
	push HL

	;green
	ld A,[DE]
	ld H,A
	inc DE
	inc DE
	inc DE
	
	;blue
	ld A,[DE]
	ld L,A
	inc DE
	inc DE
	inc DE
	
	;red
	ld A,[DE]
	
	call RGBG_ConvertColor24to15
	
	pop HL
	
	ld A,E
	ld [HL+],A
	ld A,D
	ld [HL+],A
	
	pop DE
	
	ld A,9
	add E
	ld E,A
	xor A,A
	adc D
	ld D,A
	
	dec B
	jp nz, .decodepals
	ret
	
	
RGBG_UpdateComplexFadePalsObj::
;no input

	ld HL,RGBG_fade_current_pals_obj
	
	ld A,[RGBG_first_pal_to_fade_obj]
	sla A ;2
	sla A ;4
	sla A ;8
	or %10000000
	ld [rOCPS],A

	ld A,[RGBG_pals_to_fade_obj]
	sla A ;x2
	sla A ;x4
	ld B,A

.setpals
	vld A,[HL+]
	ld [rOCPD],A
	ld A,[HL+]
	ld [rOCPD],A
	
	dec B
	jp nz, .setpals
	
	ret

RGBG_RunComplexFadeBkg::
;input
;HL = pals to fade to
;Run's C many steps every B vblanks
;references RGBG_pals_to_fade_bkg
;references RGBG_first_pal_to_fade_bkg
	push BC
	call RGBG_InitComplexFadeBkg
	pop BC
	
.dostep

	push BC

.runstep
	push BC
	call RGBG_RunComplexFadeStepBkg
	pop BC
	dec C
	jp NZ, .runstep
	
	push BC
	call RGBG_DecodeComplexFadePalsBkg
	pop BC

.wvbls
	RGBG_WaitNVBL
	RGBG_WaitVBL
	dec B
	jp nz, .wvbls

	call RGBG_UpdateComplexFadePalsBkg	
	pop BC
	
	ld A,[RGBG_fade_steps_left_bkg]
	and $FF
	jp nz, .dostep
	
	ret
	
RGBG_RunComplexFadeObj::
;input
;HL = pals to fade to
;Run's C many steps every B vblanks
;references RGBG_pals_to_fade_bkg
;references RGBG_first_pal_to_fade_bkg
	push BC
	call RGBG_InitComplexFadeObj
	pop BC
	
.dostep

	push BC

.runstep
	push BC
	call RGBG_RunComplexFadeStepObj
	pop BC
	dec C
	jp NZ, .runstep
	
	push BC
	call RGBG_DecodeComplexFadePalsObj
	pop BC

.wvbls	
	RGBG_WaitNVBL
	RGBG_WaitVBL
	dec B
	jp nz, .wvbls
	
	call RGBG_UpdateComplexFadePalsObj
	
	pop BC
	
	ld A,[RGBG_fade_steps_left_obj]
	and $FF
	jp nz, .dostep	
	
	ret	
	
RGBG_ConvertColor15to24:
;input:
;D = high byte
;E = low byte
;output:
;H = Blue
;L = Green
;A = Red

	ld	a,e

	srl	d
	rr	e
	srl	d
	rr	e
	ld	h,d

	srl	e
	srl	e
	srl	e
	ld	l,e

	and	$1f
	ret

RGBG_ConvertColor24to15:
;Input:
;H = Blue
;L = Green
;A = Red
;Output:
; D = high byte
; E = low byte

	rlca
	rlca
	rlca
	ld	e,a
	srl	l
	rr	e
	srl	l
	rr	e
	srl	l
	rr	e

	ld	a,h
	add	a
	add	a
	add	l
	ld	d,a

	ret