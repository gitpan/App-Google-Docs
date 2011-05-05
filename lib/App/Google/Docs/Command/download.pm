package App::Google::Docs::Command::download;
BEGIN {
  $App::Google::Docs::Command::download::VERSION = '0.07';
}

use App::Google::Docs -command;

use Cwd;

=head1 NAME

App::Google::Docs::Command::download - Download a document

=head1 VERSION

version 0.07

=head1 SYNOPSIS

    $ gdocs download FILE

This will download a document from the given filename.

=cut

sub abstract { 'download a document' }

sub usage_desc {
	return '%c download %o file';
}

sub opt_spec {
	return (
		[ "format=s", "set the download format",      { default => 'txt' } ],
		[ "dest=s",   "set the download destination", { default => getcwd } ],
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $file = shift @$args or $self -> usage_error("Err: provide a filename.");

	my $auth = $self -> auth;
	my $docs = $self -> get_docs($file, $auth);

	if (scalar @$docs > 1) {
		$self -> usage_error("Err: found more than one entry.");
	}

	print "Downloading '".$docs -> [0] -> {'title'}."'... ";
	$self -> do_download($docs -> [0], $opt -> {'format'}, $opt -> {'dest'}, $auth);
	print "Done\n";
}

sub do_download {
	my ($self, $doc, $format, $dest, $auth) = @_;

	my $res_id   = $doc -> {'res_id'};
	my $url      = "https://docs.google.com/feeds/download/documents/Export?docID=$res_id&exportFormat=$format&format=$format";
	my $request  = HTTP::Request -> new(GET => $url);
	my $response = $self -> do_request($request, $auth);

	die  "Err: ".$response -> {'body'}."\n"
		unless $response -> {'status'} == 200;

	my $out_file = "$dest/".$doc -> {'title'}.".$format";

	open $file, ">", $out_file or die "Err: unable to open '$out_file': $!.\n";
	print $file $response -> {'body'};
	close $file;
}

=head1 OPTIONS

=head2 --email, -e

Set login email

=head2 --pwd, -p

Set login password

=head2 --format, -f

Set download format (default C<txt>).

=head2 --dest, -d

Set download destination directory (default C<.>).

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::Google::Docs::Command::download