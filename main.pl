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
use List::Util qw(max);
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
	$s =~ s/&.*?;//g;	# remove '&rquo;' type characters
	$s =~ s/[^a-zA-Z ]//g;		# remove non-alphabetical
	$s =~ s/\s+/ /g;	# cut spaces down to one
	return $s;	
}

sub wc {
	my $text = shift;
	my $wordcount = () = $text =~ /\S+/g;
	return $wordcount;
}

sub word_counts {
	my $text = shift;
	my @word_list = split(/\s+/, $text);
	my %word_counts;
	foreach my $word (@word_list) {
		$word_counts{$word} += 1;
	}
	return %word_counts;
}

sub most_frequent_words {
	my $text = shift;
	my %word_counts = word_counts $text;
	my $max_occurences = max(values %word_counts);

	my @top_words;
	foreach my $word (keys %word_counts) {
		if ($word_counts{$word} == $max_occurences) {
			push @top_words, $word;
		}
	}
	return @top_words;
}

sub print_info {
	my $filename = shift;
	my $text = shift;

	my $word_count = wc $text;
	my @top_words = most_frequent_words $text;

	print "FILE: $filename","\n";
	print "\tWord Count: $word_count", "\n";
	print "\tMost Frequent Word: ", shift @top_words, "\n" if @top_words == 1;
	print "\tMost Frequent Words: ", join(' ', @top_words), "\n" if @top_words > 1;
}
sub main {
	my @files = get_files @ARGV;
	foreach my $file (@files) {
		my $text = process_file $file;
		$text = normalize $text;
		print_info($file,$text);
	}
}

main() unless caller();
