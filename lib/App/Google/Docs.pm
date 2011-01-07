package App::Google::Docs;
BEGIN {
  $App::Google::Docs::VERSION = '0.01';
}

use JSON;
use File::Basename;
use LWP::UserAgent;
use Media::Type::Simple;
use WWW::Google::Auth::ClientLogin;

use warnings;
use strict;

=head1 NAME

App::Google::Docs - bring Google Documents to the command line

=head1 VERSION

version 0.01

=head1 SYNOPSIS

Synopsis section

    use App::Google::Docs;

    my $app = App::Google::Docs -> new(
	email => $email,
	password => $password
    );

=head1 DESCRIPTION

This is an helper module for the gdocs utility.

=head1 METHODS

=head2 new( $args )

Constructor for App::Google::Docs object. Requires following parameters:

=over

=item B<email>

Specifies user's Google email

=item B<password>

Specifies user's Google password

=back

=cut

sub new {
	my ($class, %params) = @_;
	my $self = {};

	my $auth = WWW::Google::Auth::ClientLogin -> new(
		email		=> $params{'email'},
		password	=> $params{'password'},
		service		=> 'writely',
		sources		=> __PACKAGE__ . '0.01'#$__PACKAGE__::VERSION
	);

	my $result = $auth -> authenticate;

	if ($result -> {'status'} != 0) {
		die "Err: Authentication failed (".$result -> {'error'}.")\n";
	}

	$self -> {'auth'} = $result -> {'auth_token'};

	bless($self, $class);

	return $self;
}

=head2 list( $file_path )

List docuemnts.

=cut

sub list {
	my $self = shift;
	my $grep = shift || "";

	my $url = "https://docs.google.com/feeds/documents/private/full?alt=json";

	my $request = HTTP::Request -> new(GET => $url);
	$request -> authorization('GoogleLogin auth='.$self -> {'auth'});
	$request -> header('GData-Version' => '2.0');

	my $response = $self -> _request($request);

	my $json_text = JSON -> new -> decode($response -> {'body'});

	my @documents = ();

	foreach my $entry (@{$json_text -> {'feed'} -> {'entry'}}) {
		my $title 	= $entry -> {title} -> {'$t'};
		my $resource_id = $entry -> {'gd$resourceId'} -> {'$t'};

		if ($title =~ m/$grep/) {
			push @documents, {title => $title, resource_id => $resource_id};
		}
	}

	return \@documents;
}

=head2 upload( $file_path )

Upload a file to Google Docs. Requires the path to file to upload.

=cut

sub upload {
	my $self 	= shift;
	my $file_info 	= _readfile(shift);

	return -1 if ref $file_info ne 'HASH';

	my $url = "https://docs.google.com/feeds/documents/private/full?alt=json";

	my $request = HTTP::Request -> new(POST => $url);

	$request -> authorization('GoogleLogin auth='.$self -> {'auth'});
	$request -> header('GData-Version' => '2.0');
	$request -> content_length(length($file_info -> {'data'}));
	$request -> content_type($file_info -> {'mime'});
	$request -> header(Slug => $file_info -> {'name'});
	$request -> content($file_info -> {'data'});

	my $response = $self -> _request($request);

	if ($response -> {'status'} != 201) {
		print "Err: ".$response -> {'body'}."\n";
		return -1;
	}

	my $json_text = JSON -> new -> decode($response -> {'body'});

	my $title = $json_text -> {entry} -> {title} -> {'$t'};
	my $link  = $json_text -> {entry} -> {link}[0] -> {href};

	my $document = {title 	=> $title,
			link	=> $link};

	return $document;
}

=head2 download( $resource_id, $format )

Download a file from Google Docs. Requires the resource ID and the desired
format of the file to download.

=cut

sub download {
	my $self 	= shift;
	my $resource_id = shift;
	my $format	= shift;

	my $url = "https://docs.google.com/feeds/download/documents/Export?docID=$resource_id&exportFormat=$format&format=$format";

	my $request = HTTP::Request -> new(GET => $url);

	$request -> authorization('GoogleLogin auth='.$self -> {'auth'});
	$request -> header('GData-Version' => '2.0');

	my $response = $self -> _request($request);

	if ($response -> {'status'} != 200) {
		die  "Err: ".$response -> {'body'}."\n";
	}

	return $response -> {'body'};
}

=head2 trash( $resource_id )

Move a document to Google Docs' trash. Requires the resource ID of the
file to trash.

=cut

sub trash {
	my $self 	= shift;
	my $resource_id = shift;

	my $url = "https://docs.google.com/feeds/documents/private/full/$resource_id";

	my $request = HTTP::Request -> new(DELETE => $url);

	$request -> authorization('GoogleLogin auth='.$self -> {'auth'});
	$request -> header('GData-Version' => '2.0');
	$request -> header('If-Match' => '*');

	my $response = $self -> _request($request);

	if ($response -> {'status'} == 404) {
		print "Err: Not found\n";
		return -1;
	}

	if ($response -> {'status'} != 200) {
		print "Err: ".$response -> {'body'}."\n";
		return -1;
	}
}

=head1 INTERNAL METHODS

=head2 _request( $request )

Make an HTTP request and parse response.

=cut

sub _request {
	my ($self, $request) = @_;

	my $ua = LWP::UserAgent -> new;

	my $response = $ua -> request($request) -> as_string;

	my $status = (split / /,(split /\n/, $response)[0])[1];
	my $body = (split /\n\n/, $response)[1];

	chomp $body if $body;

	my $out = {'status' => $status,
		   'body'   => $body};

	return $out;
}

=head2 _readfile( $filname )

Read a file and return basename, content and mime.

=cut

sub _readfile {
	my $filename = shift;

	if (!open(FILE, $filename)) {
		print "Err: Unable to read '$filename'.\n";
		return -1;
	}

	my $data = join("", <FILE>);
	close FILE;

	my $file_info = {name => basename($filename),
			 data => $data,
			 mime => type_from_ext(($filename =~ m/([^.]+)$/)[0])};

	return $file_info;
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 BUGS

Please report any bugs or feature requests at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Google-Docs>.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Google::Docs

You can also look for information at:

=over 4

=item * GitHub page

L<http://github.com/AlexBio/App-Google-Docs>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Google-Docs>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Google-Docs>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Google-Docs>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Google-Docs/>

=back

=head1 SEE ALSO


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::Google::Docs