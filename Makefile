# Cân y Ddraig (Dragon's Song)

TUNE = sid/Cybernoid_II

.PHONY: all
all: cyd.bin cyd.cas

####

ASM6809 = asm6809 -v
BIN2CAS = bin2cas.pl
CLEAN =
EXTRA_DIST =

####

# SID parsing

sid/1941.sd: SPFLAGS = -t100 -f1
sid/1942.sd: SPFLAGS = -t200
sid/1943.sd: SPFLAGS = -t80 -a2
sid/Auf_Wiedersehen_Monty.sd: SPFLAGS = -t81
sid/Battle_Valley.sd: SPFLAGS = -t75
sid/Blood_Valley.sd: SPFLAGS = -t192
sid/Crazy_Comets.sd: SPFLAGS = -t110 -f1
sid/Chordian.sd: SPFLAGS = -t88 -f3
sid/Comic_Bakery.sd: SPFLAGS = -t98
sid/Commando.sd: SPFLAGS = -t95 -f1
sid/Cream_of_the_Earth.sd: SPFLAGS = -t145 -f8
sid/Cybernoid.sd: SPFLAGS = -t89
sid/Cybernoid_II.sd: SPFLAGS = -t80
sid/Delta.sd: SPFLAGS = -t114 -f2 -a11
sid/Future_Knight.sd: SPFLAGS = -t188
sid/Ghosts_n_Goblins.sd: SPFLAGS = -t179 -a1
sid/Great_Giana_Sisters.sd: SPFLAGS = -t200 -f7
sid/Head_Over_Heels.sd: SPFLAGS = -t149
sid/Hyper_Sports.sd: SPFLAGS = -t180 -a25
sid/Katakis.sd: SPFLAGS = -t112 -f1
sid/Last_Ninja.sd: SPFLAGS = -t92 -f1 -a2
sid/Lightforce.sd: SPFLAGS = -t125 -f1
sid/Monique_Alcoholique.sd: SPFLAGS = -t90 -f1
sid/Monty_on_the_Run.sd: SPFLAGS = -t91
sid/Ocean_Loader_1.sd: SPFLAGS = -t138
sid/Ocean_Loader_2.sd: SPFLAGS = -t148 -f1
sid/Ocean_Loader_3.sd: SPFLAGS = -t125
sid/Ocean_Loader_4.sd: SPFLAGS = -t69
sid/Paranoimia.sd: SPFLAGS = -t120 -f5
sid/Quadrophenia.sd: SPFLAGS = -t120 -f7
sid/R-Type.sd: SPFLAGS = -t90 -f3
sid/Rasputin.sd: SPFLAGS = -t136
sid/Redsector_3.sd: SPFLAGS = -t97 -f1
sid/Rock_Sid_compo_version.sd: SPFLAGS = -t79 -f6
sid/Romeo_Knight_Mix.sd: SPFLAGS = -t220
sid/Sanxion.sd: SPFLAGS = -t112 -f3
sid/Shadow_of_the_Beast.sd: SPFLAGS = -t93 -f1
sid/Smash_TV.sd: SPFLAGS = -t150
sid/Speed_It_Up.sd: SPFLAGS = -t100
sid/Thing_on_a_Spring.sd: SPFLAGS = -t155 -f1
sid/Turrican.sd: SPFLAGS = -t150 -f1
sid/Turrican_3_1-3.sd: SPFLAGS = -t108
sid/Warhawk.sd: SPFLAGS = -t94 -f1
sid/Xenon_2_Megablast.sd: SPFLAGS = -t117
sid/Zoids.sd: SPFLAGS = -t105

####

%.bin: %.s
	$(ASM6809) $(AFLAGS) -l $(<:.s=.lis) -o $@ $<

%.cas %.wav:
	$(BIN2CAS) $(B2CFLAGS) -o $@ $<

%.dz: %
	dzip -c $< > $@

####

WAVES_BIN = silent.bin \
	sqr2.bin sqr1.bin sqr0.bin \
	saw2.bin saw1.bin saw0.bin \
	tri2.bin tri1.bin tri0.bin \
	sin2.bin sin1.bin sin0.bin \
	nzz2.bin nzz1.bin nzz0.bin
CLEAN += $(WAVES_BIN)
EXTRA_DIST += $(WAVES_BIN)

sqr2.bin sqr1.bin sqr0.bin: WAVE_SYNTH = synth 256s square 1 0 0 40
saw2.bin saw1.bin saw0.bin: WAVE_SYNTH = synth 256s saw 1
tri2.bin tri1.bin tri0.bin: WAVE_SYNTH = synth 256s triangle 1 
sin2.bin sin1.bin sin0.bin: WAVE_SYNTH = synth 256s sine 1
nzz2.bin nzz1.bin nzz0.bin silent.bin: WAVE_SYNTH = synth 256s noise

sqr2.bin saw2.bin tri2.bin sin2.bin: WAVE_VOL = vol 0.325
sqr1.bin saw1.bin tri1.bin sin1.bin: WAVE_VOL = vol 0.217
sqr0.bin saw0.bin tri0.bin sin0.bin: WAVE_VOL = vol 0.108
silent.bin: WAVE_VOL = vol 0
nzz2.bin: WAVE_VOL = vol 0.25
nzz1.bin: WAVE_VOL = vol 0.167
nzz0.bin: WAVE_VOL = vol 0.083

$(WAVES_BIN):
	sox -r 256 -n -e signed -b 8 -c 1 -t raw $@ $(WAVE_SYNTH) $(WAVE_VOL) dcshift 0.33

####

%.bin: %.s
	$(ASM6809) $(AFLAGS) -l $(<:.s=.lis) -o $@ $<

%.cas %.wav: %.bin
	$(BIN2CAS) $(B2CFLAGS) -o $@ $<

%.sd: %.sid ./Makefile
	siddump $(SPFLAGS) $< > $@

%.s: %.sd ./sidparse.pl
	./sidparse.pl < $< > $@

####

tune.s: $(TUNE).s Makefile
	echo " include \"$(TUNE).s\"" > $@
	echo "song_table fdb c1_data,c2_data,c3_data" >> $@
CLEAN += tune.s
EXTRA_DIST += tune.s

ftable.s: ./gen_ftable.pl
	./gen_ftable.pl > $@
CLEAN += ftable.s
EXTRA_DIST += ftable.s

cyd.bin: AFLAGS = -D
cyd.bin: ftable.s tune.s $(WAVES_BIN)
CLEAN += cyd.lis cyd.bin

cyd.cas cyd.wav: B2CFLAGS = --autorun -n "CYD" --eof-data --fast -D
cyd.cas cyd.wav: cyd.bin
CLEAN += cyd.cas cyd.wav

####

.PHONY: dist
dist: $(EXTRA_DIST)
	git archive --format=tar --output=../cyd.tar --prefix=cyd/ HEAD
	tar -r -f ../cyd.tar --owner=root --group=root --mtime=../cyd.tar --transform 's,^,cyd/,' $(EXTRA_DIST)
	gzip -f9 ../cyd.tar

####

.PHONY: clean
clean:
	rm -f $(CLEAN)
