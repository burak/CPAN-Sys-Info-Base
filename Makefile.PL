#!/usr/bin/perl
use strict;
use vars qw(%PREREQ %RECOMMEND %BUILD_REQ);
use ExtUtils::MakeMaker;

do 'PREREQ' or die "Error including PREREQ: $!";

WriteMakefile(
   'NAME'         => 'Sys::Info::Base',
   'VERSION_FROM' => 'lib/Sys/Info/Base.pm',
   'PREREQ_PM'    => { %PREREQ, %RECOMMEND, %BUILD_REQ },
   ($] >= 5.005 ? (
   AUTHOR   => 'Burak Gursoy <burak@cpan.org>',
   ABSTRACT => 'Base classes for Sys::Info',
   ) : ()),
   PL_FILES => {},
);
