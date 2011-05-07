package App::Google::Docs::Command;
BEGIN {
  $App::Google::Docs::Command::VERSION = '0.08';
}

use App::Cmd::Setup -command;

use JSON;
use LWP::UserAgent;
use WWW::Google::Auth::ClientLogin;

use warnings;
use strict;

=head1 NAME

App::Google::Docs::Command - Base class for App::Google::Docs commands

=head1 VERSION

version 0.08

=head1 METHODS

=head2 get_docs( $name )

Get a list of documents matching C<$name>.

=cut

sub get_docs {
	my ($self, $grep, $auth) = @_;

	my $url     = "https://docs.google.com/feeds/documents/private/full?alt=json";
	my $request = HTTP::Request -> new(GET => $url);
	my $jdocs   = decode_json $self -> do_request($request, $auth) -> {'body'};

	$grep = defined $grep ? $grep : "";

	my @docs = ();

	foreach my $entry (@{ $jdocs -> {'feed'} -> {'entry'} }) {
		my $title  = $entry -> {'title'} -> {'$t'};
		my $res_id = $entry -> {'gd$resourceId'} -> {'$t'};

		push @docs, {title => $title, res_id => $res_id} if $title =~ m/$grep/;
	}

	return \@docs;
}

=head2 auth( )

Returns a token for the Google ClientLogin based authentication.

=cut

sub auth {
	my $self = shift;

	my $email    = $self -> app -> global_options -> {'email'};
	my $password = $self -> app -> global_options -> {'pwd'};

	$self -> usage_error('Err: set a valid email address.') unless $email;

	unless ($password) {
		print STDERR "Enter password for '".$email."': ";
		system('stty','-echo') if $^O eq 'linux';

		chop($password = <STDIN>);

		system('stty','echo') if $^O eq 'linux';
		print "\n";
	}

	my $auth = WWW::Google::Auth::ClientLogin -> new(
		email		=> $email,
		password	=> $password,
		service		=> 'writely',
		sources		=> __PACKAGE__.$App::Google::Docs::VERSION,
		type		=> 'HOSTED_OR_GOOGLE'
	);

	my $tokens = $auth -> authenticate;

	if ($tokens -> {'status'} != 0) {
		die "Err: authentication failed (".$auth -> {'error'}.")\n";
	}

	return $tokens -> {'auth_token'};
}

=head2 do_request( $request )

Make an HTTP request.

=cut

sub do_request {
	my ($self, $request, $auth) = @_;

	my $ua = LWP::UserAgent -> new;

	$request -> authorization('GoogleLogin auth='.$auth);
	$request -> header('GData-Version' => '2.0');

	my $response = $ua -> request($request) -> as_string;

	my $status = (split / /,(split /\n/, $response)[0])[1];
	my $body   = (split /\n\n/, $response)[1];

	chomp $body if $body;

	my $out = {'status' => $status, 'body' => $body};

	return $out;
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

1; # End of App::Google::Docs::Command