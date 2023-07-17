#!/usr/bin/env perl

use strict;
use warnings;

my ($vcf) = @ARGV;


#### 01. convert vcf to annovar avinput

my $annovar_bin = qq{/results/software/annovar/convert2annovar.pl};
system qq{perl $annovar_bin -format vcf4 $vcf  > variant.avinput\n};

#### 02. parse variant.avinput to get annovar format ref alt and chrom position
my %hash = ();
my $cnt = 0;
open TXT, qq{variant.avinput} or die "Can't open variant.avinput!\n";
while (<TXT>) {
	chomp;
	$cnt++;
	my @arr = split /\t/;
	$hash{$cnt} = join "\t", @arr[0..4];
}
close TXT;


my $head = qq{#Chr\tStart\tEnd\tRef\tAlt\tCLNALLELEID\tCLNDN\tCLNDISDB\tCLNREVSTAT\tCLNSIG};
print qq{$head\n};

my $num = 0;
open VCF, $vcf or die "Can't open $vcf!\n";
while (<VCF>) {
	chomp;
	next if /^#/;
	$num++;

	my $pos  = $hash{$num};
	my @arr = split /\t/;
	my $chrom = $arr[0];
	my $start = $arr[1];
	my $end   = $arr[1] + length($arr[4]) - 1;
	my $ref   = $arr[3];
	my $alt   = $arr[4];
	my ($id)  = $_ =~ /ALLELEID=(\d+)/;
	my ($db)    = $_ =~ /CLNDISDB=(\S+?);/;
	my ($dn)    = $_ =~ /CLNDN=(\S+?);/;
	my ($stat)  = $_ =~ /CLNREVSTAT=(\S+?);/;

	$stat =~ s/,/\\x2c/;

	my ($sig)   = $_ =~ /CLNSIG=(\S+?);/;

	if ((not defined $dn) or (not defined $db) or (not defined $sig) or (not defined $stat) ) {
		# print qq{$_\n};
	} else {
		print qq{$pos\t$id\t$dn\t$db\t$stat\t$sig\n};
	}
	
}
close VCF;
