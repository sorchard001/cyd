# Cân y Ddraig

(aka Dragon's Song, aka There's Good Cyd)

A 3-channel music player for the Dragon.  Inspired by Rem's CoCoSID, this is
rewritten with a tight core and tune scripting engine.

Copyright 2013-2015 Ciaran Anscomb

Mods by Stewart Orchard 2018

## Quick Start

But note this is just to quickly try out SID tunes, which do *not* convert
cleanly, do *not* use the programming feature and so take up loads of
memory.  If there isn't a rule in the Makefile for the one you choose,
you'll probably have to specify some SDFLAGS for siddump to limit the
amount of time it dumps the tune for.

Needs: asm6809, bin2cas.pl, dzip, perl, siddump, sox

```
git clone https://github.com/sixxie/cyd
cd cyd
cp /path/to/Ocean_Loader_2.sid .
make SID=Ocean_Loader_2.sid
xroar cyd.bin
```

## New Stuff by S.Orchard

Added magic comments to Ciaran's example tune for easier build.

```
git clone https://github.com/sorchard001/cyd
cd cyd
make SID=example.s
xroar cyd.bin
```

Additional demo tunes:

```
make SID=example2.s
make SID=example3.s
make SID=example4.s
make SID=example5.s
```

The three channels may be individually configured as variable duty pulse wave generators by defining symbols in the source as required:

```
CYD_C1_PULSE	equ 1
CYD_C2_PULSE	equ 1
CYD_C3_PULSE	equ 1
```

The pulse wave duty is configured with new commands in the music source:

	fcb	setplscfg,reset_mode,duty_min,duty_max
	fcb	setplsduty,duty_val,rate_val

where:

**reset_mode** is either **CYD_DUTY_RESET** or **CYD_DUTY_NORST** (controls whether the duty is reset to the start value or not when a new note starts)

**duty_min** and **duty_max** define the range over which the duty will be varied

**duty_val** sets the current duty and start duty (range 0 to 255. Use a value of 128 for a 50% duty square wave). It may be set outside the duty range in which case it will sweep until it falls within range.

**rate_val** sets the rate at which the duty is varied (range 0 to 255).


New command to reset the channel phase before starting a note. This allows playback of 256-byte samples:

	fcb	startsmp,n,duration

where **n** is the note and **duration** is the note length as specified in similar commands.


Note that it is necessary to define an envelope that cuts off the sample at the right time if looping of the sample is to be avoided.
