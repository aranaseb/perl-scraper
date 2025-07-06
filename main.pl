
sub println {
	print @_, "\n"
}

my $filepath = $ARGV[0];

die "Input is not an HTML file" if $filepath !~ /.html$/;

open $FILE, "<", $filepath or die "$!";

while (my $line = <$FILE>) {
	my $spantext = "";
	my $ptext = "";
	if ($line =~ /[ \t]+<p/) {
		($ptext) = $line =~ m/(?<=\>)(.*?)(?=\<\/p\>)/i;
	}
	if ($line =~ /[ \t]+<span/) {
		($spantext) = $line =~ m/(?<=\>)(.*?)(?=\<\/h)/i;
	}
	print "<span>: $spantext\n" if length($spantext) > 0;
	print "<p>: $ptext\n" if length($ptext) > 0;
}

close $FILE;
