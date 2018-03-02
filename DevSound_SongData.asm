; ================================================================
; DevSound song data
; ================================================================
	
; =================================================================
; Song speed table
; =================================================================

SongSpeedTable:
	db	8,7		; scoot the burbs
	db	3,3		; character select
	db	3,3		; you lose

SongSpeedTable_End
	
SongPointerTable:
	dw	PT_ScootTheBurbs
	dw	PT_CharacterSelect
	dw	PT_LoseHorn
SongPointerTable_End

if(SongSpeedTable_End-SongSpeedTable) < (SongPointerTable_End-SongPointerTable)
	fail "SongSpeedTable does not have enough entries for SongPointerTable"
endc

if(SongSpeedTable_End-SongSpeedTable) > (SongPointerTable_End-SongPointerTable)
	warn "SongSpeedTable has extra entries"
endc

; =================================================================
; Volume sequences
; =================================================================

; For pulse and noise instruments, volume control is software-based by default.
; However, when the table execution ends ($FF) the value after that terminator
; will be loaded as a hardware volume and envelope. Please be cautious that the
; envelope speed won't be scaled along the channel volume.

; For wave instruments, volume has the same range as the above (that's right,
; this is possible by scaling the wave data) except that it won't load the
; value after the terminator as a final volume.
; WARNING: since there's no way to rewrite the wave data without restarting
; the wave so make sure that the volume doesn't change too fast that it
; unintentionally produces sync effect.
; NOTE: If the DisableWaveScaling flag is enabled, the above does not apply.
; Instead, there are four volume values (including 0). These values can be
; selected with w0-w3.

w0	equ	0
w1	equ	3
w2	equ	7
w3	equ	15

vol_Kick:			db	$ff,$81
vol_Snare:			db	$ff,$d1
vol_OHH:			db	$ff,$84
vol_CymbQ:			db	$ff,$a6
vol_CymbL:			db	$ff,$f3
vol_Tom:			db	$ff,$c1
vol_Tink:			db	$ff,$51

vol_BurbsLeadC:		db	13,12,12,12,12,12,11,$fe,6
vol_BurbsFadeC:		db	8,8,8,8,8,8,8,8,8,8,7,7,7,6,6,6,6,6,6,5,5,5,5,5,4,4,4,3,3,3,3,3,3,2,2,2,1,1,1,1,1,0,$ff,0
vol_BurbsSlide:		db	13,12,12,12,$fe,0
vol_BurbsArp:		db	$ff,$c2
vol_BurbsLead:		db	$ff,$f6
vol_BurbsFade:		db	$ff,$a2
vol_BurbsBass:		db	w3,w3,w3,w3,w3,w3,w2,$fe,6
vol_BurbsBassL:		db	w3,w3,w3,w3,w3,w3,w3,w3,w3,w3,w3,w3,w3,w2,$fe,13

vol_CharSelBass:	db	w3,w3,w3,w3,w3,w3,w3,w3,w3,w2,w2,w2,w2,w2,w2,w1,$fe,15

vol_CharSelLead:	db	15,$fd,$ff,$f2
vol_CharSelLead8:	db	8,$fd,$ff,$82
vol_CharSelLead4:	db	4,$fd,$ff,$42
vol_CharSelLead2:	db	2,$fd,$ff,$22
vol_CharSelLead1:	db	1,$fd,$ff,$12
vol_CharSelLeadC:	db	12,$fd,$ff,$c2
vol_CharSelArp:		db	$ff,$b3

vol_LoseHorn:		db	$ff,$c0

; =================================================================
; Arpeggio/Noise sequences
; =================================================================

s7	equ	$2d

; Noise values are the same as Deflemask, but with one exception:
; To convert 7-step noise values (noise mode 1 in deflemask) to a
; format usable by DevSound, take the corresponding value in the
; arpeggio macro and add s7.
; Example: db s7+128+32 = noise value 32 with step lengh 7
; Note that each noiseseq must be terminated with a loop command
; ($fe) otherwise the noise value will reset!

arp_Pluck:			db	12,0,$ff

arp_Kick:			db	$a0,$9a,$a5,$fe,2
arp_Snare:			db	s7+$9d,s7+$97,s7+$94,$a3,$fe,3
arp_Hat:			db	$a9,$ab,$fe,1
arp_Tom:			db	22,20,18,16,14,12,10,9,7,6,4,3,2,1,0,$ff
arp_Tink:			db	128+A#7,128+A_7,$fe,1

arp_BurbsSlide1:	db	0,0,0,0,2,2,2,2,4,4,4,4,6,6,6,6,$ff
arp_BurbsSlide2:	db	0,0,0,0,2,2,2,2,3,3,3,3,5,5,5,5,$ff
arp_BurbsHack:		db	0,$fe,0

; =================================================================
; Pulse/Wave sequences
; =================================================================

WaveTable:
	dw	wave_Pulse
	dw	wave_OctSquare
	dw	wave_CharSelBass

wave_Pulse:			db	$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
wave_OctSquare:		db	$ff,$ff,$ff,$ff,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$00,$00,$00,$00
wave_CharSelBass:	db	$9c,$ef,$eb,$74,$10,$13,$69,$ce,$fe,$b7,$41,$01,$36,$9f,$a5,$06


; use $c0 to use the wave buffer
waveseq_Pulse:			db	0,$ff
waveseq_Pulse50:		db	2,$ff

waveseq_BurbsArp:		db	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,$ff
waveseq_BurbsLead:		db	1,1,1,1,1,1,0,$ff
waveseq_BurbsSlide:		db	1,$ff
waveseq_BurbsFade:		db	0,$ff
waveseq_CharSelArp:		db	0,0,1,1,1,2,2,2,3,3,3,2,2,2,1,1,1,0,$fe,0

;waveseq_CharSelBass:	db	2,$ff	; use waveseq_Pulse50 instead
waveseq_CharSelLead:	db	0,1,2,$ff

; =================================================================
; Vibrato sequences
; Must be terminated with a loop command!
; =================================================================

vib_Test:			db	4,2,4,6,8,6,4,2,0,-2,-4,-6,-8,-6,-4,-2,0,$80,1
vib_BurbsLeadC:		db	1,-1,-1,-1,0,0,0,0,0,$80,1

vib_BurbsLead:		db	8,2,4,2,0,-2,-4,-2,0,$80,1
vib_BurbsFade:		db	0,2,4,2,0,-2,-4,-2,0,$80,1

vib_LoseHorn:		db	0,6,12,18,24,30,24,18,12,6,0,-6,-12,-18,-24,-30,-24,-18,-12,-6,0,$80,1

; =================================================================
; Instruments
; =================================================================

InstrumentTable:
	const_def
	dins	Kick
	dins	Snare
	dins	CHH
	dins	OHH
	dins	CymbQ
	dins	CymbL
	dins	Tom
	dins	Tink
	
	dins	BurbsLeadC
	dins	BurbsFadeC
	dins	BurbsLead
	dins	BurbsLeadSlide
	dins	BurbsFade
	dins	BurbsArp
	dins	BurbsBass
	dins	BurbsBassL
	dins	BurbsTom
	
	dins	CharSelBass
	dins	CharSelLead
	dins	CharSelLead8
	dins	CharSelLead4
	dins	CharSelLead2
	dins	CharSelLead1
	dins	CharSelLeadC
	dins	CharSelArp

	dins	LoseHorn
	dins	LoseHorn2

; Instrument format: [no reset flag],[voltable id],[arptable id],[wavetable id],[vibtable id]
; _ for no table
; !!! REMEMBER TO ADD INSTRUMENTS TO THE INSTRUMENT POINTER TABLE !!!
ins_Kick:			Instrument	0,Kick,Kick,_,_
ins_Snare:			Instrument	0,Snare,Snare,_,_
ins_CHH:			Instrument	0,Kick,Hat,_,_
ins_OHH:			Instrument	0,OHH,Hat,_,_
ins_CymbQ:			Instrument	0,CymbQ,Hat,_,_
ins_CymbL:			Instrument	0,CymbL,Hat,_,_
ins_Tom:			Instrument	0,Tom,Tom,Pulse50,_
ins_Tink:			Instrument	0,Tink,Tink,Pulse50,_

ins_BurbsLeadC		Instrument	0,BurbsLeadC,_,Pulse50,BurbsLeadC
ins_BurbsFadeC		Instrument	0,BurbsFadeC,_,Pulse50,BurbsLeadC
ins_BurbsLead		Instrument	0,BurbsLead,BurbsHack,BurbsLead,BurbsLead
ins_BurbsLeadSlide	Instrument	0,BurbsSlide,BurbsSlide1,BurbsSlide,_
ins_BurbsFade		Instrument	0,BurbsFade,_,BurbsFade,BurbsFade
ins_BurbsArp		Instrument	0,BurbsArp,Buffer,BurbsArp,_
ins_BurbsBass		Instrument	0,BurbsBass,Pluck,Pulse,_
ins_BurbsBassL		Instrument	0,BurbsBassL,Pluck,Pulse,_
ins_BurbsTom		Instrument	0,BurbsBass,Tom,BurbsSlide,_

ins_CharSelBass		Instrument	0,CharSelBass,Pluck,Pulse50,_
ins_CharSelLead		Instrument	0,CharSelLead,_,CharSelLead,_
ins_CharSelLead8	Instrument	0,CharSelLead8,_,CharSelLead,_
ins_CharSelLead4	Instrument	0,CharSelLead4,_,CharSelLead,_
ins_CharSelLead2	Instrument	0,CharSelLead2,_,CharSelLead,_
ins_CharSelLead1	Instrument	0,CharSelLead1,_,CharSelLead,_
ins_CharSelLeadC	Instrument	0,CharSelLeadC,_,CharSelLead,_
ins_CharSelArp		Instrument	0,CharSelArp,Buffer,CharSelArp,_

ins_LoseHorn		Instrument	0,LoseHorn,_,BurbsSlide,LoseHorn
ins_LoseHorn2		Instrument	0,LoseHorn,_,Pulse,LoseHorn
	
; =================================================================

PT_ScootTheBurbs:	dw	Burbs_CH1,Burbs_CH2,Burbs_CH3,Burbs_CH4

Burbs_CH1:
	db	SetLoopPoint
	rept	2
	dbw	CallSection,.block2
	db	SetInstrument,id_BurbsLead,rest,2
	db	B_3,2,D#4,1,D#4,1,D#4,1,D#4,3,D#4,2,D#4,2,D#4,2,B_3,2,SetInstrument,id_BurbsFade,B_3,14
	dbw	CallSection,.block2
	db	SetInstrument,id_BurbsLead,rest,2
	db	B_3,2,D#4,2,D#4,1,D#4,3,D#4,2,D#4,2,D#4,2,B_3,2,SetInstrument,id_BurbsFade,B_3,18
	dbw	CallSection,.block3
	endr
	db	B_3,64
	
	db	SetInstrument,id_BurbsLeadC
	db	rest,4
	dbw	CallSection,.block1
	db	C#5,3,SetInstrument,id_BurbsFadeC,C#5,8,SetInstrument,id_BurbsLeadC
	db	C#5,2,B_4,1,A#4,1,F#4,3,SetInstrument,id_BurbsFadeC,F#4,6,SetInstrument,id_BurbsLeadC
	db	B_4,1,SetInsAlternate,id_BurbsFadeC,id_BurbsLeadC
	db	C#5,1,C#5,1,D#5,1,D#5,1,E_5,1,E_5,1,D#5,1,D#5,1,C#5,1,C#5,1,B_4,3,B_4,9
	db	SetInstrument,id_BurbsLeadC,B_4,1
	dbw	CallSection,.block1
	db	C#5,3,SetInstrument,id_BurbsFadeC,C#5,6,SetInsAlternate,id_BurbsFadeC,id_BurbsLeadC,B_4,2,B_4,1
	db	C#5,2,C#5,2,B_4,2,B_4,2,A#4,2,A#4,2,SetInstrument,id_BurbsLeadC
	db	A#4,1,B_4,1,C#5,1,D#5,2,E_5,1,D#5,1,C#5,2,SetInstrument,id_BurbsFadeC,C#5,1
	db	SetInstrument,id_BurbsLeadC,B_4,3,SetInstrument,id_BurbsFadeC,B_4,7
	
	db	SetInsAlternate,id_BurbsFade,id_BurbsLead
	db	C#4,1,C#4,1,C#4,1,C#4,1,C#4,1,C#4,1,C#4,1
	db	SetInsAlternate,id_BurbsLead,id_BurbsFade
	db	D#4,2,D#4,1,D#4,1,D#4,1,D#4,1,D#4,1,D#4,1
	db	SetInsAlternate,id_BurbsFade,id_BurbsLead
	db	F#4,2,F#4,1,E_4,1,E_4,1,SetInstrument,id_BurbsLead
	db	D#4,1,E_4,1,D#4,1,B_3,11
	db	SetInstrument,id_BurbsLeadSlide,E_3,2
	db	SetInstrument,id_BurbsLead
	db	B_3,1,SetInsAlternate,id_BurbsFade,id_BurbsLead
	db	A#3,1,A#3,1,B_3,1,B_3,1,A#3,1,A#3,1,B_3,1,B_3,1,A#3,1,A#3,1
	db	SetInstrument,id_BurbsLead,F#3,17
	db	GotoLoopPoint
	
.block1
	db	B_4,1,C#5,1,D#5,1,D#5,1,SetInstrument,id_BurbsFadeC,D#5,1,SetInstrument,id_BurbsLeadC
	db	D#5,1,C#5,1,B_4,1,SetInstrument,id_BurbsFadeC,B_4,1,SetInstrument,id_BurbsLeadC,C#5,1,D#5,1,SetInstrument,id_BurbsFadeC,D#5,1,SetInstrument,id_BurbsLeadC
	db	D#5,2,SetInstrument,id_BurbsFadeC,D#5,1,SetInstrument,id_BurbsLeadC,C#5,1
	ret
	
.block2
	rept	2
	db	SetInstrument,id_BurbsLead,F#4,3,D#4,3,C#4,4,SetInstrument,id_BurbsFade,C#4,6
	endr
	ret

.block3
	db	SetInstrument,id_BurbsLead
	db	D#4,1,D#4,2,D#4,3,D#4,2,D#4,1,D#4,2,D#4,3,B_3,2,SetInstrument,id_BurbsFade,B_3,16
	db	SetInstrument,id_BurbsLead
	db	D#4,1,D#4,2,D#4,3,D#4,2,D#4,2,B_3,2,D#4,5,E_4,1,D#4,1,C#4,4,C#4,1,B_3,2,A#3,2
	ret
	
Burbs_CH2:
	db	SetInstrument,id_BurbsArp
	db	SetLoopPoint
	rept	2
	dbw	CallSection,.block1
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	endr
	rept	3
	dbw	CallSection,.block1
	endr
	dbw	CallSection,.block2
	db	GotoLoopPoint
	
.block1
	db	Arp,1,$38,D#4,2,D#4,2,D#4,2,D#4,2,D#4,2,D#4,2,D#4,1,D#4,2
	db	Arp,1,$59,B_3,3,B_3,2,B_3,2,B_3,2,B_3,2,B_3,2,B_3,1,B_3,2
	db	Arp,1,$5a,C#4,3,C#4,2,C#4,1,C#4,2,Arp,1,$59,C#4,3,C#4,2,C#4,2,C#4,2
	db	Arp,1,$47,E_4,2,E_4,2,E_4,1,E_4,2,E_4,3,E_4,2,E_4,2,E_4,1,E_4,1
	ret
	
.block2
	db	Arp,1,$38,A#3,2,A#3,2,A#3,1,A#3,2,A#3,3,A#3,2,A#3,2,A#3,2
	db	G#3,2,G#3,2,G#3,1,G#3,2,G#3,3,G#3,2,G#3,2,G#3,2
	db	A#3,2,A#3,2,A#3,1,A#3,2,A#3,3,A#3,2,A#3,2,A#3,2
	db	Arp,1,$47,E_4,2,E_4,2,E_4,1,E_4,2,Arp,1,$5a,C#4,2,C#4,2,C#4,1,Arp,1,$59,C#4,2,C#4,2
	ret
	

Burbs_CH3:
	db	SetInstrument,id_BurbsBass,SetLoopPoint
	rept	2
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	dbw	CallSection,.block2
	dbw	CallSection,.block4
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	endr
	
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	dbw	CallSection,.block1
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	dbw	CallSection,.block2
	dbw	CallSection,.block4
	dbw	CallSection,.block2
	dbw	CallSection,.block3
	db	GotoLoopPoint
	
.block1
	db	B_2,1,B_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,B_2,2,SetInstrument,id_BurbsBass,B_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,B_2,1
	db	B_2,1,B_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,B_2,2,SetInstrument,id_BurbsBass,B_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,B_2,1
	db	G#2,1,G#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,G#2,2,SetInstrument,id_BurbsBass,G#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,G#2,1
	db	G#2,1,G#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,G#2,2,SetInstrument,id_BurbsBass,G#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,G#2,1
	ret

.block2
	db	SetInstrument,id_BurbsBass,F#2,1,F#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,F#2,2,SetInstrument,id_BurbsBass,F#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,F#2,1
	db	F#2,1,F#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,F#2,2,SetInstrument,id_BurbsBass,F#2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,F#2,1
	ret
	
.block3
	db	E_3,1,E_3,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,E_3,2,SetInstrument,id_BurbsBass,E_3,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,E_3,1
	db	E_3,1,E_3,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,D#3,2,SetInstrument,id_BurbsBass,C#3,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,B_2,1
	ret
	
.block4
	db	SetInstrument,id_BurbsBass,E_2,1,E_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,E_2,2,SetInstrument,id_BurbsBass,E_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,E_2,1
	db	E_2,1,E_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBassL,E_2,2,SetInstrument,id_BurbsBass,E_2,1
	Drum	BurbsTom,1
	db	SetInstrument,id_BurbsBass,E_2,1
	ret
	
Burbs_CH4:
	db	SetLoopPoint
	rept	3
	dbw	CallSection,.block1
	endr
	Drum	Kick,1
	Drum	CHH,1
	Drum	Snare,2
	Drum	Kick,1
	db	fix,1
	Drum	Snare,2
	Drum	Kick,1
	db	fix,1
	Drum	Snare,1
	Drum	Kick,1
	Drum	CHH,1
	Drum	Kick,1
	Drum	Snare,1
	db	fix,1
	db	GotoLoopPoint
	
.block1
	Drum	Kick,1
	Drum	CHH,1
	Drum	Snare,2
	Drum	Kick,1
	db	fix,1
	Drum	Snare,2
	Drum	Kick,1
	db	fix,1
	Drum	Snare,1
	Drum	Kick,1
	Drum	CHH,1
	Drum	Kick,1
	Drum	Snare,2
	ret
; =================================================================

PT_CharacterSelect:	dw	CharSel_CH1,CharSel_CH2,CharSel_CH3,CharSel_CH4

CharSel_CH1:
	; intro
	db	SetInstrument,id_CharSelLead,B_4,2,D_5,2,E_5,2,F#5,2,A_5,2,F#5,2,SetLoopPoint	
	; loop
	dbw	CallSection,.block1
	db	SetInstrument,id_CharSelLead8
	dbw	CallSection,.block1
	db	SetInstrument,id_CharSelLead4
	dbw	CallSection,.block1
	db	SetInstrument,id_CharSelLead2
	dbw	CallSection,.block1
	db	SetInstrument,id_CharSelLead1
	dbw	CallSection,.block1
	db	rest,30
	db	SetInstrument,id_CharSelLeadC
	db	A_4,2,rest,2,SetInstrument,id_CharSelLead,A_4,2
	
	dbw	CallSection,.block2
	db	SetInstrument,id_CharSelLead8
	dbw	CallSection,.block2
	db	SetInstrument,id_CharSelLead4
	dbw	CallSection,.block2
	db	SetInstrument,id_CharSelLead2
	dbw	CallSection,.block2
	db	SetInstrument,id_CharSelLead1
	dbw	CallSection,.block2
	db	SetInstrument,id_CharSelLead
	db	rest,66
	db	GotoLoopPoint
	
.block1
	db	B_5,6,PitchBendDown,$10,rel,6,PitchBendDown,0
	ret
.block2
	db	B_4,3,rest,3
	ret

CharSel_CH2:
	; intro
	db	SetInstrument,id_Tom
	db	fix+11,2
	db	fix+11,2
	db	fix+11,2
	db	fix+7,2
	db	fix+7,2
	db	fix+7,2
	db	SetLoopPoint
	; loop
	dbw	CallSection,.block1
	dbw	CallSection,.block1
	dbw	CallSection,.block1
	db	SetInstrument,id_Tink,fix,4,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$37,B_3,6
	Drum	Tom,4
	db	SetInstrument,id_Tink,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$47,D_4,6
	dbw	CallSection,.block1
	dbw	CallSection,.block1
	dbw	CallSection,.block1
	db	SetInstrument,id_Tink,fix,4,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$37,B_3,6
	Drum	Tom,4
	db	SetInstrument,id_Tink,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$47,A_3,6
	db	GotoLoopPoint
	
.block1
	db	SetInstrument,id_Tink,fix,4,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$37,B_3,6
	Drum	Tom,4
	db	SetInstrument,id_Tink,fix,2
	db	SetInstrument,id_CharSelArp,Arp,1,$37,B_3,6
	ret
	
CharSel_CH3:
	db	SetInstrument,id_CharSelBass
	; intro
	db	B_3,2,A_3,2,F#3,2,E_3,2,D_3,2,A_2,2,SetLoopPoint
	; loop
	dbw	CallSection,.block1
	db	E_3,4,B_2,2,D_3,2,PitchBendUp,4,___,4,PitchBendUp,0
	dbw	CallSection,.block1
	db	D_3,4,B_2,2,A_2,4,A#2,2
	db	GotoLoopPoint
	
.block1
	db	B_2,6,A_2,6,F#2,4,A_2,6,B_2,6,B_2,2,D_3,4,B_2,2
	ret

CharSel_CH4:
	; intro
	Drum	Snare,2
	rept	5
	db	fix,2
	endr
	; loop
	db	SetLoopPoint
	dbw	CallSection,.block1
	Drum	OHH,2
	dbw	CallSection,.block1
	Drum	Snare,2
	db	GotoLoopPoint
	
.block1
	Drum	Kick,4
	Drum	CHH,2
	Drum	Kick,4
	db	fix,2
	Drum	Snare,4
	Drum	CHH,2
	Drum	OHH,4
	Drum	Kick,2
	Drum	CHH,4
	Drum	Kick,2
	db	fix,4
	Drum	CHH,2
	Drum	Snare,4
	Drum	CHH,2
	Drum	Kick,4
	ret
; =================================================================

PT_LoseHorn:	dw	LoseHorn_CH1,LoseHorn_CH2,DummyChannel,DummyChannel

LoseHorn_CH1:

	db	SetInstrument,id_LoseHorn
	db	B_4,4,rest,2,G#4,2,rest,2,C#5,2,B_4,4,rest,2,G#4,4,rest,2
	db	EndChannel
	
LoseHorn_CH2:
	db	SetInstrument,id_LoseHorn2
	db	A#4,4,rest,2,G_4,2,rest,2,C_5,2,A#4,4,rest,2,G_4,4,rest,2
	db	EndChannel
