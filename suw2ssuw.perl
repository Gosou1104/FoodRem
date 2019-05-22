#!/usr/bin/perl

# xml2tsv.perlで作成した短単位(SUW)tsvを超短単位(SSUW)tsv形式に変換
# KKCIを作成
# -nosegで短単位のまま

# 活用語尾表を用いて語尾を分割する

# 後で各関数の引数をハッシュにする

# Perl 5.8.1以上が必須
# Perl 5.10.1 以上を推奨

# 全ての単語に"記事ID-記事内単語ID-EOSフラグ-NAフラグ"を追加する

# EOSフラグ: 文末フラグ
#     tagNA: missingCharacter, imageタグを付与された単語
#     eucNA: utf-8 -> euc-jpの変換が不可, もしくは拡張3バイトeuc-jp文字を含む単語
#     eucNAな単語を除けば全ての文字がJIS X 0208文字集合に含まれる（はず）
#       - そうでもなかったので単漢字辞書で6879文字に入るかどうかチェックした

use encoding "utf-8";
use Encode;
use strict;
use Getopt::Long;
use Char_dev; # この書き方微妙かも

# my %ADDTANKAN;
my $ERRWORD;

my $KKCI_REGEXP = &getKkciRegExp();

my %SKIPCHAR;
# my %POSTYPES;

my $OPTS = {};
#GetOptions($OPTS, 'noseg', 'format=i', 'tagdelim', 'myformat=s', "skip=s", 'debug=s', 'euc', 'gobi=s');
GetOptions($OPTS, 'noseg', 'format=i', 'tagdelim', 'myformat=s', 'euc', 'gobi=s');

# 活用語尾表
my $STDGOBI;
my $EXGOBI;

my $PTW2F;
my $WPT2F;
my $W2K;

$OPTS->{'gobi'} = "gobi.csv" unless ($OPTS->{'gobi'});
open(GT, "<:encoding(utf-8)", $OPTS->{'gobi'}) || die;

while (<GT>) {
    chomp;
    next if ($_ =~ /^\#/);
    next unless ($_);
    my @tmp = split(/,/, $_);
    die "Wrong format: $_\n" unless ($tmp[0]);
    my $pt = join(",", @tmp[0..2]);
    my $w = join("", @tmp[3..5]);
    my $pr = join("", @tmp[9..11]);

    if ($tmp[3] eq "*") {
	push(@{$STDGOBI->{$pt}}, $_);
    }
    else {
	$EXGOBI->{$w}{$pt}{pron} = $pr;
	$EXGOBI->{$w}{$pt}{form} = $_;
    }
}
close GT;

# 単漢字辞書 JIS X 0208+

my $TANKAN;

open(TANKAN, "<:encoding(utf-8)", "tankan.wordkkci") || die;
while (<TANKAN>) {
    chomp;
    my ($c, $k) = split(/\//, $_);
#    $TANKAN->{$c}{$k} = 1;
    push(@{$TANKAN->{$c}}, $k);
}
close TANKAN;


# Default
# tagdelim: tab
#        1: word/pos/kkci/pron/wordID/tags

$OPTS->{'format'} = 1 unless ($OPTS->{'format'});

my $SPFORM = "%s\t%s\t%s\t%s\t%s\t%s\t%s";

$/ = "\n\n";

while (<>){
    chomp;
    warn "format error.\n" unless ($_);
    my @lines = split(/\n/, $_);
    my @out;
    for my $i (0..$#lines) {

	# 文スキップに使うフラグ
	my $tagNA = 0; # 1: タグを除去しない
	my $eucNA = 0; # 1: utf-8 -> euc-jpの変換不可 or 3byte拡張euc-jp
	my $posNA = 0; # 1: web誤脱 || 未知語 || 漢文

	my $NAflags; # $tagNA-$eucNA-$posNA
	my $wID = $i+1;
	my @elem = split(/\t/, $lines[$i]);
	my ($aID, $awID, $lemma, $lForm, $pos, $cType, $cForm, $baseForm, $orthBase, $kana, $pron, $word) = (@elem[0,1], @elem[5,6], @elem[9..12], $elem[14], @elem[16..18]);

	$kana =~ tr/ァ-ン/ぁ-ん/;
	$pron =~ tr/ァ-ン/ぁ-ん/;
	my $isEOS = ($i == $#lines) ? 1 : 0;
	my $wordID = "$aID-$awID";

	$word = &rmTags($word, \$tagNA);
	my $eucword;
	&checkConv($word, \$eucNA) if (!$tagNA);
	$posNA = 1 if ($pos =~ /^(web誤脱|未知語|漢文)$/);

	$NAflags = "$tagNA-$eucNA-$posNA";


	# フラグを付与した単語の処理をスキップ
	# 文ごとのスキップは最後に
	if ($tagNA || $posNA) {
	    # kana, pronは無い
	    my $outstr = sprintf("$SPFORM", $word, $pos, $pron, $pron, $wordID, $isEOS, $NAflags);
	    push(@out, $outstr);
	    next;
	}
# 	elsif ($OPTS->{'euc'} && $eucNA) {
# 	    my $outstr = sprintf("$SPFORM", $word, $pos, $pron, $wordID, $isEOS, $NAflags);
# 	    push(@out, $outstr);
# 	    next;
# 	}
	my $kkci;
	$kkci = &makeKkci($word, $kana, $pron, $orthBase, $baseForm, $lemma, $lForm, $cType);

	# 語尾分割($word, $kkci, $pron)
	if (!$OPTS->{'noseg'} && $cType) {
	    warn unless ($cForm);

	    my @sunits; # ($sword1/$skkci1/$spron1/$spos1, $sword2/$skkci2/$spron2/$spos2, ...)
	    if (&segmentWord($word, $kkci, $lemma, $lForm, $pron, $pos, $cType, $cForm, \@sunits)) {
		for my $j (0..$#sunits) {
		    my ($sword, $skkci, $spron, $spos) = split(/\//, $sunits[$j]);
		    my $sid = ($j+1) * 10;
		    my $swordID = "$wordID-$sid";
		    my $sisEOS = ($isEOS && $j == $#sunits) ? 1 : 0;
		    my $outstr = sprintf("$SPFORM", $sword, $spos, $skkci, $spron, $swordID, $sisEOS, $NAflags);
		    push(@out, $outstr);
		}
	    }
	    else {
		my $temppos = $pos;
		$temppos =~ s/-.+//;
		$pos = "$temppos=$pos=$cType=$cForm==";
		$pron = "NA" unless ($pron);
		my $outstr = sprintf("$SPFORM", $word, $pos, $kkci, $pron, $wordID, $isEOS, $NAflags);
		push(@out, $outstr);
	    }
	}
	else {
	    my $temppos = $pos;
	    $temppos =~ s/-.+//;
	    $pos = "$temppos=$pos====";
	    $pron = "NA" unless ($pron);
	    my $outstr = sprintf("$SPFORM", $word, $pos, $kkci, $pron, $wordID, $isEOS, $NAflags);
	    push(@out, $outstr);
	}
    }

    print join("\n", @out), "\n\n" if (@out);
}

# foreach my $pt (sort keys %$ERRWORD) {
#     foreach my $e (sort keys %{$ERRWORD->{$pt}}) {
# 	print "$pt,$e\n";
#     }
# }

# 活用語尾表に従って語尾を分割

sub segmentWord {
    my ($word, $kkci, $lemma, $lForm, $pron, $pos, $cType, $cForm, $sunits) = @_;
# ($sword1/$skkci1/$spron1/$spos1, $sword2/$skkci2/$spron2/$spos2, ...)
    if (!$kkci || !$pron) {
	warn "pos error: @_\n";
	return 0;
    }

    my $pt = "$pos,$cType,$cForm";

    $pron =~ tr/ァ-ン/ぁ-ん/;

    my @orig = ($word, $kkci, $pron, $pos, $cType, $cForm);

    my @sword; # (語幹, 語尾, 助動詞)
    my @skkci;
    my @spron;
    my @spos;

    my @sref = (\@sword, \@skkci, \@spron, \@spos);

    my $exflag;

    # 例外形
    if ($EXGOBI->{$word}{$pt}{pron} eq $pron) {
	($pos, $cType, $cForm, @sword[0..2], @skkci[0..2], @spron[0..2], $exflag) = split(/,/, $EXGOBI->{$word}{$pt}{form});
	warn "wrong format: gobi table(except)\n$EXGOBI->{$word}{$pt}{form}\n" unless ($sword[0]);
	# 語尾分割品詞情報のみ付加
	&segmentKkci(\@orig, @sref, $exflag);
    }
    # 標準形
    elsif ($STDGOBI->{$pt}) {
	my $done;
	foreach my $f (@{$STDGOBI->{$pt}}) {
	    ($pos, $cType, $cForm, @sword[0..2], @skkci[0..2], @spron[0..2], $exflag) = split(/,/, $f);
	    warn "wrong format: gobi table(standard)\n$f\n" if ($sword[0] ne "*" || $skkci[0] ne "*" || $spron[0] ne "*");
	    my $wordsuf = $sword[1] . $sword[2];
	    my $kkcisuf = $skkci[1] . $skkci[2];
	    my $pronsuf = $spron[1] . $spron[2];
	    next if ($word !~ /$wordsuf$/);
	    next if ($kkci !~ /$kkcisuf$/);
	    next if ($pron !~ /$pronsuf$/);
	    ($sword[0], $skkci[0], $spron[0]) = ($word, $kkci, $pron);
	    $sword[0] =~ s/$wordsuf$//;
	    $skkci[0] =~ s/$kkcisuf$//;
	    $spron[0] =~ s/$pronsuf$//;
	    &segmentKkci(\@orig, @sref, $exflag);
	    $done = 1;
	    last;
	}
	unless ($done) {
	    warn "$pt,$word,,,$kkci,,,$pron,,,";
	    return 0;
	}
#	$ERRWORD->{$pt}{"$word,,,$kkci,,,$pron,,,"}++ unless ($done);
    }
    else {
	warn "$pt,$word,,,$kkci,,,$pron,,,";
	return 0;
#	$ERRWORD->{$pt}{"$word,,,$kkci,,,$pron,,,"}++;
    }
    for my $i (0..$#sword) {
	push(@$sunits, join("/", ($sword[$i], $skkci[$i], $spron[$i], $spos[$i]))) if ($sword[$i]);
    }
    # サ変「する」など
    return 0 if ($exflag ne "IN" && scalar(@$sunits) == 1);
    return 1;
}

# kkci(, pron)を分割
# pronは本来別のプログラムでKKCIから推定する予定
sub segmentKkci {
    my ($orig_ref, $sword_ref, $skkci_ref, $spron_ref, $spos_ref, $exflag) = @_;
    my ($word, $kkci, $pron, $pos, $cType, $cForm) = @$orig_ref;

    my $shortpos = $pos;
    $shortpos =~ s/-.+$//;
    # 品詞詳細
    if ($exflag) {
	$spos_ref->[0] = "$shortpos=$pos=$cType=$cForm=$word=${exflag}語幹" if ($sword_ref->[0]);
	$spos_ref->[1] = "語尾=語尾=$cType=$cForm=$word=S語尾" if ($sword_ref->[1]);
	$spos_ref->[2] = "助動詞=助動詞-語尾=$cType=$cForm=$word=S助動詞" if ($sword_ref->[2]);
    }
    else {
	$spos_ref->[0] = "$shortpos=$pos=$cType=$cForm=$word=S語幹" if ($sword_ref->[0]);
	$spos_ref->[1] = "語尾=語尾=$cType=$cForm=$word=S語尾" if ($sword_ref->[1]);
	$spos_ref->[2] = "助動詞=助動詞-語尾=$cType=$cForm=$word=S助動詞" if ($sword_ref->[2]);
    }
}

# kkciを作成
sub makeKkci {
    my ($word, $kana, $pron, $orthBase, $baseForm, $lemma, $lForm, $cType) = @_;
    my $kkci;

    my @char = split(//, $word);
    $kana =~ s/　/＿/g;
    if ($word =~ /^(${KKCI_REGEXP})+$/) {
	$kkci = $word;
    }
    elsif ($kana && $kana =~ /^(${KKCI_REGEXP})+$/) {
	$kkci = $kana;
    }
    elsif ($baseForm =~ /^(${KKCI_REGEXP})+$/ && $orthBase eq $word) {
	$kkci = $baseForm;
    }
    elsif ($baseForm =~ /^(${KKCI_REGEXP})+$/ && !$cType) {
	$kkci = $baseForm;
    }
    elsif ($lForm =~ /^(${KKCI_REGEXP})+$/ && $lemma eq $word) {
	$kkci = $lForm;
    }
    elsif ($lForm =~ /^(${KKCI_REGEXP})+$/ && !$cType) {
	$kkci = $lForm;
    }
    elsif ($pron) {
	if ($pron =~ /^(${KKCI_REGEXP})+$/) {
#	    warn "converted from pron.: $word $pron\n";
	    $kkci = $pron;
	}
	else {
#	    warn "estimated from tankan: $word\n";
	    foreach (@char) {
		if ($TANKAN->{$_}) {
		    $kkci .= $TANKAN->{$_}[0];
		}
		else {
		    warn "$word $_";
		}
	    }
	}
    }
    else {
#	warn "estimated from tankan: $word\n";
	foreach (@char) {
	    if ($TANKAN->{$_}) {
		$kkci .= $TANKAN->{$_}[0];
	    }
	    else {
		warn "$word $_";
	    }
	}
    }
    $kkci =~ tr/ァ-ン/ぁ-ん/;
    $kkci =~ tr/ａ-ｚ/Ａ-Ｚ/;
    $kkci =~ s/　/＿/g;
    return $kkci;
}

# UTF-8 -> EUC-JP(JIS X 0208)に変換可能かどうかをチェック
# 拡張3バイトeucのチェック
sub checkConv {
    my ($word, $eucNA_ref) = @_;
    my @chars = split(//, $word);
    for my $c (@chars) {
	my $origc = $c;
	# JIS X 0208文字集合に含まれるか
	unless ($TANKAN->{$c}) {
	    $$eucNA_ref = 1;
	    $SKIPCHAR{"out of JIS X 0208: $origc"}++;
	}

	# PERLQQ使うとencodeの第2引数が消える
	my $eucChar = encode("euc-jp", $c, Encode::PERLQQ);
	if (length($eucChar) == 1) {
	    $$eucNA_ref = 1;
	    $SKIPCHAR{"ascii: $origc"}++;
	}
	elsif (length($eucChar) == 3){
	    $$eucNA_ref = 1;
	    $SKIPCHAR{"3byte euc: $origc"}++;
	}

	elsif ($eucChar =~ /\\x\{([0-9a-fA-F]+)\}/) {
	    $$eucNA_ref = 1;
	    $SKIPCHAR{"cannot convert: $origc"}++;
	}
    }
}

# 単語表記のタグを除去
sub rmTags {
    my ($word, $tagNA_ref) = @_;

    $word =~ s/<correction.*?>//g;
    $word =~ s/<\/correction>//g;

    $word =~ s/<delete.*?>//g;
    $word =~ s/<\/delete>//g;

    $word =~ s/<enclosedCharacter.*?>//g;
    $word =~ s/<\/enclosedCharacter>//g;

    $word =~ s/<ruby.*?>//g;
    $word =~ s/<\/ruby>//g;

    $word =~ s/<sampling.*?>//g;

    $word =~ s/<subScript>//g;
    $word =~ s/<\/subScript>//g;

    $word =~ s/<superScript>//g;
    $word =~ s/<\/superScript>//g;

    $word =~ s/<webBr.*?>//g;

    if ($word =~ /<image/ || $word =~ /<missingCharacter/) {
	$$tagNA_ref = 1;
#	warn "tags NA: $word\n";
    }
    return $word;
}


