#!usr/bin/perl
# ============================
# 
# PROGRAM: main.pl
# 
# PURPOSE: Basic html scraper
# that reports some stats
# about the text on the page
# 
# @author Sebastian Arana
#
# ============================
use strict;
use warnings;
use constant DEBUG => 0;

sub getFiles {
	my @input_files = @_;
	my @files = ();
	while (@ARGV) {
		my $new_file = shift @ARGV;
		if ($new_file !~ /\.html$/i) {
			warn "Non-HTML file in input: $new_file";
			next;
		}
		push(@files, $new_file);
	}
	return @files;
}

sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

sub main {
	my @files = getFiles @ARGV;
	foreach my $file (@files) {
		open (my $FILE, "<", $file) or die "$!";
		while (my $line = <$FILE>) {
			my @text = "";
			
			print $line if DEBUG;
			
			if ($line =~ /[ \t]+</) {
				(@text) = split /<.*?>/, trim $line;
			}

			@text = grep { $_ ne '[ \t\n]+' } @text;
			print join('',@text),"\n" if @text;
		}
		close $FILE;
	}
}

main() unless caller();
