; ================================================================
; System routines
; ================================================================

; ================================================================
; Clear work RAM
; ================================================================

ClearWRAM:
	ld	hl,$c000	
	ld	bc,$1ff0	; don't clear the stack
	jr	ClearLoop	; routine continues in ClearLoop
	
; ================================================================
; Clear video RAM
; ================================================================

ClearVRAM:
	ld	hl,$8000
	ld	bc,$2000
	; routine continues in ClearLoop

; ================================================================
; Clear a section of RAM
; ================================================================
	
ClearLoop:
	xor	a
	ld	[hl+],a
	dec	bc
	ld	a,b
	or	c
	jr	nz,ClearLoop
	ret
	
; ================================================================
; Check joypad input
; ================================================================

CheckInput:
	ld	a,P1F_5
	ld	[rP1],a
	ld	a,[rP1]
	ld	a,[rP1]
	cpl
	and	a,$f
	swap	a
	ld	b,a
	
	ld	a,P1F_4
	ld	[rP1],a
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	cpl
	and	a,$f
	or	a,b
	ld	b,a
	
	ld	a,[sys_btnHold]
	xor	a,b
	and	a,b
	ld	[sys_btnPress],a
	ld	a,b
	ld	[sys_btnHold],a
	ld	a,P1F_5|P1F_4
	ld	[rP1],a
	ret

; ================================================================
; Draw hexadecimal number A at HL
; ================================================================

DrawHex:
	push	af
	swap	a
	call	.loop1
	pop	af
.loop1
	and	$f
	cp	$a
	jr	c,.loop2
	add	a,$7
.loop2
	add	a,$10
	push	af
	ldh	a,[rSTAT]
	and	2
	jr	nz,@-4
	pop	af
	ld	[hl+],a
	ret
	
DrawHexDigit:
	and	$f
	cp	$a
	jr	c,.carry
	add	a,$7
.carry
	add	a,$10
	push	af
	ldh	a,[rSTAT]
	and	2
	jr	nz,@-4
	pop	af
	ld	[hl+],a
	ret

; ================================================================
; Load a text tilemap
; ================================================================

LoadMapText:
	ld	de,_SCRN0
	ld	bc,$1214
LoadMapText_loop:
	ld	a,[hl+]
	sub 32	
	ld	[de],a
	inc	de
	dec	c
	jr	nz,LoadMapText_loop
	ld	c,$14
	ld	a,e
	add	$c
	jr	nc,.continue
	inc	d
.continue
	ld	e,a
	dec	b
	jr	nz,LoadMapText_loop
	ret
	
; ================================================================
; Get a pointer from a table
; Input:  hl = pointer table
;          a = offset
; Output: hl = pointer
; ================================================================
	
GetPointerFromTable:
	add	a
	add	l
	ld	l,a
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	ret
