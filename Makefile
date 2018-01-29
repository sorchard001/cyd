# Cân y Ddraig (Dragon's Song)

SID = sid/Cybernoid_II.sid

.PHONY: all
all: cyd.bin cyd.cas

####

ASM6809 = asm6809 -v
BIN2CAS = bin2cas.pl
CLEAN =
EXTRA_DIST = cyd.html

####

# SID parsing

sid/1941.s: SDFLAGS = -t100 -f1
sid/1942.s: SDFLAGS = -t200
sid/1943.s: SDFLAGS = -t80 -a2
sid/Auf_Wiedersehen_Monty.s: SDFLAGS = -t84
sid/Battle_Valley.s: SDFLAGS = -t78
sid/Blood_Valley.s: SDFLAGS = -t192
sid/Crazy_Comets.s: SDFLAGS = -t110 -f1
sid/Comic_Bakery.s: SDFLAGS = -t100
sid/Commando.s: SDFLAGS = -t102 -f1
sid/Cream_of_the_Earth.s: SDFLAGS = -t144 -f8
sid/Cybernoid.s: SDFLAGS = -t89
sid/Cybernoid_II.s: SDFLAGS = -t80
sid/Delta.s: SDFLAGS = -t120 -f2 -a11
sid/Future_Knight.s: SDFLAGS = -t188
sid/Ghosts_n_Goblins.s: SDFLAGS = -t180 -a1
sid/Great_Giana_Sisters.s: SDFLAGS = -t200 -f7
sid/Green_Beret.s: SDFLAGS = -t114
sid/Head_Over_Heels.s: SDFLAGS = -t150
sid/Hyper_Sports.s: SDFLAGS = -t180 -a25
sid/Katakis.s: SDFLAGS = -t114 -f1
sid/Last_Ninja.s: SDFLAGS = -t92 -f1 -a2
sid/Lightforce.s: SDFLAGS = -t125 -f1
sid/Monique_Alcoholique.s: SDFLAGS = -t90 -f1
sid/Monty_on_the_Run.s: SDFLAGS = -t91
sid/Ocean_Loader_1.s: SDFLAGS = -t138
sid/Ocean_Loader_2.s: SDFLAGS = -t147 -f1
sid/Ocean_Loader_3.s: SDFLAGS = -t125
sid/Ocean_Loader_4.s: SDFLAGS = -t69
sid/Paranoimia.s: SDFLAGS = -t120 -f5
sid/Quadrophenia.s: SDFLAGS = -t120 -f7
sid/R-Type.s: SDFLAGS = -t96 -f3
sid/Rasputin.s: SDFLAGS = -t140
sid/Redsector_3.s: SDFLAGS = -t100 -f1
sid/Rock_Sid_compo_version.s: SDFLAGS = -t79 -f6
sid/Romeo_Knight_Mix.s: SDFLAGS = -t220
sid/Sanxion.s: SDFLAGS = -t112 -f3
sid/Shadow_of_the_Beast.s: SDFLAGS = -t100 -f1
sid/Smash_TV.s: SDFLAGS = -t150
sid/Speed_It_Up.s: SDFLAGS = -t100
sid/Thing_on_a_Spring.s: SDFLAGS = -t154 -f1
sid/Turrican.s: SDFLAGS = -t150 -f1
sid/Turrican_3_1-3.s: SDFLAGS = -t108
sid/Warhawk.s: SDFLAGS = -t106 -f1
sid/Xenon_2_Megablast.s: SDFLAGS = -t116
sid/Zoids.s: SDFLAGS = -t105

####

%.bin: %.s
	$(ASM6809) $(AFLAGS) -l $(<:.s=.lis) -o $@ $<

%.cas %.wav:
	$(BIN2CAS) $(B2CFLAGS) $(B2CFLAGS_ADD) -o $@ $<

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
#WAVE_DITHER = dither -p 11
#silent.bin: WAVE_DITHER = dither -p 11

$(WAVES_BIN):
	sox -D -r 256 -n -e signed -b 8 -c 1 -t raw $@ $(WAVE_SYNTH) $(WAVE_VOL) dcshift 0.33 $(WAVE_DITHER)

####

%.bin: %.s
	$(ASM6809) $(AFLAGS) -l $(<:.s=.lis) -o $@ $<

%.cas %.wav: %.bin
	$(BIN2CAS) $(B2CFLAGS) $(B2CFLAGS_ADD) -o $@ $<

####

SPFLAGS = -c 71
%.s: %.sid ./Makefile
	siddump $(SDFLAGS) $< | ./sidparse.pl $(SPFLAGS) > $@

tune0.s: $(SID:.sid=.s) Makefile
	echo " include \"$(SID:.sid=.s)\"" > $@
CLEAN += tune0.s

waves0.s: $(SID:.sid=.s)
	for w in $(shell awk '/^;begin-waves$$/,/^;end-waves$$/{print $$2}' $(SID:.sid=.s)); do echo "$$w equ *+128"; echo " includebin /$$w.bin/"; done > $@
CLEAN += waves0.s

####

GFTFLAGS = -c 71
ftable.s: ./gen_ftable.pl
	./gen_ftable.pl $(GFTFLAGS) > $@
CLEAN += ftable.s
EXTRA_DIST += ftable.s

cyd.bin: AFLAGS = -D
cyd.bin: ftable.s tune0.s waves0.s $(WAVES_BIN)
CLEAN += cyd.lis cyd.bin

cyd.cas cyd.wav: B2CFLAGS_ADD = --autorun -n "CYD" --eof-data --dzip --fast -D
cyd.cas cyd.wav: cyd.bin
CLEAN += cyd.cas cyd.wav

ifdef VSYNC
cyd.bin: AFLAGS += -d VSYNC
GFTFLAGS = -c 70
SPFLAGS = -c 70
endif

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
