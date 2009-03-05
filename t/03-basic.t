#!/usr/bin/env perl -w
use strict;
use Test::More qw( no_plan );
use File::Spec;
use constant FILE => File::Spec->catfile( qw( t slurp.txt ) );

# Sys::Info::Device::CPU
# Sys::Info::Device
# Sys::Info::OS
#    ... can not be tested without a driver

# TODO: interface test for Sys::Info::Constants

use_ok('Sys::Info::Base');
use_ok('Sys::Info::Driver');

is( Sys::Info::Base->slurp(FILE), 'slurp', 'slurp() works' );
ok( Sys::Info::Base->load_module('CGI'), 'load_module() works');
ok( defined &CGI::new, 'CGI::new is defined' );
is( Sys::Info::Base->trim("  \n\n Foo \n \t \n "), 'Foo', 'trim() works');
ok( my @f = Sys::Info::Base->read_file(FILE), 'read_file() works' );
is( $f[0], 'slurp', 'read_file() works' );

is( Sys::Info::Base->date2time('1 Fri Jul 23 20:48:29 CDT 2004'), 1090604909,
        'date2time() works');

1;
