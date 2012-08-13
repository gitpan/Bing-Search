
use strict;
use warnings;



use ExtUtils::MakeMaker 0.010;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Parser of Bing Search Engine search results",
  "AUTHOR" => "Dmitry Vinogradenko <jin\@hungosh.net>",
  "BUILD_REQUIRES" => {
  "Test::Most" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Bing-Search",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Bing::Search",
  "PREREQ_PM" => {
    "LWP::UserAgent" => 0
  },
  "VERSION" => "0.010",
);


unless ( eval { ExtUtils::MakeMaker->VERSION(0.010) } ) {
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
  unless eval { ExtUtils::MakeMaker->VERSION(6.30) };

WriteMakefile(%WriteMakefileArgs);
