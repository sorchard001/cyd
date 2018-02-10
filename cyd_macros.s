; helper macros for CyD music data

	if	!_cyd_macros_s

__cyd_macros_s	equ 1


_silence macro
	fcb	silence,\1
	endm


_rest	macro
	fcb	rest,\1
	endm


_setnote macro
	fcb	setnote,\1
	endm


_setpatch macro
	fcb	setpatch,\1
	endm


_setport macro
	fcb	setport,\1
	endm

	
_settp	macro
	fcb	settp,\1
	endm


_loop 	macro
	fcb	loop,\1
	endm


_next	macro
	fcb	next
	endm


_jump	macro
	fcb	jump
	fdb	\1
	endm
	

_call	macro
	fcb	call
	fdb	\1
	endm


_calltp	macro
	fcb	calltp,\1
	fdb	\2
	endm


_return macro
	fcb	return
	endm


_setarp macro
	fcb	setarp,\1
	fdb	\2
	endm


_clrarp	macro
	fcb	clrarp
	endm


_startsmp macro
	fcb	startsmp,\1,\2
	endm


_setplscfg macro
	fcb	setplscfg,\1,\2
	endm


_setplsduty macro
	fcb	setplsduty,\1,\2
	endm


	endif
