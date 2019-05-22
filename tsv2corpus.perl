#!/usr/bin/perl

use encoding "utf-8";
use strict;
use Getopt::Long;

my $OPTS = {};
GetOptions($OPTS, 'euc', 'kkci', 'pron', 'part', 'expart', 'fine');

#$OPTS->{'kkci'} = 1 if (!$OPTS->{'kkci'} && !$OPTS->{'kana'} && !$OPTS->{'pron'});

$/ = "\n\n";
while (<>) {
    chomp;
    my @elems = split(/\n/, $_);
    my $skipSentence = 0;
    my @out;
    foreach my $e (@elems) {
	my ($word, $part, $kkci, $pron, $wordID, $isEOS, $NAflags) = split(/\t/, $e);
	$part =~ s/=(.+)//;
	my $expart = $1;
	my $finepart = join("+", (split(/=/, $expart))[0,1]);
	$expart = (split(/=/, $expart))[0];

	my $outstr = $word;
	my ($tagNA, $eucNA, $partNA) = split(/-/, $NAflags);
	$skipSentence = 1 if ($tagNA || $partNA);
	$skipSentence = 1 if ($OPTS->{'euc'} && $eucNA == 1);
	if ($OPTS->{'part'}) {
	    $outstr .= "/$part";
	}

	if ($OPTS->{'expart'}) {
	    $outstr .= "/$expart";
	}
	elsif ($OPTS->{'fine'}) {
	    $outstr .= "/$finepart";
	}

	$outstr .= "/$kkci" if ($OPTS->{'kkci'});
	$outstr .= "/$pron" if ($OPTS->{'pron'});
#	$outstr .= "/$kana" if ($OPTS->{'kana'});
	push(@out, $outstr);
    }
    next if ($skipSentence);
    print join(" ", @out), "\n";
}
