package Sys::Info::Constants;
use strict;
use warnings;
use vars qw( $VERSION @EXPORT_OK %EXPORT_TAGS );
use Carp qw( croak );
use base qw( Exporter );

$VERSION = '0.73';

BEGIN {
    if ( ! defined &OSID ) {
        my %OS = (
            MSWin32  => 'Windows',
            MSWin64  => 'Windows',
            linux    => 'Linux',
            #darwin   => 'MacOSX',
        );
        $OS{$_} = 'BSD' for qw( freebsd openbsd netbsd );
        my $ID = $OS{ $^O } || 'Unknown';
        *OSID = sub () { "$ID" }
    }
}

use constant DCPU_LOAD_LAST_01    => 0;
use constant DCPU_LOAD_LAST_05    => 1;
use constant DCPU_LOAD_LAST_10    => 2;
use constant DCPU_LOAD            => (0..2);

use constant WIN_REG_HW_KEY       => 'HKEY_LOCAL_MACHINE/HARDWARE/';
use constant WIN_REG_CPU_KEY      => WIN_REG_HW_KEY
                                   . q{DESCRIPTION/System/CentralProcessor};
use constant WIN_REG_CDKEY        => q{HKEY_LOCAL_MACHINE/Software/Microsoft/}
                                   . q{Windows NT/CurrentVersion//DigitalProductId};
use constant WIN_REG_OCDKEY       => q{HKEY_LOCAL_MACHINE/Software/Microsoft/Office};
use constant WIN_WMI_DATE_TMPL    => 'A4 A2 A2 A2 A2 A2';
use constant WIN_B24_DIGITS       => qw( B C D F G H J K M P Q R T V W X Y 2 3 4 6 7 8 9 );
use constant WIN_USER_INFO_LEVEL  => 3;

use constant DATE_WEEKDAYS        => qw( Sun Mon Tue Wed Thu Fri Sat );
use constant DATE_MONTHS          => qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
use constant DATE_MKTIME_YDAY     =>  0;
use constant DATE_MKTIME_ISDST    => -1;

# uptime
use constant LIN_UP_TIME          => 0;
use constant LIN_IDLE_TIME        => 1;

# fstab entries
use constant LIN_FS_SPECIFIER     => 0;
use constant LIN_MOUNT_POINT      => 1;
use constant LIN_FS_TYPE          => 2;
use constant LIN_MOUNT_OPTS       => 3;
use constant LIN_DUMP_FREQ        => 4;
use constant LIN_FS_CHECK_ORDER   => 5;

# getpwnam()
use constant LIN_REAL_NAME_FIELD  => 6;
use constant LIN_RE_LINUX_VERSION => qr{
   \A
   Linux \s+ version \s
   (.+?)
   \s
   \( .+? \@ .+? \)
   (.*?)
   \z
}xmsi;

use constant UN_RE_BUILD    => qr{\A Build \s+ (\d+) .* \z}xmsio;

use constant NEW_PERL       => $] >= 5.008;

%EXPORT_TAGS = (
    device_cpu => [qw/
                    DCPU_LOAD_LAST_01
                    DCPU_LOAD_LAST_05
                    DCPU_LOAD_LAST_10
                    DCPU_LOAD
                  /],
    windows_reg => [qw/
                    WIN_REG_HW_KEY
                    WIN_REG_CPU_KEY
                    WIN_REG_CDKEY
                    WIN_REG_OCDKEY
                    /],
    windows_wmi => [qw/
                    WIN_WMI_DATE_TMPL
                    /],
    windows_etc => [qw/
                    WIN_B24_DIGITS
                    WIN_USER_INFO_LEVEL
                    /],
    date        => [qw/
                    DATE_WEEKDAYS
                    DATE_MONTHS
                    DATE_MKTIME_YDAY
                    DATE_MKTIME_ISDST
                    /],
    linux       => [qw/
                    LIN_UP_TIME
                    LIN_IDLE_TIME
                    LIN_FS_SPECIFIER
                    LIN_MOUNT_POINT
                    LIN_FS_TYPE
                    LIN_MOUNT_OPTS
                    LIN_DUMP_FREQ
                    LIN_FS_CHECK_ORDER
                    LIN_REAL_NAME_FIELD
                    LIN_RE_LINUX_VERSION
                    /],

    unknown     => [qw/
                    UN_RE_BUILD
                    /],

    general     => [qw/ OSID NEW_PERL /],
);

@EXPORT_OK        = map { @{ $_ } } values %EXPORT_TAGS;
$EXPORT_TAGS{all} = \@EXPORT_OK;

1;

__END__

=head1 NAME

Sys::Info::Constants - Constants for Sys::Info

=head1 SYNOPSIS

    use Sys::Info::Constants qw( :device_cpu );
    printf "CPU Load: %s\n", $cpu->load(DCPU_LOAD_LAST_01);

=head1 DESCRIPTION

This module defines all the constants used inside C<Sys::Info> and it's
subclasses.

=head1 CONSTANTS

Every constant can be imported individually or via import keys:

    Import Key      Constant
    ------------    -----------------
    :device_cpu     DCPU_LOAD_LAST_01
                    DCPU_LOAD_LAST_05
                    DCPU_LOAD_LAST_10
                    DCPU_LOAD

    :windows_reg    WIN_REG_HW_KEY
                    WIN_REG_CPU_KEY
                    WIN_REG_CDKEY
                    WIN_REG_OCDKEY

    :windows_wmi    WIN_WMI_DATE_TMPL

    :windows_etc    WIN_B24_DIGITS
                    WIN_USER_INFO_LEVEL

    :date           DATE_WEEKDAYS
                    DATE_MONTHS
                    DATE_MKTIME_YDAY
                    DATE_MKTIME_ISDST

    :linux          LIN_UP_TIME
                    LIN_IDLE_TIME
                    LIN_FS_SPECIFIER
                    LIN_MOUNT_POINT
                    LIN_FS_TYPE
                    LIN_MOUNT_OPTS
                    LIN_DUMP_FREQ
                    LIN_FS_CHECK_ORDER
                    LIN_REAL_NAME_FIELD
                    LIN_RE_LINUX_VERSION

    :general        OSID

=head2 OSID

The Operating System name used inside all C<Sys::Info> modules.

=head1 SEE ALSO

L<Sys::Info>.

=cut
