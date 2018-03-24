;List waveforms required for build
;
;begin-waves
; silent
; kick
; snare
;end-waves

; Select channels to be configured as variable duty
CYD_C1_PULSE	equ 0
CYD_C2_PULSE	equ 1
CYD_C3_PULSE	equ 1


	; music data helper macros
	include	"cyd_macros.s"


envelope_1
	fcb 65,85,85,85,85,50,0

envelope_0	equ *-1
;	fcb	0

envelope_2
	fcb 40,60,60,60,60,35,0


envelope_kick	fcb	kick>>8,0
envelope_snare	fcb	snare>>8,0
envelope_silent	fcb	silent>>8,0


patch_table

patch_0
	fcb	0
	fdb	envelope_0,envelope_0
patch_1
	fcb	8
	fdb	envelope_1,envelope_0
patch_2
	fcb	4
	fdb	envelope_2,envelope_0
patch_3
	fcb	4
	fdb	envelope_kick,envelope_silent
patch_4
	fcb	7
	fdb	envelope_snare,envelope_silent



; basic note length
n1	equ	8


tune0_c3

	_silence	n1*16
	_silence	n1*16
	_silence	n1*16
	_silence	n1*16

	_setpatch	1
	_setplscfg	CYD_DUTY_RESET,0,0
	_setplsduty 	112,2
1
	;_silence	n1*16
	;_jump 1b

	_call	bass_main
	_call	bass_main
	_call	bass_main
	_call	bass_2

	_call	bass_main
	_call	bass_main

	_jump 1b



bass_main
	fcb	b1,n1*2
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1
	fcb	e2,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	d2,n1

	_return

bass_2
	fcb	e2,n1*2
	fcb	e2,n1*2
	fcb	d2,n1
	fcb	f2,n1
	fcb	g2,n1
	fcb	e2,n1*2

	fcb	e2,n1*2
	fcb	g2,n1
	fcb	b2,n1*2
	fcb	e2,n1*2
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	a1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1*2
	fcb	b1,n1
	fcb	d2,n1*2
	fcb	a1,n1*2

	_return



tune0_c2
	_setpatch 2

1	;_silence	n1*16
	;_jump 1b

	_setplscfg	CYD_DUTY_RESET,128,160
	_setplsduty	32,6
	_calltp		24,lead_main
	_setplscfg	CYD_DUTY_RESET,240,250
	_setplsduty	128,8
	_call		lead_main
1
	
	_setplsduty	64,3
	_calltp		24,lead_main

	_setplsduty	128,8
	_call		lead_main

	_setplsduty	32,4
	_call		lead_main

	_setplscfg	CYD_DUTY_NORST,0,255
	_setplsduty	16,3
	_setport	-1
	_calltp		12,bass_2
	_setport	0

	_settp		0

	fcb		b3,n1*16
	fcb		rest,n1*16
	fcb		rest,n1*16
	fcb		setplsduty,64,3
	fcb		setnote,b4,n1*8
	_setport	-40
	_rest		n1*8
	_setport	0

	_jump 1b


lead_main
	fcb	e2,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	d2,n1

	fcb	b1,n1*2
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1
	fcb	d2,n1
	fcb	b1,n1
	fcb	a1,n1
	fcb	b1,n1*2

	fcb	b1,n1
	fcb	b1,n1
	fcb	b1,n1

	_return



tune0_c1

1
	_call	drum_1
	_call	drum_2

	_jump 1b


f_kick	equ	c0-3
f_snare	equ	128

drum_1
	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	3
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2

	_setpatch	4
	_startsmp	f_snare,n1*2
	_setpatch	3
	_startsmp	f_kick,n1*1
	_setpatch	4
	_startsmp	f_snare,n1*1

	_return


drum_2
	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	3
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*2

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1

	_setpatch	4
	_startsmp	f_snare,n1*1

	_setpatch	3
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*2
	_startsmp	f_kick,n1*1
	_startsmp	f_kick,n1*2

	_setpatch	4
	_startsmp	f_snare,n1*2
	_startsmp	f_snare,n1
	_startsmp	f_snare,n1

	_return

