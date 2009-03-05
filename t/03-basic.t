#!/usr/bin/env perl -w
use strict;
use Test::More qw( no_plan );
use File::Spec;
use constant FILE => File::Spec->catfile( qw( t slurp.txt ) );
use Cwd;

print STDERR "EEEEEEEEE:" . cwd . "\n";

# Sys::Info::Device::CPU can not be tested without a driver

use_ok('Sys::Info::Base');

ok( Sys::Info::Base->slurp(FILE) eq 'slurp', 'slurp() works' );
ok( Sys::Info::Base->load_module('CGI'), 'load_module() works');
ok( defined &CGI::new, 'CGI::new is defined' );
ok( Sys::Info::Base->trim("  \n\n Foo \n \t \n ") eq 'Foo', 'trim() works');
ok( my @f = Sys::Info::Base->read_file(FILE), 'read_file() works' );
ok( $f[0] eq 'slurp', 'read_file() works' );

is( Sys::Info::Base->date2time('1 Fri Jul 23 20:48:29 CDT 2004'), , 'date2time() works');

    #$build_date = "1 Fri Jul 23 20:48:29 CDT 2004';";
    #$build_date = "1 SMP Mon Aug 16 09:25:06 EDT 2004";

ok(1);

1;
