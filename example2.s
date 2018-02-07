;List waveforms required for build
;
;begin-waves
; silent
; sqr2
; sqr1
; sqr0
;end-waves

; Select channels to be configured as variable duty
CYD_C1_PULSE	equ 1
CYD_C2_PULSE	equ 1
CYD_C3_PULSE	equ 1


; Envelope definition depends on how channel is configured:
;  Either waveform address MSB or actual volume 1-85

	if CYD_C1_PULSE
envelope_1	fcb	85,60,0
envelope_2	fcb	30,1,0
	else
envelope_1	fcb	sqr2>>8,sqr1>>8,0
envelope_2	fcb	sqr0>>8,silent>>8,0
	endif

	if CYD_C2_PULSE
envelope_3	fcb	30,30,30,60,0
	else
envelope_3	fcb	sqr0>>8,sqr0>>8,sqr0>>8,sqr1>>8,0
	endif
envelope_4	equ	*-2

	if CYD_C3_PULSE
envelope_5	fcb	85,60,0
envelope_6	fcb	30,1,0
	else
envelope_5	fcb	sqr2>>8,sqr1>>8,0
envelope_6	fcb	sqr0>>8,silent>>8,0
	endif


patch_table
patch_0
	fcb	0
	fdb	envelope_1,envelope_1
patch_1
	fcb	4
	fdb	envelope_1,envelope_2
patch_2
	fcb	0
	fdb	envelope_3,envelope_4
patch_3
	fcb	12
	fdb	envelope_5,envelope_6

arp1	fcb	4,8
arp0	fcb	0

tempo	equ	6
sq	equ	tempo
qv	equ	sq*2
cr	equ	qv*2
dcr	equ	cr+qv
mn	equ	cr*2
sb	equ	mn*2

tune0_c1
    if CYD_C1_PULSE
	fcb	setplsduty,96,-8
    endif
	fcb	setpatch,1
	fcb	setport,0
1
	fcb	loop,3
	fcb	call,bass>>8,bass
	fcb	next
	fcb	calltp,2,bass>>8,bass
	fcb	calltp,0,bass>>8,bass
	fcb	jump,1B>>8,1B

bass
	fcb	c2,sq
	fcb	rest,sq
	fcb	c2,sq
	fcb	rest,sq
	fcb	e2,sq
	fcb	rest,sq
	fcb	c2,sq
	fcb	c2,sq
	fcb	e2,sq
	fcb	rest,sq
	fcb	c2,sq
	fcb	c2,sq
	fcb	return

tune0_c2
    if CYD_C2_PULSE
	fcb	setplsduty,16,2
    endif
	fcb	setpatch,2
1
	fcb	silence,sq*12
	fcb	silence,sq*12
	fcb	c4,sq*2
	fcb	call,trill>>8,trill
	fcb	e4,sq*2
	fcb	call,trill>>8,trill
	fcb	c4,sq*2
	fcb	call,trill>>8,trill

	fcb	jump,1B>>8,1B

trill
	fcb	loop,5
	fcb	setport,8
	fcb	rest,4
	fcb	setport,-8
	fcb	rest,6
	fcb	setport,8
	fcb	rest,2
	fcb	next
	fcb	setport,0
	fcb	return

tune0_c3
    if CYD_C3_PULSE
	fcb	setplscfg,CYD_DUTY_NORST,CYD_DUTY_CYCLE
	fcb	setplsduty,16,8
    endif
	fcb	setpatch,3
	fcb	setarp,1,arp1>>8,arp1
1
	fcb	silence,sq*12
	fcb	c4,cr
	fcb	e4,cr
	fcb	c4,cr
	fcb	silence,sq*12
	fcb	settp,2
	fcb	c4,cr
	fcb	e4,cr
	fcb	c4,cr
	fcb	settp,0
	fcb	silence,sq*12

	fcb	jump,1B>>8,1B
