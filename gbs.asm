SECTION "GBS Header", ROM0[$3f90]
	db	"GBS"											; signature
	db	1												; version
	db	(SongPointerTable_End-SongPointerTable)/2		; number of songs
	db	1												; first song
	dw	$4000											; load address
	dw	DS_Init											; init address
	dw	DS_Play											; play address
	dw	$fffe											; stack pointer
	db	0,0												; timer values
GBS_TitleText:
	db "Scoot the Burbs"
rept GBS_TitleText - @ + 32
	db	0												; if ds is used, $ff will be filled instead 
endr
GBS_AuthorText:
	db "DevEd"
rept GBS_AuthorText - @ + 32
	db	0
endr
GBS_CopyrightText:
	db "2018 Devsoft"
rept GBS_CopyrightText - @ + 32
	db	0
endr
