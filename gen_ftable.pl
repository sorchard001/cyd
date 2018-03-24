#!/usr/bin/perl -wT

use Getopt::Long;

my $cpu_freq = 14318180 / 16;
my $mixer_cyc = 71;

my $mbase = 69;   # A4
my $mfreq = 440;

Getopt::Long::Configure("bundling", "auto_help");

GetOptions("cycles|c=i" => \$mixer_cyc,
		"base|b=i", \$mbase,
		"base-freq|f=i", \$mfreq);

my @note_names = ( "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs", "a", "as", "b" );
my @note_map = ( );

print "CYD_FSCALE\tequ\t65536 * CYD_CORE_CYCLES / $cpu_freq\n\n";

my $fadjust = "1b / (1 + (1b >= \$8000))";

for my $m (64..127,0..63) {
	my $freq = (2 ** (($m - $mbase) / 12)) * $mfreq;
	printf "1\tequ\t(CYD_FSCALE * %8.2f) + 0.5\n", $freq;
	if ($m >= 12) {
		my $o = int(($m - 12) / 12);
		my $ni = $m % 12;
		my $name = "$note_names[$ni]$o";
		push @note_map, [ $name, $m|0x80 ];
		print "f_$name\tequ\t$fadjust\n";
		print "\tfdb\tf_$name\n";
	} else {
		print "\tfdb\t$fadjust\n";
	}
	#printf "\tfdb\t\$\%04x\n", int($f+0.5);
	#print "f_$name\tequ\t1b / (1 + (1b >= \$8000))\n";
	#print "\tfdb\t1b / (1 + (1b >= \$8000))\n";
}
print "\n";

for (@note_map) {
	print "$_->[0]\tequ\t$_->[1]\n";
}

__END__

=head1 gen_ftable.pl

gen_ftable.pl - Generate a frequency lookup table for CyD

=head1 SYNOPSIS

gen_ftable.pl [OPTION]...

 Options:
  -c, --cycles C       mixer loop takes C cycles [71]
  -b, --base N         note base [69]
  -f, --base-freq HZ   frequency at note base [440]

=cut
