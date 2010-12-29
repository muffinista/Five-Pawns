#!/usr/bin/env perl

my $entries_per_line = 50;

use strict;
my $holdTerminator = $/;
undef $/;

my $buf = <STDIN>;
$/ = $holdTerminator;

my @data = split(/,/, $buf);

my $count = 0;
my @tmp;

foreach my $k (@data) {
	push @tmp, $k;
	$count++;

	if ( $count >= $entries_per_line ) {
		print join ",", @tmp;
		print "\n";
		$count = 0;
		@tmp = ();
	}
}

if ( $count > 0 ) {
	print join ",", @tmp;
}
