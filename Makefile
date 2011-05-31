# Cân y Ddraig (Dragon's Song)

TUNE = example

.PHONY: all
all: cyd.bin cyd.cas

####

ASM6809 = asm6809 -v
BIN2CAS = ./bin2cas.pl
CLEAN =
EXTRA_DIST =

####

%.bin: %.s
	$(ASM6809) $(AFLAGS) -l $(<:.s=.lis) -o $@ $<

%.cas:
	$(BIN2CAS) $(B2CFLAGS) -o $@ $<

%.wav:
	$(BIN2CAS) $(B2CFLAGS) --wav-out -o $@ $<

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
	sox -r 256 -n -e signed -b 8 -c 1 -t raw $@ $(WAVE_SYNTH) $(WAVE_VOL)

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

cyd.cas cyd.wav: B2CFLAGS = -D --eof-data
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
