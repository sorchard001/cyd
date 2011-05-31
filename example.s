envelope_1
	fcb	sqr2>>8,sqr1>>8,0
envelope_2
	fcb	sqr0>>8,silent>>8,0
envelope_0	equ	*-2
envelope_3
	fcb	sqr0>>8,sqr0>>8,sqr0>>8,sqr1>>8,0
envelope_4	equ	*-2
envelope_5
	fcb	nzz2>>8,nzz1>>8,nzz0>>8,silent>>8,0

patch_table
patch_0
	fcb	0
	fdb	envelope_0,envelope_0
patch_1
	fcb	4
	fdb	envelope_1,envelope_2
patch_2
	fcb	0
	fdb	envelope_3,envelope_4
patch_3
	fcb	0
	fdb	envelope_5,envelope_0

tempo	equ	6
sq	equ	tempo
qv	equ	sq*2
cr	equ	qv*2
dcr	equ	cr+qv
mn	equ	cr*2
sb	equ	mn*2

c1_data
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

c2_data
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

c3_data
	fcb	setpatch,3
1
	fcb	a4,sq
	fcb	rest,3*sq

	fcb	jump,1B>>8,1B
