use strict;
use vars qw(%PREREQ %RECOMMEND %BUILD_REQ);
use Module::Build;

do 'PREREQ' or die "Error including PREREQ: $@";

Module::Build->new(
   module_name    => 'Sys::Info::Base',
   license        => 'perl',
   requires       => \%PREREQ,
   recommends     => \%RECOMMEND,
   build_requires => \%BUILD_REQ,
   sign           => 0,
   dist_author    => 'Burak Gursoy <burak@cpan.org>',
)->create_build_script;
