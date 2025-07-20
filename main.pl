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
$/ = "";  # Multi-line paragraph mode for file reading

sub get_files {
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

sub process_line {
	print if DEBUG;
	my @text;

	# operates on $_
	if (/[ \t]+</) {
		(@text) = split /<.*?>/, trim $_;
	}

	# remove space only lines
	@text = grep { $_ ne '[ \t\n]+' } @text;

	# remove embedded tags
	@text = grep { $_ !~ /<.*(\/>|)/ } @text;
	return @text;
}

sub process_file {
	my $filename = shift;
	my $text = "";
	open (FILE, $filename) || die "Can't open file: $!\n";
	while (<FILE>) {
		my @chunk = process_line;
		$text .= join('',@chunk);
	}
	return $text;
}

sub normalize {
	my $s = shift;
    $s =~ s/[\,\:\(\)]+//g;	# remove punctuation
	$s =~ s/\.(?=\s)//g;	# remove periods (at ends of words)
	$s =~ s/&.*?;//g;	# remove '&rquo;' type characters
	$s =~ s/\s+/ /g;	# remove spaces
	return $s;	
}

sub main {
	my @files = get_files @ARGV;
	foreach my $file (@files) {
		my $text = process_file $file;
		$text = normalize $text;
		print $text, "\n";
	}
}

main() unless caller();
