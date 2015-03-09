#!/usr/bin/perl

use Data::Dumper;

my $cpu_freq = 14318180 / 16;
my $mixer_cyc = 70;

my $freq_scale = (65536 * 1000000) / (16777216 * ($cpu_freq / $mixer_cyc));

my %voices = (
	'tri' => [ 160 => 'tri2', 80 => 'tri1', 16 => 'tri0', 0 => 'silent' ],
	'saw' => [ 160 => 'saw2', 80 => 'saw1', 16 => 'saw0', 0 => 'silent' ],
	'sqr' => [ 160 => 'sqr2', 80 => 'sqr1', 16 => 'sqr0', 0 => 'silent' ],
	'nzz' => [ 160 => 'nzz2', 80 => 'nzz1', 16 => 'nzz0', 0 => 'silent' ],
	'silent' => [ 0 => 'silent' ],
);

my @a_rate = ( 2, 8, 16, 24, 38, 56, 68, 80, 100, 250, 500, 800, 1000, 3000, 5000, 8000 );
my @dr_rate = ( 6, 24, 48, 72, 114, 168, 204, 240, 300, 750, 1500, 2400, 3000, 9000, 15000, 24000 );

@a_rate = map { (255 * 20) / $_; } @a_rate;
@dr_rate = map { (255 * 20) / $_; } @dr_rate;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ordered list of envelopes.  ref to array of waves.
my @envelopes = ();
my %envelope_index = ();

my @patches = ();

find_envelope([ "silent" ]);

sub find_envelope {
	my $waves = shift;
	$waves = [ "silent" ] if (!@$waves);
	my $key = join(",", @$waves);
	if (exists $envelope_index{$key}) {
		return $envelope_index{$key};
	}
	push @envelopes, [ @$waves ];
	$envelope_index{$key} = $#envelopes;
	return $#envelopes;
}

sub find_patch {
	my $dur_ads = shift;
	my $env_ads = shift;
	my $env_r = shift;
	if ($dur_ads > 256) {
		$dur_ads = 0;
	}
	for (my $i = 0; $i <= $#patches; $i++) {
		my $patch = $patches[$i];
		if ($env_ads == $patch->[0]
			&& $dur_ads <= $patch->[1]
			&& $env_r == $patch->[2]) {
			return $i;
		}
	}
	push @patches, [ $env_ads, $dur_ads, $env_r ];
	return $#patches;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# initial values
my @old = ({}, {}, {});
for my $c (0..2) {
	$old[$c] = {
		'adsr' => '0000',
		'voice' => 'silent',
		'gate' => 0,
		'freq' => 0,
		'ampl' => 0,
		'is_attack' => 0,
	};
}

my @chan_wave = ([], [], []);
my @chan_gate = ([], [], []);
my @chan_freq = ([], [], []);

# Run through siddump output, populating wave/gate/freq arrays one per frame
# per channel.

while (<>) {
	chomp;
	my @line = split(/\s+/);
	next unless ($line[0] eq '|' && $line[1] ne 'Frame');
	shift @line;  # |
	my $frame = shift @line;
	for my $c (0..2) {
		die unless $line[0] eq '|';
		shift @line;  # |
		my $freq = shift @line;
		my $note = shift @line;
		my $abs = shift @line;
		my $wf = shift @line;
		my $adsr = shift @line;
		my ($attack, $decay, $sustain, $release);
		my $pul = hex shift @line;

		if ($freq eq "....") {
			$freq = $old[$c]->{'freq'};
		} else {
			$freq = hex $freq;
		}

		if ($adsr eq "....") {
			$adsr = $old[$c]->{'adsr'};
		}
		my $attack = hex substr($adsr,0,1);
		my $decay = hex substr($adsr,1,1);
		my $sustain = 16 * hex substr($adsr,2,1);
		my $release = hex substr($adsr,3,1);

		my $gate;
		my $voice = "silent";
		if ($wf eq "..") {
			$gate = $old[$c]->{'gate'};
			$voice = $old[$c]->{'voice'};
		} else {
			$wf = hex $wf;
			$gate = $wf & 1;
			if ($wf & 0x10) {
				$voice = "tri";
			} elsif ($wf & 0x20) {
				$voice = "saw";
			} elsif ($wf & 0x40) {
				$voice = "sqr";
			} elsif ($wf & 0x80) {
				$voice = "nzz";
			}
		}

		my $is_attack = $old[$c]->{'is_attack'};
		my $ampl = $old[$c]->{'ampl'};

		if ($gate && !$old[$c]->{'gate'}) {
			$is_attack = 1;
		}

		if ($gate) {
			if ($is_attack) {
				$ampl += $a_rate[$attack];
				if ($ampl >= 255) {
					$ampl = 255;
					$is_attack = 0;
				}
			} else {
				$ampl -= $dr_rate[$decay];
				if ($ampl < $sustain) {
					$ampl = $sustain;
				}
			}
		} else {
			$ampl -= $dr_rate[$release];
			if ($ampl < 0) {
				$ampl = 0;
			}
		}
		my $wave = voice_ampl_to_wave($voice, $ampl);

		push @{$chan_wave[$c]}, $wave;
		push @{$chan_gate[$c]}, $gate;
		push @{$chan_freq[$c]}, $freq;

		$old[$c] = {
			'freq' => $freq,
			'adsr' => $adsr,
			'voice' => $voice,
			'gate' => $gate,
			'ampl' => $ampl,
			'is_attack' => $is_attack,
		};
	}
	die unless $line[0] eq '|';
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

my @chan_patch = ([], [], []);
for my $c (0..2) {
	my $old_gate = 0;
	my $note_duration = 0;
	my $ads_duration = 0;
	my $env_ads = find_envelope([ "silent" ]);
	my $env_r;
	my @waves = ();
	for (my $i = 0; $i <= $#{$chan_wave[$c]}; $i++) {
		my $wave = $chan_wave[$c]->[$i];
		my $gate = $chan_gate[$c]->[$i];
		if ($gate == $old_gate) {
			$note_duration++;
			if ($gate) {
				$ads_duration++;
			}
			push @waves, $wave;
		}
		if ($gate != $old_gate || $i == $#{$chan_wave[$c]}) {
			# last one sticks
			while ($#waves > 0 && $waves[-1] eq $waves[-2]) {
				pop @waves;
			}
			if ($gate) {
				$env_r = find_envelope(\@waves);
				my $patch = find_patch($ads_duration, $env_ads, $env_r);
				for (my $j = 0; $j < $note_duration; $j++) {
					push @{$chan_patch[$c]}, $patch;
				}
				$note_duration = 0;
				$ads_duration = 0;
			} else {
				$env_ads = find_envelope(\@waves);
			}
			@waves = ();
			$note_duration++;
			if ($gate) {
				$ads_duration++;
			}
			push @waves, $wave;
			$old_gate = $gate;
		}
	}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

my $nbytes = 0;

# sort, coalesce and print envelopes

my @envelopes_sort = sort { scalar(@{$envelopes[$b]}) <=> scalar(@{$envelopes[$a]}) } (0..$#envelopes);

PATCH: for my $j (0..$#envelopes_sort) {
	my $i = $envelopes_sort[$j];
	my $p = $envelopes[$i];
	my $l = $#$p;
	if ($j > 0) {
		TRYPATCH: for my $j2 (0..$j-1) {
			my $i2 = $envelopes_sort[$j2];
			my $p2 = $envelopes[$i2];
			my $l2 = $#$p2;
			next if ($l > $l2);
			for my $k (1..$l+1) {
				next TRYPATCH if ($p2->[-$k] ne $p->[-$k]);
			}
			print "envelope_$i\tequ\tenvelope_$i2+".($l2-$l)."\n";
			next PATCH;
		}
	}
	print "envelope_$i\n\tfcb\t".join(",", map { "$_>>8" } @{$p}).",0\n";
	$nbytes += scalar(@{$p}) + 1;
}
print "\n";

# print patches

print "patch_table\n";
for (my $i = 0; $i <= $#patches; $i++) {
	my $patch = $patches[$i];
	print "patch_$i\n";
	print "\tfcb\t$patch->[1]\n";
	print "\tfdb\tenvelope_$patch->[0],envelope_$patch->[2]\n";
	$nbytes += 5;
}
print "\n";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub print_note {
	my $note = shift;
	my $data = shift;
	return if ($note->{'duration'} == 0);

	my $explicit_note = $note->{'gate'} || $note->{'setnote'};

	if ($note->{'setport'}) {
		if ($note->{'port'} == -1 || $note->{'duration'} > 1 || !$explicit_note) {
			push @{$data}, [ "setport", $note->{'cport'} ];
			$nbytes += 2;
			$note->{'setport'} = 0;
		}
	}

	if ($note->{'gate'}) {
		if ($note->{'note'} == -1) {
			push @{$data}, [ "silence", $note->{'duration'}%256 ];
			$nbytes += 2;
		} else {
			push @{$data}, [ $note->{'note'}|0x80, $note->{'duration'}%256 ];
			$nbytes += 2;
		}
		$note->{'xrest'} = 0;
	} elsif ($note->{'setnote'}) {
		if ($note->{'note'} == -1) {
			push @{$data}, [ "silence", $note->{'duration'}%256 ];
			$nbytes += 2;
		} else {
			push @{$data}, [ "setnote", $note->{'note'}, $note->{'duration'}%256 ];
			$nbytes += 3;
		}
		$note->{'xrest'} = 0;
	} elsif ($note->{'xrest'}) {
		push @{$data}, [ "xrest", $note->{'duration'}%256 ];
		$nbytes += 2;
	} else {
		push @{$data}, [ "rest", $note->{'duration'}%256 ];
		$nbytes += 2;
		$note->{'xrest'} = 1;
	}
	$note->{'gate'} = 0;
	$note->{'setnote'} = 0;
	$note->{'duration'} = 0;
}

for my $c (0..2) {
	my $old_gate = 0;

	my %note = (
		'patch' => -1,
		'note' => 0,
		'freq' => 0,
		'port' => -1,
		'gate' => 1,
		'duration' => 0,
	);

	my @data = ();

	while (@{$chan_patch[$c]}) {
		my $patch = shift @{$chan_patch[$c]};
		my $freq = shift @{$chan_freq[$c]};
		my $gate = shift @{$chan_gate[$c]};

		my $next_freq = $chan_freq[$c]->[0] // $freq;
		my $port = $next_freq - $freq;

		if ($patch != $note{'patch'}) {
			print_note(\%note, \@data);
			#print "\t; patch changed\n";
			push @data, [ "setpatch", $patch ];
			$nbytes += 2;
			$note{'patch'} = $patch;
		}

		my $adj_freq = $note{'freq'} + $note{'port'} * $note{'duration'};

		if ($gate && !$old_gate) {
			print_note(\%note, \@data);
			#print "\t; gate triggered\n";
			my $new = closest_note($freq);
			$note{'gate'} = 1;
			$note{'note'} = $new;
			if ($new >= 0) {
				$note{'freq'} = sid_freq($new);
			}
		}

		if ($port != $note{'port'}) {
			my $off = ($port >= 0) ? 0.5 : -0.5;
			my $cport = int(($port * $freq_scale) + $off);
			if ($cport >= -128 && $cport <= 127) {
				print_note(\%note, \@data);
				#print "\t; port changed $note{'port'} -> $port\n";
				$note{'setport'} = 1;
				$note{'port'} = $port;
				$note{'cport'} = $cport;
			}
		}

		my $delta = abs($adj_freq - $freq);
		my $new = closest_note($freq);
		my $new_freq = sid_freq($new);
		my $new_delta = abs($new_freq - $freq);
		if ($new_delta < $delta && !($new == -1 && $note{'note'} == -1)) {
			print_note(\%note, \@data);
			#print "\t; freq changed ($new_delta < $delta) $adj_freq -> $freq\n";
			$note{'setnote'} = 1;
			$note{'note'} = $new;
			if ($new >= 0) {
				$note{'freq'} = $new_freq;
			}
		}

		$note{'duration'}++;
		if ($note{'duration'} == 256) {
			#print "\t; note timeout\n";
			print_note(\%note, \@data);
			$note{'freq'} = $adj_freq;
		}

		$old_gate = $gate;
	}
	if ($note{'duration'} > 0) {
		print_note(\%note, \@data);
	}

	printf "c\%d_data\n", $c+1;
	my @out = ();
	my $port = 0;
	while (my $cmd = shift @data) {
		if ($cmd->[0] eq 'setport') {
			$port = $cmd->[1];
		}
		# peephole optimise...
		if ($cmd->[0] eq 'setnote' && ($cmd->[2] == 1 || $port == 0)) {
			my @ph_cmd = (@{$cmd});
			my $note = $ph_cmd[1];
			my $duration = $ph_cmd[2];
			my $count = 0;
			while ($count <= $#data && $data[$count]->[0] eq 'setnote' && $data[$count]->[1] == $note && ($data[$count]->[2] == 1 || $port == 0)) {
				last if ($duration + $data[$count]->[2] > 256);
				$duration += $data[$count]->[2];
				$count++;
				last if ($duration == 256);
			}
			if ($count > 1 || ($count > 0 && $port == 0)) {
				for (my $i = 0; $i < $count; $i++) {
					shift @data;
				}
				$ph_cmd[-1] = ($count + 1) % 256;
				if ($port != 0) {
					push @out, "\tfcb\tsetport,0";
				}
				push @out, "\tfcb\t".join(",",@ph_cmd);;
				if ($port != 0 && @data && $data[0]->[0] ne 'setport') {
					push @out, "\tfcb\tsetport,$port";
				}
				next;
			}
		}
		push @out, "\tfcb\t".join(",",@{$cmd});
	}
	for (@out) {
		print "\t$_\n";
	}
	printf "\tfcb\tjump,c\%d_data>>8,c\%d_data\n", $c+1, $c+1;
	print "\n";
}

print "; total $nbytes bytes\n";

exit 0;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub closest_note {
	my $sidf = shift;
	my $freq = ($sidf * 1000000) / 16777216;
	return -1 if (int($freq) <= 0);
	my $n = ((log($freq/440)/log(2))*12)+69;
	return int($n+0.5);
}

sub sid_freq {
	my $note = shift;
	return 0 if ($note < 0);
	my $freq = (2 ** (($note - 69) / 12)) * 440;
	my $sidf = ($freq * 16777216) / 1000000;
	return $sidf;
}

sub voice_ampl_to_wave {
	my ($voice,$ampl) = @_;
	my @v = @{$voices{$voice}};
	while (@v) {
		if ($ampl >= $v[0]) {
			return $v[1];
		}
		shift @v;
		shift @v;
	}
	return 'silent';
}
