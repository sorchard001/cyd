#!/usr/bin/perl -wT

# bin2cas.pl - convert a raw/DragonDOS/CoCo binary into a .cas file.
# Ciaran Anscomb, 2011-2014.  Public Domain.

# Pre-v2.0: really rubbish
# v2.0: rewritten to only be mostly rubbish
# v2.1: WAV output
# v2.2: fixed wav header when using --blocks
#       added 'p' block instruction
#       fixed blocks help text

use strict;

require v5.10;

use IO::Handle;
require bytes;

use constant {
	TYPE_BASIC => 0,
	TYPE_DATA => 1,
	TYPE_BINARY => 2,
};

use constant {
	DDOS_TYPE_BASIC => 1,
	DDOS_TYPE_BINARY => 2,
};

use constant {
	ENCODING_BINARY => 0,
	ENCODING_ASCII => 0xff,
};

use constant {
	BLOCK_NAMEFILE => 0,
	BLOCK_DATA => 1,
	BLOCK_EOF => 0xff,
};

use constant {
	BINARY_RAW => 0,
	BINARY_DRAGONDOS => 1,
	BINARY_COCO => 2,
};

sub suggest_help {
	print STDERR "Try '$0 --help' for more information'\n";
	exit 0;
}

sub help_text {
	print STDERR <<EOF;
usage: $0 OPTION... input-file
       $0 --blocks [l | p | TYPE:LENGTH]... input-file
Generate a cassette image from binary input.

  -B                   input file is raw binary (default)
  -D                   input file is a DragonDOS binary
  -C                   input file is a CoCo RSDOS binary
  -l ADDR              load address in filename block
  -e ADDR              exec address in filename block
  -n NAME              name in filename block
  -o FILE              output file (defaults to stdout)
      --leader COUNT   leader size before filename block and data
      --no-filename    no filename block required in output
      --no-eof         no EOF block required in output
      --eof-data       EOF block allowed to contain the last chunk of data
      --wav-out        output a WAV file instead of a CAS
  -r, --wav-rate RATE  sample rate for WAV output

In standard cassette image mode, load and exec addresses are determined from
the binary if DragonDOS or RSDOS binary format is specified, otherwise they
should be specified as an option.

The argument to --blocks is a comma-separated list of instructions:
  l             emit a leader
  p             emit a ~0.5s pause (wav), or leader (cas)
  TYPE:LENGTH   emit block of specified type and length from input.  If LENGTH
		is negative, use all but the last -LENGTH bytes from the input.
EOF
	exit 0;
}

my %ddos_to_tape_type = (
		DDOS_TYPE_BASIC => TYPE_BASIC,
		DDOS_TYPE_BINARY => TYPE_BINARY,
		);
# Wave data

my @wav_header = (
		0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00,
		0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20,
		0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x01, 0x00, 0x08, 0x00, 0x64, 0x61, 0x74, 0x61,
		0x00, 0x00, 0x00, 0x00
		);

my @wav_samples = (
		0x82, 0x97, 0xab, 0xbd, 0xce, 0xdc, 0xe8, 0xf0,
		0xf5, 0xf6, 0xf4, 0xee, 0xe5, 0xd9, 0xca, 0xb9,
		0xa6, 0x92, 0x7e, 0x69, 0x55, 0x43, 0x32, 0x24,
		0x18, 0x10, 0x0b, 0x0a, 0x0c, 0x12, 0x1b, 0x27,
		0x36, 0x47, 0x5a, 0x6e
		);

my $sample_rate = 9600;
my $bits_per_sample = 8;
my $num_channels = 1;
my $sample_count = 0;
my $write_cycles = 0;

my $load;
my $exec;
my $name;
my $want_fnblock = 1;
my $want_eofblock = 1;
my $eof_data = 0;
my $leader = 256;
my $wav_out = 0;
my $mode = BINARY_RAW;
my @blocks = ();

while (my $opt = shift @ARGV) {
	if ($opt eq '--') {
		last;
	} elsif ($opt eq '-B') {
		$mode = BINARY_RAW;
	} elsif ($opt eq '-D') {
		$mode = BINARY_DRAGONDOS;
	} elsif ($opt eq '-C') {
		$mode = BINARY_COCO;
	} elsif ($opt eq '-l') {
		my $v = shift @ARGV;
		if ($v =~ /^(\d+|0x[\da-f]+)$/i) {
			$load = eval $1;
		}
	} elsif ($opt eq '-e') {
		my $v = shift @ARGV;
		if ($v =~ /^(\d+|0x[\da-f]+)$/i) {
			$exec = eval $1;
		}
	} elsif ($opt eq '-n') {
		$name = shift @ARGV;
	} elsif ($opt eq '-o') {
		my $f = shift @ARGV;
		my $o;
		if ($f =~ /(.*)/) {
			$f = $1;  # de-taint
		}
		open($o, ">", $f) or die $!;
		STDOUT->fdopen(\*$o, 'w') or die $!;
	} elsif ($opt eq '--leader') {
		my $v = shift @ARGV;
		if ($v =~ /^(\d+|0x[\da-f]+)$/i) {
			$leader = eval $1;
		}
	} elsif ($opt eq '--no-filename') {
		$want_fnblock = 0;
	} elsif ($opt eq '--no-eof') {
		$want_eofblock = 0;
	} elsif ($opt eq '--eof-data') {
		$eof_data = 1;
	} elsif ($opt eq '--blocks') {
		my $v = shift @ARGV;
		push @blocks, split(/,/, $v);
	} elsif ($opt eq '--wav-out') {
		$wav_out = 1;
	} elsif ($opt eq '-r' || $opt eq '--wav-rate') {
		$sample_rate = shift @ARGV;
	} elsif ($opt eq '--help') {
		help_text();
	} elsif ($opt =~ /^-/) {
		print STDERR "Unrecognised option '$opt'\n";
		suggest_help();
	} else {
		unshift @ARGV, $opt;
		last;
	}
}

die "no input file\n" unless scalar(@ARGV) > 0;
my $file = shift @ARGV;

my $in;
open($in, "<", $file) or die "failed to open $file: $!\n";
binmode $in;
binmode STDOUT;

my $cycles_per_frame = 14318180 / $sample_rate;
my $bytes_per_sample = $bits_per_sample >> 3;

# WAV header?
if ($wav_out) {
	# NumChannels
	$wav_header[22] = $num_channels;
	$wav_header[23] = ($num_channels >> 8) & 0xff;
	# SampleRate
	$wav_header[24] = $sample_rate & 0xff;
	$wav_header[25] = ($sample_rate >> 8) & 0xff;
	$wav_header[26] = ($sample_rate >> 16) & 0xff;
	$wav_header[27] = ($sample_rate >> 24) & 0xff;
	# ByteRate
	my $byte_rate = $sample_rate * $num_channels * $bytes_per_sample;
	$wav_header[28] = $byte_rate & 0xff;
	$wav_header[29] = ($byte_rate >> 8) & 0xff;
	$wav_header[30] = ($byte_rate >> 16) & 0xff;
	$wav_header[31] = ($byte_rate >> 24) & 0xff;
	# BlockAlign
	my $block_align = ($num_channels * $bits_per_sample) / 8;
	$wav_header[32] = $block_align & 0xff;
	$wav_header[33] = ($block_align >> 8) & 0xff;
	# BitsPerSample
	$wav_header[34] = $bits_per_sample & 0xff;
	$wav_header[35] = ($bits_per_sample >> 8) & 0xff;
	print pack("C*", @wav_header);
}

if (!defined $name) {
	if ($file =~ /^(\w{1,8})\./) {
		$name = uc $1;
	} else {
		$name = "BINARY";
	}
}

my $file_info = do {
	if ($mode == BINARY_DRAGONDOS) {
		read_dragondos($in);
	} elsif ($mode == BINARY_COCO) {
		read_coco($in);
	} else {
		read_raw($in);
	}
};

die "Internal error\n" unless defined $file_info;
die "No data\n" unless exists $file_info->{'segments'};

my $filetype = $file_info->{'filetype'} // TYPE_BINARY;
my $start0 = $file_info->{'segments'}[0]->{'start'} // 0;
$load //= $start0;
my $offset = $load - $start0;
my $start = $start0 + $offset;
my $end = $start;
my $data;
$exec //= ($file_info->{'exec'} // 0) + $offset;

my @segments = ();
while (my $s = shift @{$file_info->{'segments'}}) {
	my $ssize = bytes::length($s->{'data'});
	my $sstart = $s->{'start'} + $offset;
	my $send = $sstart + $ssize;
	if ($sstart < $start) {
		printf STDERR "Can't handle out of order segments: \%04x < \%04x\n", $sstart, $start;
		exit 1;
	}
	# TODO
	if ($sstart < $end) {
		die "Can't handle overlapping segments\n";
	}
	# TODO
	if ($send >= 0x10000) {
		die "Segment too large\n";
	}
	if ($sstart > $end) {
		$data .= "\0" x ($sstart - $end);
	}
	$data .= $s->{'data'};
	$end = $send;
}

my $ptr = 0;
my $size = $end - $start;

# Special case: if a list of blocks is specified, output those blocks only.

if (scalar(@blocks) > 0) {
	my $type = 1;
	while (my $block = shift @blocks) {
		if ($block eq 'l') {
			bytes_out("U" x $leader);
		} elsif ($block eq 'p') {
			if ($wav_out) {
				sample_out(0x80, 0xda5c * 8 * 16);
			} else {
				bytes_out("U" x 128);
			}
		} elsif ($block =~ /^(\d+|0x[\da-f]+)(:(-?\d+|0x[\da-f]+))?$/) {
			my $type = eval $1;
			my $bsize;
			if (defined $3) {
				$bsize = eval $3;
				$bsize += $size if ($bsize < 0);
				$bsize = 255 if ($bsize > 255);
			} else {
				$bsize = ($size > 255) ? 255 : $size;
			}
			$size -= $bsize;
			block_out($type, bytes::substr($data, $ptr, $bsize));
			$ptr += $bsize;
		} else {
			last;
		}
	}
} else {

	$exec //= $start;

	if ($want_fnblock) {
		bytes_out("U" x $leader);
		my $fndata = sprintf("%-8s%c\x00\x00%c%c%c%c", $name, $filetype, $exec>>8, $exec & 0xff, $load >> 8, $load & 0xff);
		block_out(BLOCK_NAMEFILE, $fndata);
		if ($wav_out) {
			sample_out(0x80, 0xda5c * 8 * 16);
		}
	}

	bytes_out("U" x $leader);

	while ($size > 0) {
		my $bsize = ($size > 255) ? 255 : $size;
		$size -= $bsize;
		if ($size == 0 && $want_eofblock) {
			if ($eof_data) {
				block_out(BLOCK_EOF, bytes::substr($data, $ptr, $bsize));
			} else {
				block_out(BLOCK_DATA, bytes::substr($data, $ptr, $bsize));
				block_out(BLOCK_EOF, "");
			}
		} else {
			block_out(BLOCK_DATA, bytes::substr($data, $ptr, $bsize));
		}
		$ptr += $bsize;
	}

	bytes_out("U");
}

if ($wav_out) {
	# rewrite Subchunk2Size
	seek(STDOUT, 40, 0);
	print pack("C", $sample_count & 0xff);
	print pack("C", ($sample_count >> 8) & 0xff);
	print pack("C", ($sample_count >> 16) & 0xff);
	print pack("C", ($sample_count >> 24) & 0xff);
	# rewrite ChunkSize
	$sample_count += 36;
	seek(STDOUT, 4, 0);
	print pack("C", $sample_count & 0xff);
	print pack("C", ($sample_count >> 8) & 0xff);
	print pack("C", ($sample_count >> 16) & 0xff);
	print pack("C", ($sample_count >> 24) & 0xff);
}

exit 0;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# File readers

# Raw binary: just slurp data in 64K segments
sub read_raw {
	my $in = shift;
	my %file_info = ();

	my $sstart = 0;
	my $data;
	my $rsize;
	do {
		$rsize = read $in, $data, 0x10000;
		push @{$file_info{'segments'}}, {
			'start' => $sstart,
			'data' => $data,
		};
		$sstart += $rsize;
		$sstart &= 0xffff;
	} while ($rsize == 0x10000);

	return \%file_info;
}

# DragonDOS binary - single segment only
sub read_dragondos {
	my $in = shift;
	my %file_info = ();

	getc($in);  # skip $55
	my $filetype = unpack("C", getc($in));
	my $sstart = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
	my $ssize = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
	my $exec = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
	getc($in);  # skip $aa

	$file_info{'filetype'} = $ddos_to_tape_type{$filetype} // TYPE_BINARY;
	$file_info{'exec'} = $exec;

	my $data;
	my $rsize = read $in, $data, $ssize;
	if ($rsize != $ssize) {
		print STDERR "Warning: short read from DragonDOS binary\n";
	}
	push @{$file_info{'segments'}}, {
		'start' => $sstart,
		'data' => $data,
	};

	return \%file_info;
}

# CoCo (DECB) - binaries can contain multiple segments

# BASIC files are: $ff size>>8 size data*
# BINARY files are: ($00 size>>8 size data*)+ $ff 00 00 exec>>8 exec
#   (binaries can contain multiple segments)

sub read_coco {
	my $in = shift;
	my %file_info = ();

	my $filetype;
	my $exec = 0;

	while (my $stype = getc($in)) {
		$stype = unpack("C", $stype);

		my $ssize = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
		my $sstart;

		if ($stype == 0x00) {
			$filetype //= TYPE_BINARY;
			$sstart = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
		} elsif (!defined $filetype && $stype == 0xff) {
			$filetype = TYPE_BASIC;
			$sstart = 0;
			$exec = 0;
		} elsif ($stype == 0xff) {
			if ($ssize != 0) {
				# XXX is this dodgy?
				printf STDERR "Warning: EXEC segment with non-zero size in CoCo binary\n";
			}
			$exec = (unpack("C", getc($in)) << 8) | unpack("C", getc($in));
		} else {
			printf STDERR "Warning: skipping data in CoCo binary\n";
			last;
		}

		if ($ssize > 0) {
			my $data;
			my $rsize = read $in, $data, $ssize;
			if ($rsize != $ssize) {
				print STDERR "Warning: short read from CoCo binary\n";
			}
			push @{$file_info{'segments'}}, {
				'start' => $sstart,
				'data' => $data,
			};
		}
	}
	$file_info{'filetype'} = $filetype // TYPE_BINARY;
	$file_info{'exec'} = $exec;

	return \%file_info;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub block_out {
	my ($type,$data) = @_;
	my $bsize = bytes::length($data);
	my $sum = $type + $bsize;;
	bytes_out(pack("C*", 0x55, 0x3c, $type, bytes::length($data)));
	bytes_out($data);
	for (unpack("C*", $data)) {
		$sum += $_;
	}
	bytes_out(pack("C*", ($sum & 0xff), 0x55));
}

sub bytes_out {
	my $data = shift;
	if (!$wav_out) {
		print $data;
		return;
	}
	for my $byte (unpack("C*", $data)) {
		for (0..7) {
			my $cycles = ($byte & 1) ? 176 : 352;
			for (@wav_samples) {
				sample_out($_, $cycles);
			}
			$byte >>= 1;
		}
	}
}

sub sample_out {
	my $samp = shift;
	my $cycles = shift;
	$write_cycles += $cycles;
	while ($write_cycles > $cycles_per_frame) {
		$write_cycles -= $cycles_per_frame;
		print pack("C", $samp);
		$sample_count++;
	}
}
