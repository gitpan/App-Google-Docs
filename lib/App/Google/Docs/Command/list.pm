package App::Google::Docs::Command::list;
BEGIN {
  $App::Google::Docs::Command::list::VERSION = '0.08';
}

use App::Google::Docs -command;

use warnings;
use strict;

=head1 NAME

App::Google::Docs::Command::list - List your docs

=head1 VERSION

version 0.08

=head1 SYNOPSIS

    $ gdocs list [ NAME ]

This will list every documents on the Google account, optionally filtering their
names by C<NAME>.

=cut

sub abstract { 'list your docs' }

sub usage_desc {
	return '%c list %o [ name ]';
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $auth = $self -> auth;
	my $docs = $self -> get_docs(shift @$args, $auth);

	foreach (@$docs) {
		print $_ -> {'title'}, "\n";
	}
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

1; # End of App::Google::Docs::Command::list