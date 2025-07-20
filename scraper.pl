#!/bin/perl
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

# an important convention in perl: required scope annotation
use strict;

# another convention, just warning messages
use warnings;

# Specific libraru import of "max" function
use List::Util qw(max);

# debug constant, like C macro but must be set here
use constant DEBUG => 0;

$/ = "";  # Multi-line paragraph mode for file reading

# The first example of a perl 'function', called a subroutine.
# It takes parameters through a global list variable @_, which must be
# unpacked to get the parameters. This is useful because the parameter
# list can be any size, which is used here to open any number of files.
sub get_files {
	# parameter list is moved to named list variable
	# (one of the three explicit types, lists are always marked with '@')
	# 'my' keyword indicates scope; Similar to 'private' in Java
	my @input_files = @_;

	# new empty list
	my @files = ();

	# Perl lists are linked lists of boxed values.
	# This loop continues until the list has no values left.
	while (@input_files) {
		# Another of perl's three main types, the 'scalar'.
		# Always marked with '$'.
		# It accesses the list by popping off the head.
		my $new_file = shift @ARGV;

		# first use of regex matching: !~ operator
		# checks if regex (between //) is NOT found in string
		if ($new_file !~ /\.html$/i) {
			# use of warnings; non fatal
			# String literals can have variables interpolated,
			# once again using '$' to indicate a variable
			warn "Non-HTML file in input: $new_file";

			# like Python's 'continue', moves to next loop iteration
			next;
		}

		# (library func) adds to head of linked list
		push(@files, $new_file);
	}
	return @files;
}

# param: string to be trimmed
sub trim {
	my $s = shift;

	# another regex operation: =~ in this case
	# finds and replaces leading/trailing whitespace
	# indicated by s///g regex
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

sub process_line {
	# parameter $_ is not unpacked here.
	# One of perl's features for efficiency is setting
	# every function/operator's input as $_ by default.
	my @text;

	# a regex match, technically using =~ on invisible
	# $_ parameter. Not typically good style but can
	# make for shorter, more direct functions.
	#
	# I will only demonstrate it here, because for larger files it can become
	# extremely hard to read without extracting and naming $_.
	if (/[ \t]+</) {
		# split func takes regex (matches text between tags)
		# split also takes string to split
		# Notice parameters are not inside parentheses, a stylistic choice.
		(@text) = split /<.*?>/, trim $_;
	}

	# Perl's library includes many unix-style functions, like grep.
	# This one searches through a list for strings that do not match
	# the regex and filters out the others.
	# Removes whitespace-only strings.
	@text = grep { $_ ne '[ \t\n]+' } @text;

	# another grep search, this time filtering out nested tags that 
	# slipped through the initial extraction
	@text = grep { $_ !~ /<.*(\/>|)/ } @text;

	return @text;
}

sub process_file {
	my $filename = shift;
	my $text = "";

	# perl provides clean inline try-catch blocks:
	# || operator detects a failure to open, and terminates
	# with error message (hence the 'die' function).
	# Notice the interpolated $! variable - this holds
	# error messages set by try blocks like 'open'.
	open (FILE, $filename) || die "Can't open file: $!\n";

	# perl makes file reading very easy: this simply loops over
	# paragraphs within the file (typically lines, but remember
	# paragraph mode was set in the beginning).
	while (<FILE>) {
		my @chunk = process_line;

		# .= operator concatenates strings. $text variable
		# is collecting the merged line strings from the files.
		$text .= join('',@chunk);
	}
	return $text;
}

sub normalize {
	my $s = shift;

	# a series of find/replace operations.
	# Cleans up the text for easier processing.
	$s =~ s/&.*?;//g;	# remove '&rquo;' type characters
	$s =~ s/[^a-zA-Z ]//g;		# remove non-alphabetical
	$s =~ s/\s+/ /g;	# cut spaces down to one
	$s =~ tr/A-Z/a-z/;	# make all letters lowercase
	return $s;	
}

sub wc {
	my $text = shift;
	# This is a complex series of operations:
	# First, $text is matched with all space characters.
	# Then, those matches are placed in a new list.
	# Then the list is placed into a SCALAR variable,
	# not a list. Perl by default puts a lists' LENGTH
	# if it is put into a scalar.
	my $wordcount = () = $text =~ /\S+/g;
	return $wordcount;
}

sub word_counts {
	my @word_list = shift;

	# Perl's third explicit type: the hash.
	# Works exactly like a python dict.
	my %word_counts;

	# Perl encourages use of for each loops:
	# In python, this might look like
	# 'for word in word_list:'
	# Notice here, $word has its scope annotated
	foreach my $word (@word_list) {
		
		# Hashmap's VALUE is accessed as a scalar ($)
		# Key is entered between { }.
		$word_counts{$word} += 1;
	}
	return %word_counts;
}

sub most_frequent_words {
	my @words = shift;
	my %word_counts = word_counts @words;

	# library func 'values' used here.
	# Exactly like python 'dict.values()'.
	my $max_occurences = max(values %word_counts);

	my @top_words;
	# 'keys' func gets keys from dict.
	foreach my $word (keys %word_counts) {
		if ($word_counts{$word} == $max_occurences) {
			# remember 'push' adds to the head of a list
			push @top_words, $word;
		}
	}
	return @top_words;
}

sub filter_stopwords {
	my $cleantext = shift;

	# stopwords from python nltk
	# List is explicitly declared here.
	# Notice each line is a sub-list declared with 'qw'.
	# This allows elements of a list to be separated by only spaces
	# assuming they are strings.
	# The final list will simply be a list of strings, this just makes
	# declarations cleaner.
	my @stopwords_list = (qw(i me my myself we our ours ourselves you youre youve youll),
	   						qw(youd your yours yourself yourselves he him his himself she),
							qw(shes her hers herself it its itself they them their theirs),
						   	qw(themselves what which who whom this that thatll these those),
						   	qw(am is are was were be been being have has had having do does),
							qw(did doing a an the and but if or because as until while of at),
							qw(by for with about against between into through during before),
							qw(after above below to from up down in out on off over under),
						   	qw(again further then once here there when where why how all any),
							qw(both each few more most other some such no nor not only own),
							qw(same so than too very can will just dont should shouldve now),
							qw(arent couldnt didnt doesnt hadnt hasnt havent isnt mightnt),
							qw(mustnt neednt shant shouldnt wasnt werent wont wouldnt)
						);

	# map function works just like in functional programming.
	# There is even an anonymous function.
	# Simply creates a hashmap of values from @stopwords_list
	# to the number 1 for fast lookups.
	my %stopwords = map { $_ => 1 } @stopwords_list;

	my @words = split(' ', $cleantext);
	
	# grep filters out strings in the stopwords hashmap.
	@words = grep { !$stopwords{$_} } @words;

	return @words;
}

sub print_info {
	# three shift operations extract parameters #1, #2, #3
	my $filename = shift;
	my $text = shift;
	my @words = shift;
	
	my $word_count = wc $text;
	my @top_words = most_frequent_words @words;

	# perl's 'print' function expects a list of scalars as a parameter.
	# These can be anything printable, and the list is heterogenous.
	# Functions that return strings, lists are interpolated.
	# Notice the last two prints are conditional, using the inline 'if'.
	# Also notice that the value returned by @top_words is its length.
	print "FILE: $filename","\n";
	print "\tWord Count: $word_count", "\n";
	print "\tMost Frequent Content Word: ", shift @top_words, "\n" if @top_words == 1;
	print "\tMost Frequent Content Words: ", join(' ', @top_words), "\n" if @top_words > 1;
}

# a main subroutine is NOT required in perl, but is good style.
sub main {
	my @files = get_files @ARGV;
	foreach my $file (@files) {
		my $text = process_file $file;
		$text = normalize $text;
		my @words = filter_stopwords $text;
		print_info($file, $text, @words);
	}
}

# Just like python, main is called at the end.
# Notice no parameters are passed, so main is just a word.
# Perl knows it is a function because it is not annotated
# as scalar '$', list '@' or hash '%'. 
main;
