
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Perl client to the bloomd server",
  "dist_author" => [
    "Damien \"dams\" Krotkine"
  ],
  "dist_name" => "Bloomd-Client",
  "dist_version" => "0.23",
  "license" => "perl",
  "module_name" => "Bloomd::Client",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Config" => 0,
    "IO::Socket::INET" => 0,
    "List::MoreUtils" => 0,
    "Method::Signatures" => 0,
    "Moo" => 0,
    "perl" => "v5.10.0"
  },
  "script_files" => [],
  "test_requires" => {
    "Test::Exception" => 0,
    "Test::More" => 0,
    "Test::TCP" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
