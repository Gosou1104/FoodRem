#!/usr/bin/perl

# xmlをtsvに変換

use encoding "utf-8";
use strict;

$/ = "\r\n";

my $sampleID;

# my %SUWTags;

while (<>) {
    chomp;
    if ($_ =~ / sampleID="(.+?)" /) {
	$sampleID = $1;
    }
    next unless ($_ =~ /<SUW/);

    my @suw = $_ =~ m/<SUW .+?<\/SUW>/g;
    for my $s (@suw) {
	$s =~ /^<SUW (.+?)>(.+?)<\/SUW>/;
	my ($elemstr, $word) = ($1, $2);

	my %elem;
	for my $e (split(/ /, $elemstr)) {
	    $e =~ /(.+?)="(.+?)"/;
	    $elem{$1} = $2;
#	    $SUWTags{$1}++;
	}
	printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n", 
	       $sampleID, $elem{"orderID"}, $elem{"lemmaID"}, $elem{"start"}, $elem{"end"}, 
	       $elem{"lemma"}, $elem{"lForm"}, $elem{"subLemma"}, 
	       $elem{"wType"}, $elem{"pos"}, $elem{"cType"}, $elem{"cForm"}, 
	       $elem{"formBase"}, $elem{"usage"}, $elem{"orthBase"}, $elem{"originalText"},
	       $elem{"kana"}, $elem{"pron"}, $word);
    }
    print "\n";
}

# foreach (sort keys %SUWTags) {
#     print "$_\n";
# }
