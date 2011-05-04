package App::Google::Docs::Command::upload;
BEGIN {
  $App::Google::Docs::Command::upload::VERSION = '0.06';
}

use App::Google::Docs -command;

use File::Basename;
use LWP::MediaTypes;

=head1 NAME

App::Google::Docs::Command::upload - Upload a bunch of files

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    $ gdocs upload FILE [ FILE ... ]

This will upload some files to Google Docs.

=cut

sub abstract { 'upload a bunch of files' }

sub usage_desc {
	return '%c upload %o FILE1 [ FILE2 [ FILE3 ] ... ]';
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $auth = $self -> auth;

	foreach (@$args) {
		print "Uploading '$_'... ";
		my $info = $self -> do_upload($_, $auth);
		print "Done. Direct link: ".$info -> {'link'}."\n";
	}
}

sub do_upload {
	my ($self, $filename, $auth) = @_;

	open my $file, $filename or die "Err: Unable to read '$filename'.\n";
	my $data = join("", <$file>);
	close $file;

	my $url = "https://docs.google.com/feeds/documents/private/full?alt=json";

	my $request = HTTP::Request -> new(POST => $url);

	$request -> content_length(length $data);
	$request -> content_type(guess_media_type($filename));
	$request -> header(Slug => basename($filename));
	$request -> content($data);

	my $response = $self -> do_request($request, $auth);

	die "Err: ".$response -> {'body'}."\n"
		unless $response -> {'status'} == 201;

	my $json_text = JSON -> new -> decode($response -> {'body'});

	my $title = $json_text -> {entry} -> {title} -> {'$t'};
	my $link  = $json_text -> {entry} -> {link}[0] -> {href};

	return { 'title' => $title, 'link' => $link };
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::Google::Docs::Command::upload