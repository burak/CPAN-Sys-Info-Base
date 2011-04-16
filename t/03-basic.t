#!/usr/bin/env perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use File::Spec;
use constant FILE => File::Spec->catfile( qw( t slurp.txt ) );

use Sys::Info::Constants qw( OSID );

BEGIN {
    my @fakes =
        map { sprintf $_, OSID() }
        qw(
            Sys::Info::Driver::%s::Device::CPU
            Sys::Info::Driver::%s::OS
        );
    foreach my $class ( @fakes ) {
        (my $file = $class) =~ s{::}{/}xmsg;
        $file .= q(.pm);
        $INC{ $file } = $class;
    }
}

# Sys::Info::Device::CPU
# Sys::Info::Device
# Sys::Info::OS
#    ... can not be tested without a driver

# TODO: interface test for Sys::Info::Constants

use Sys::Info::Base;
use Sys::Info::Driver;

is( Sys::Info::Base->slurp(FILE), 'slurp', 'slurp() works' );
ok( Sys::Info::Base->load_module('CGI'), 'load_module() works');
ok( defined &CGI::new, 'CGI::new is defined' );
is( Sys::Info::Base->trim("  \n\n Foo \n \t \n "), 'Foo', 'trim() works');
ok( my @f = Sys::Info::Base->read_file(FILE), 'read_file() works' );
is( $f[0], 'slurp', 'read_file() works' );

ok( my $t = Sys::Info::Base->date2time('1 Fri Jul 23 20:48:29 CDT 2004'),
    'date2time() works');

like( scalar( localtime $t ), qr{Jul .+? 2004}xms, 'Got an approximate date' );

1;
