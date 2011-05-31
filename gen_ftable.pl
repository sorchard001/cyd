#!/usr/bin/perl -wT

my $cpu_freq = 14318180 / 16;
my $mixer_cyc = 72;

my @note_names = ( "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs", "a", "as", "b" );

my $mbase = 69;   # A4
my $mfreq = 440;

my @note_map = ( );

for my $m (64..127,0..63) {
	my $freq = (2 ** (($m - $mbase) / 12)) * $mfreq;
	my $f = (65536 * $freq) / ($cpu_freq / $mixer_cyc);
	if ($m >= 12 && $f < 0x8000) {
		my $o = int(($m - 12) / 12);
		my $ni = $m % 12;
		my $name = "$note_names[$ni]$o";
		push @note_map, [ $name, $m|0x80 ];
	}
	while ($f >= 0x8000) {
		$f /= 2;  # pull off-scale notes down an octave
	}
	printf "\tfdb\t\$\%04x\n", int($f+0.5);
}
print "\n";

for (@note_map) {
	print "$_->[0]\tequ\t$_->[1]\n";
}
