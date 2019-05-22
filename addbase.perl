#!/usr/bin/perl

# 入力: <表記/品詞/品詞細分類+活用型/KKCI> 列
# or <表記/品詞/品詞細分類+活用型/KKCI/発音> 列

# 出力: <表記/品詞/品詞細分類+活用型/KKCI/終止形表記> 列
# 活用語幹のみ"/終止形表記"を追加、語尾や非活用語は"/NA"を追加します

# 発音も残したい場合や、終止形のKKCI・発音が必要な場合は
# sub getBaseform{}を改変してください

# $part: 品詞
# $fine: 品詞細分類+活用型


use encoding "utf-8";
use strict;


### 終止形復元リスト読み込み
open(S,"<:encoding(utf-8)", "base.list") || die;

my $af = 0;
my $rf = 0;
my $bf = 0;

my %add;
my %rep;
my %roa;

my %addpr;
my %reppr;
my %roapr;

my @cType;

while (<S>) {
    chomp;
    next if ($_ =~ /^\#/);
    next unless ($_);
    if ($_ =~ /</) {
	$af = 1 if ($_ =~ /add/);
	$af = 0 if ($_ =~ /\/add/);
	$rf = 1 if ($_ =~ /rep/);
	$rf = 0 if ($_ =~ /\/rep/);
	$bf = 1 if ($_ =~ /roa/);
	$bf = 0 if ($_ =~ /\/roa/);
	next;
    }
    if ($bf) {
	my ($cType, $gobi, $roapr) = split(/,/, $_);
	push(@cType, $cType);
	$roa{$cType} = $gobi;
	$roapr{$cType} = $roapr;
    }
    if ($rf) {
	my ($cType, $repstr, $reppr) = split(/,/, $_);
	push(@cType, $cType);
	$rep{$cType} = $repstr;
	$reppr{$cType} = $reppr;
    }
    elsif ($af) {
	my ($cType, $gobi, $addpr) = split(/,/, $_);
	push(@cType, $cType);
	$add{$cType} = $gobi;
	$addpr{$cType} = $addpr;
    }
}
close S;

### main

while (<>) {
    chomp;
    my @unit = split(/ /, $_);
    my @out;
    foreach my $u (@unit) {
	my $base = &getBaseform($u);
	push(@out, $base);
    }
    print join(" ", @out), "\n";
}


# 終止形を復元
sub getBaseform {
    my $unit = shift;
    my ($word, $part, $fine, $kkci, $pron) = split(/\//, $unit);
    my ($dpart, $cType) = split(/\+/, $fine);
#    return "$word/$part/$fine/$kkci/$pron/NA" unless ($cType);
    return "$word/$part/$fine/$kkci/NA" unless ($cType);
    # 分割後の語尾は復元しない
#    return "$word/$part/$fine/$kkci/$pron/NA" if ($fine =~ /語尾/);
    return "$word/$part/$fine/$kkci/NA" if ($fine =~ /語尾/);

    my ($retw, $retk, $retpr) = ($word, $kkci, $pron);
    my $exist;
    foreach my $ct (@cType) {
	if ($cType =~ /$ct/) {
	    if ($roa{$ct}) {
		# サ変、カ変
		if ($dpart =~ /非自立可能/) {
		    $retw = $roa{$ct};
		    $retk = $roa{$ct};
		    $retpr = $roapr{$ct};
		}
		elsif ($dpart =~ /一般/) {
		    $retw .= $roa{$ct};
		    $retk .= $roa{$ct};
		    $retpr .= $roapr{$ct};
		}
		else {
		    warn "unknown verb-category: $part\n";
		    $retw .= $roa{$ct};
		    $retk .= $roa{$ct};
		    $retpr .= $roapr{$ct};
		}

	    }
	    elsif ($rep{$ct}) {
		$retw = $rep{$ct};
		$retk = $rep{$ct};
		$retpr = $reppr{$ct};
	    }
	    elsif ($add{$ct}) {
		$retw .= $add{$ct};
		$retk .= $add{$ct};
		$retpr .= $addpr{$ct};
	    }
	    $exist = 1;
	    last;
	}
    }
    if (!$exist) {
	warn "unknown cType:\n$unit\n";
#	return "$word/$part/$fine/$kkci/$pron/NA";
	return "$word/$part/$fine/$kkci/NA";
    }
#    return "$word/$part/$fine/$kkci/$pron/$retw";
    return "$word/$part/$fine/$kkci/$retw";
}
