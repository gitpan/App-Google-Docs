#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Google::Docs' ) || print "Bail out!
";
}

diag( "Testing App::Google::Docs $App::Google::Docs::VERSION, Perl $], $^X" );
