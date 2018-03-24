;List waveforms required for build
;
;begin-waves
; silent
; kick
; snare
; nzz1
; nzz0
;end-waves

; Select channels to be configured as variable duty
CYD_C1_PULSE	equ 0
CYD_C2_PULSE	equ 1
CYD_C3_PULSE	equ 1


	; music data helper macros
	include	"cyd_macros.s"


envelope_1
	fcb 30,40,40,40,40,40,40,40,30,20,0

envelope_0	equ *-1
;	fcb	0

envelope_2
	fcb 40,60,60,60,60,25,0

envelope_3
	fcb 20,30,30,30,30,13,0

envelope_4
	fcb 40,0

envelope_hhat	fcb	nzz1>>8,0
envelope_kick	fcb	kick>>8,0
envelope_snare	fcb	snare>>8,0
envelope_snare2	fcb	nzz0>>8,0
envelope_silent	fcb	silent>>8,0


patch_table

patch_0
	fcb	0
	fdb	envelope_0,envelope_0
patch_1
	fcb	10
	fdb	envelope_1,envelope_0
patch_2
	fcb	6
	fdb	envelope_2,envelope_0
patch_3
	fcb	4
	fdb	envelope_kick,envelope_silent
patch_4
	fcb	6 ;7
	fdb	envelope_snare,envelope_snare2
	;fdb	envelope_snare,envelope_silent
patch_5
	fcb	2
	fdb	envelope_hhat,envelope_silent
patch_6
	fcb	6
	fdb	envelope_3,envelope_0
patch_7
	fcb	1
	fdb	envelope_4,envelope_0


; basic note length
n1	equ	6


tune0_c3

1	;fcb	silence,n1*16
	;_jump 1b

	_setplscfg	CYD_DUTY_NORST,0,255
	_setplsduty 	64,1

	_setpatch	7
	fcb	a2,n1*16
	fcb	a2,n1*16
	fcb	a2,n1*16
	_setport	10
	fcb	a2,n1*16
	_setport	0

	_setpatch	2
	_setplscfg	CYD_DUTY_RESET,128,160
	_setplsduty 	64,4
1
	_call	bass_main

	_jump 1b



bass_main
	fcb	a2,n1*2
	fcb	a2,n1
	fcb	a2,n1
	fcb	a2,n1*2
	fcb	a2,n1*2
	fcb	a2,n1
	fcb	a2,n1
	fcb	a2,n1*2
	fcb	g2,n1*2
	fcb	a2,n1*2

	fcb	a2,n1*2
	fcb	a2,n1
	fcb	a2,n1
	fcb	a2,n1*2
	fcb	a2,n1*2
	fcb	c3,n1*2
	fcb	b2,n1*2
	fcb	g2,n1
	fcb	a2,n1
	fcb	a2,n1*2

	_return



tune0_c2

1	;fcb	silence,n1*16
	;_jump 1b

	_setpatch 7
	_setplscfg	CYD_DUTY_NORST,0,255
	_setplsduty	128,1
	_call	lead_drone

1	
	_setpatch 1
	_setplscfg	CYD_DUTY_NORST,96,223
	_setplsduty	128,8

	_loop	4
	_call	lead_main
	_next

	_setpatch 7
	_setplscfg	CYD_DUTY_NORST,0,255
	_setplsduty	128,1

	_call	lead_drone
	_call	lead_drone

	_setpatch 1

	_settp	-12
	_loop	4
	_call	lead_main
	_next

	_settp	0

	_setpatch 7

	_call	lead_drone
	_call	lead_drone

	_jump 1b


lead_main
	fcb	a4,n1*3
	fcb	a4,n1*3
	fcb	a4,n1*3
	fcb	a4,n1*3
	fcb	g4,n1*2
	fcb	a4,n1*2

	fcb	e4,n1*2
	fcb	e4,n1
	fcb	e4,n1
	fcb	e4,n1*2
	fcb	g4,n1*2
	fcb	c5,n1
	fcb	g4,n1
	fcb	c5,n1*2
	fcb	e4,n1*2
	fcb	g4,n1*2

	_return


lead_drone
	fcb	a1,n1*16
	fcb	a1,n1*16
	fcb	a1,n1*16
	fcb	a1,n1*16
	_return

tune0_c1

1	;_silence	n1*16
	;_jump 1b

	_call	drum_1
	_call	drum_1
	_call	drum_1
	_call	drum_3
1

	_call	drum_1
	_call	drum_1
	_call	drum_1
	_call	drum_2
	_call	drum_1
	_call	drum_1
	_call	drum_1
	_call	drum_3

	_jump 1b


f_kick	equ	c0-3
f_snare	equ	128

drum_1
	_setpatch	3
	_startsmp	f_kick,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_return

drum_2
	_setpatch	3
	_startsmp	f_kick,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1
	_startsmp	f_snare,n1*2
	_startsmp	f_snare,n1

	_return

drum_3
	_setpatch	3
	_startsmp	f_kick,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	5
	fcb	c0,n1*1
	fcb	c0,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	5
	fcb	c0,n1*1

	_setpatch	4
	_startsmp	f_snare,n1
	_startsmp	f_snare,n1
	_startsmp	f_snare,n1
	_startsmp	f_snare,n1

	_return

