;List waveforms required for build
;
;begin-waves
; silent
; kick
; snare
; nzz1
; nzz0
;end-waves


;Sounds a bit like Are 'Friends' Electric? by Gary Numan
;or at least it has many of the same notes in a similar order...


; Select channels to be configured as variable duty
CYD_C1_PULSE	equ 0
CYD_C2_PULSE	equ 1
CYD_C3_PULSE	equ 1


	; music data helper macros
	include	"cyd_macros.s"


envelope_1
	fcb 40,60,0

envelope_0	equ *-1
;	fcb	0

envelope_2
	fcb 40,0

envelope_3
	fcb 40,50,50,50,50,30,0

envelope_4
	fcb 60,0

envelope_5
	fcb 80,0

envelope_6
	fcb 30,0

envelope_hhat	fcb	nzz0>>8,0
envelope_kick	fcb	kick>>8,0
envelope_snare	fcb	snare>>8,0
envelope_snare2	fcb	nzz0>>8,0
envelope_silent	fcb	silent>>8,0


patch_table

patch_0
	fcb	0
	fdb	envelope_0,envelope_0
patch_1
	fcb	24
	fdb	envelope_1,envelope_2
patch_2
	fcb	6
	fdb	envelope_3,envelope_0
patch_3
	fcb	4
	fdb	envelope_kick,envelope_silent
patch_4
	fcb	6
	fdb	envelope_snare,envelope_snare2
patch_5
	fcb	2
	fdb	envelope_hhat,envelope_silent
patch_6
	fcb	1
	fdb	envelope_6,envelope_0
patch_7
	fcb	1
	fdb	envelope_4,envelope_0
patch_8
	fcb	1
	fdb	envelope_5,envelope_0


; basic note length
n1	equ	8

mskip	macro
	;_jump	30f
	endm

tune0_c3

1	;fcb	silence,n1*16
	;_jump 1b

	_setplscfg	CYD_DUTY_RESET,96,128
	_setplsduty 	64,2

	_setpatch	2

	mskip

	fcb	silence,n1*16
	fcb	silence,n1*16
	_call	bass_1
	_call	bass_1
	_call	bass_1
	_call	bass_1
	_call	bass_1
10
	_call	bass_2
	_call	bass_2
15
	_call	port_part

	_setpatch	2
	_setplscfg	CYD_DUTY_RESET,96,128
	_setplsduty 	64,2

	_call	bass_1
	_call	bass_1
	_call	bass_1
	_call	bass_1

	_call	bass_2
	_call	bass_2
20
	_setpatch	7
	_setplsduty 	128,4
	_call	bass_3
	_call	bass_3
	_call	bass_3
	_call	bass_3
	_call	bass_3
	_call	bass_3
30
	_setpatch	8
	_setplscfg	CYD_DUTY_RESET,64,96
	_setplsduty 	64,2
	_call	bass_4
	_call	bass_4
	_call	bass_4
	_call	bass_4

	_jump 15b

bass_1
	fcb	c2,n1*2
	fcb	c2,n1*6
	fcb	as1,n1*2
	fcb	as1,n1*6

	fcb	c2,n1*2
	fcb	c2,n1*6
	fcb	as1,n1*2
	fcb	as2,n1*2
	fcb	e2,n1*2
	fcb	g2,n1*2

	_return

bass_2
	fcb	f1,n1*2
	fcb	f1,n1*5
	fcb	f1,n1
	fcb	f1,n1*2
	fcb	f1,n1*5
	fcb	f1,n1
	fcb	f1,n1*2
	fcb	f1,n1*5
	fcb	f1,n1
	fcb	f1,n1*2
	fcb	f1,n1*5
	fcb	f1,n1
	_return

bass_3
	fcb	g1,n1*2
	fcb	d2,n1*2
	fcb	f2,n1*2
	fcb	d2,n1*4

	fcb	a2,n1*2
	fcb	c3,n1*2
	fcb	a2,n1*2

	fcb	f1,n1*2
	fcb	c2,n1*2
	fcb	e2,n1*2
	fcb	c2,n1*4

	fcb	g2,n1*2
	fcb	c3,n1*2
	fcb	b2,n1*2

	_return

bass_4
	fcb	g1,n1*8
	fcb	f1,n1*8
	fcb	c2,n1*16
	_return

port_part
	_setpatch	6
	_setplscfg	CYD_DUTY_NORST,32,224
	_setplsduty 	32,3

	_portamento	c4,f_c4,f_c5,n1*4
	_setnote	c5,n1*12
	_rest	n1*12

	_portamento	c5,f_c5,f_c4,n1*4
	_setnote	c4,n1*12
	_rest		n1*16

	_portamento	c4,f_c4,f_c3,n1*4

	_return

tune0_c2

1	;fcb	silence,n1*16
	;_jump 1b

	_setpatch 1
	_setplscfg	CYD_DUTY_RESET,160,192
	_setplsduty	128,4

	mskip

	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1
10
	_call	part_2
	_call	part_2
15
	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1
	_call	part_1

	_call	part_2
	_call	part_2
20
	_call	part_3
	_call	part_3
	_call	part_3
	_call	part_3
	_call	part_3
	_call	part_3
30
	_setplscfg	CYD_DUTY_NORST,32,220
	_setplsduty	128,7
	_call	part_4
	_call	part_4
	_call	part_4
	_call	part_4

	_setplscfg	CYD_DUTY_RESET,160,192
	_setplsduty	128,4

	_jump 15b

part_1
	fcb	c2,n1*4
	fcb	g2,n1*4
	fcb	as1,n1*4
	fcb	f2,n1*4

	fcb	c2,n1*4
	fcb	g2,n1*4
	fcb	as1,n1*4
	fcb	as3,n1*2
	fcb	e3,n1*2

	_return

part_2
	fcb	f2,n1*2
	fcb	f2,n1*2
	fcb	e3,n1*2
	fcb	c3,n1*2

	fcb	f2,n1*2
	fcb	f2,n1*2
	fcb	f3,n1*2
	fcb	c3,n1*2

	fcb	f2,n1*2
	fcb	f2,n1*2
	fcb	g3,n1*2
	fcb	c3,n1*2

	fcb	f2,n1*2
	fcb	f2,n1*2
	fcb	a3,n1*2
	fcb	c3,n1*2

	_return


part_3
	fcb	g3,n1*2
	fcb	d4,n1*2
	fcb	f4,n1*2
	fcb	d4,n1*2

	fcb	d3,n1*2
	fcb	a3,n1*2
	fcb	c4,n1*2
	fcb	a3,n1*2

	fcb	f3,n1*2
	fcb	c4,n1*2
	fcb	e4,n1*2
	fcb	c4,n1*2

	fcb	c3,n1*2
	fcb	g3,n1*2
	fcb	c4,n1*2
	fcb	b3,n1*2

	_return


part_4
	fcb	g3,n1*2
	fcb	d4,n1*2
	fcb	g4,n1*2
	fcb	f4,n1*4

	;fcb	f3,n1*2
	fcb	c4,n1*2
	fcb	f4,n1*2
	fcb	e4,n1*4

	;fcb	c3,n1*2
	fcb	g3,n1*2
	fcb	c4,n1*2
	fcb	b3,n1*2

	fcb	c4,n1*2
	fcb	b3,n1*2
	fcb	c4,n1*2
	fcb	b3,n1*2

	_return


tune0_c1

1	;_silence	n1*16
	;_silence	n1*16
	_silence	n1*16
	;_jump 1b
	_silence	n1*8
	_call	drum_2

1

	_call	drum_1
	_call	drum_1
	_call	drum_1
	_call	drum_1b
	;_call	drum_1
	;_call	drum_2

	_jump 1b


f_kick	equ	c0-3
f_snare	equ	128

drum_1
	_setpatch	3
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*1

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1

	_return

drum_1b
	_setpatch	3
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*1

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1

	_return

drum_2
	;_silence	n1*2

	_setpatch	4
	_startsmp	f_snare,n1*2
	_startsmp	f_snare,n1*2
	_startsmp	f_snare,n1*1
	_startsmp	f_snare,n1*1
	_startsmp	f_snare,n1*2

	_return


