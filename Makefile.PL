use strict;
use vars qw(%PREREQ);
use ExtUtils::MakeMaker;

do 'PREREQ' or die "Error including PREREQ: $!";

WriteMakefile(
   'NAME'         => 'Sys::Info::Base',
   'VERSION_FROM' => 'lib/Sys/Info.pm',
   'PREREQ_PM'    => \%PREREQ,
   ($] >= 5.005 ? (
   AUTHOR   => 'Burak Gursoy <burak@cpan.org>',
   ABSTRACT => 'Fetch information from the host system',
   ) : ()),
   PL_FILES => {},
);
