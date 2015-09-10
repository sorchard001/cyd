# Cân y Ddraig

(aka Dragon's Song, aka There's Good Cyd)

A 3-channel music player for the Dragon.  Inspired by Rem's CoCoSID, this is
rewritten with a tight core and tune scripting engine.

## Quick Start

But note this is just to quickly try out SID tunes, which do *not* convert
cleanly, do *not* use the programming feature and so take up loads of
memory.  If there isn't a rule in the Makefile for the one you choose,
you'll probably have to specify some SDFLAGS for siddump so limit the
amount of time it dumps the tune for.

Needs: asm6809, bin2cas.pl, dzip, perl, siddump

```
git clone https://github.com/sixxie/cyd
cd cyd
cp /path/to/Ocean_Loader_2.sid .
make SID=Ocean_Loader_2.sid
xroar cyd.bin
```
