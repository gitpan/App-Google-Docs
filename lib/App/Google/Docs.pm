package App::Google::Docs;
BEGIN {
  $App::Google::Docs::VERSION = '0.07';
}

use App::Cmd::Setup -app;

use warnings;
use strict;

BEGIN {
	autoflush STDOUT 1;
}

=head1 NAME

App::Google::Docs - Bring Google Documents to the command line

=head1 VERSION

version 0.07

=head1 SYNOPSIS

    use App::Google::Docs;

   App::Google::Docs -> run;

=head1 DESCRIPTION

This is the implementation of L<App::Google::Docs> with L<App::Cmd>.

=cut

sub global_opt_spec {
	my $email    = $ENV{GOOGLE_EMAIL} || $ENV{EMAIL};
	my $password = $ENV{GOOGLE_PASSWORD};

	return (
		[ "email=s", "set the login email",    { default => $email } ],
		[ "pwd=s",   "set the login password", { default => $password } ],
	);
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

1; # End of App::Google::Docs