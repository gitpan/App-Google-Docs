
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Bring Google Documents to the command line',
  'AUTHOR' => 'Alessandro Ghedini <alexbio@cpan.org>',
  'BUILD_REQUIRES' => {
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'App-Google-Docs',
  'EXE_FILES' => [
    'bin/gdocs'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'App::Google::Docs',
  'PREREQ_PM' => {
    'App::Cmd::Setup' => '0',
    'Cwd' => '0',
    'File::Basename' => '0',
    'JSON' => '0',
    'LWP::MediaTypes' => '0',
    'LWP::UserAgent' => '0',
    'WWW::Google::Auth::ClientLogin' => '0'
  },
  'VERSION' => '0.08',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



