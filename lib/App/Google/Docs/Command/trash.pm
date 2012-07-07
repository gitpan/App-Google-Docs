package App::Google::Docs::Command::trash;
{
  $App::Google::Docs::Command::trash::VERSION = '0.09';
}

use App::Google::Docs -command;

use warnings;
use strict;

=head1 NAME

App::Google::Docs::Command::trash - Move a document to the trash

=head1 VERSION

version 0.09

=head1 SYNOPSIS

    $ gdocs trash FILE [ FILE ... ]

This will move a bunch of documents, identified by the given filenames, to the
Google Docs trash.

=cut

sub abstract { 'move a document to the trash' }

sub usage_desc {
	return '%c trash %o files...';
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $auth = $self -> auth;

	foreach (@$args) {
		print "Moving '$_' to trash... ";
		my $info = $self -> do_trash($_, $auth);
		print "Done.\n";
	}
}

sub do_trash {
	my ($self, $file, $auth) = @_;

	my $docs    = $self -> get_docs($file, $auth);
	my $res_id  = $docs -> [0] -> {'res_id'};
	my $url     = "https://docs.google.com/feeds/documents/private/full/$res_id";
	my $request = HTTP::Request -> new(DELETE => $url);

	$request -> header('If-Match' => '*');

	my $response = $self -> do_request($request, $auth);

	die "Err: Not found\n"
		if $response -> {'status'} == 404;

	die "Err: ".$response -> {'body'}."\n"
		unless $response -> {'status'} == 200;
}

=head1 OPTIONS

=head2 --email, -e

Set login email

=head2 --pwd, -p

Set login password

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::Google::Docs::Command::trash
