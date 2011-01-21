
use strict;
use warnings;

BEGIN { require 5.001; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A Perl module to deal with time periods.',
  'AUTHOR' => 'Patrick Ryan, Paul Boyd <pboyd@dev3l.net>',
  'BUILD_REQUIRES' => {
    'POSIX' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Time-Period',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Time::Period',
  'PREREQ_PM' => {
    'Exporter' => '0'
  },
  'VERSION' => '1.22',
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



