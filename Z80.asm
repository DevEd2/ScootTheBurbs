; ======================================
; Equivalent macros for Z80 instructions
; ======================================

cpd:	macro
	cp	[hl]
	dec	hl
	dec	bc
	endm
	
cpi:	macro
	cp	[hl]
	inc	hl
	dec	bc
	endm
	
djnz:	macro
	dec	b
	jr	nz,\1
	endm
	
exx_toShadow:	macro
	; WARNING: Stack abuse!
	ld	[tempSP],sp
	ld	sp,tempHL2+2
	push	hl
	push	de
	push	bc
	ld	sp,tempBC
	pop	bc
	pop	de
	pop	hl
	ld	sp,tempHL3+2
	push	hl
	ld	sp,tempSP
	pop	hl
	ld	sp,hl
	ld	a,[tempHL3]
	ld	l,a
	ld	a,[tempHL3+1]
	ld	h,a
	endm
	
exx_toNormal:	macro
	; WARNING: Stack abuse!
	ld	[tempSP],sp
	ld	sp,tempHL+2
	push	hl
	push	de
	push	bc
	ld	sp,tempBC2
	pop	bc
	pop	de
	pop	hl
	ld	sp,tempHL3+2
	push	hl
	ld	sp,tempSP
	pop	hl
	ld	sp,hl
	ld	a,[tempHL3]
	ld	l,a
	ld	a,[tempHL3+1]
	ld	h,a
	endm

ini:	macro
	ld	a,[c]
	ld	[hl+],a
	dec	b
	endm
	
ind:	macro
	ld	a,[c]
	ld	[hl-],a
	dec	 b
	endm

inir:	macro
.inirLoop
	ld	a,[c]
	ld	[hl+],a
	dec	b
	jr	nz,.indrLoop
	endm

indr:	macro	; TODO: Make it so this can be used multiple times per routine
.indrLoop
	ld	a,[c]
	ld	[hl-],a
	dec	b
	jr	nz,.indrLoop
	endm

lddr:	macro
.lddrLoop
	ld	a,[hl-]
	ld	[de],a
	dec	bc
	dec	de
	ld	a,b
	or	c
	jr	nz,.lddrloop
	endm
	
neg:	macro
	cpl
	inc	a
	endm
	