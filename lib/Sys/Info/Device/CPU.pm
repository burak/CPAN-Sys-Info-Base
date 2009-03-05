package Sys::Info::Device::CPU;
use strict;
use subs qw(hyper_threading ht);
use vars qw( $VERSION @ISA   );
use base qw( Sys::Info::Base );
use Sys::Info::Constants qw( OSID );
use Carp qw( croak );

$VERSION = '0.60';

BEGIN {
    push @ISA, __PACKAGE__->load_subclass('Sys::Info::Driver::%s::Device::CPU');
    *ht = \&hyper_threading;
}

sub new {
    my $class = shift;
    my %opt   = scalar(@_) % 2 ? () : (@_);
    my $self  = {
        %opt,
        CACHE => undef,
    };
    bless $self, $class;
    $self;
}

sub count {
    my $self = shift;
    $self->identify if not $self->{CACHE};
    my @cpu = @{ $self->{CACHE} };
    return @cpu ? scalar @cpu : undef;
}

sub hyper_threading {
    my $self = shift;
    $self->identify if not $self->{CACHE};
    my %test;
    my $logical = 0;

    foreach my $cpu ( @{ $self->{CACHE} } ) {
        $logical++;
        my $noc = $cpu->{number_of_cores};
        my $nol = $cpu->{number_of_logical_processors};
        if ( defined $noc && defined $nol ) {
            # ht? then return the number of threads
            return $nol if $noc != $nol;
        }
        next if not exists $cpu->{socket_designation};
        $test{ $cpu->{socket_designation} }++;
    }

    return 0 if $logical < 1;  # failed to fill cache
    my $physical = keys %test;
    return 0 if $physical < 1; # an error occurred somehow
    return $logical > $physical ? 1 : 0;
}

sub speed {
    my $self = shift;
    $self->identify if not $self->{CACHE};
    my @cpu = @{ $self->{CACHE} };
    return if !@cpu || !ref($cpu[0]);
    return $cpu[0]->{speed};
}

sub load {
    my $self   = shift;
    my $level  = int +(shift || 0) + 0;
    croak "Illegal cpu_load level: $level" if $level > 2 || $level < 0;
    return $self->SUPER::load( $level );
}

# ------------------------[ P R I V A T E ]------------------------ #

sub _serve_from_cache {
    my $self    = shift;
    my $context = shift;
    croak "Can not happen: cache is not set" if not $self->{CACHE};
    return if not defined $context; # void context
    if ( not $context ) { # scalar context
        # OK for single processor ("name" will be same)
        my $count = $self->count;
        $count = undef if $count && $count == 1; # "1 x CPU" is meaningless
        my $name  = $self->{CACHE}[0] ? $self->{CACHE}[0]{name} : '';
        return $name if not $count;
        return "$count x $name";
    }
    return @{ $self->{CACHE} };
}

1;

__END__

=head1 NAME

Sys::Info::Device::CPU - CPU information.

=head1 SYNOPSIS

   use Sys::Info;
   use Sys::Info::Constants qw( :device_cpu );
   my $info = Sys::Info->new;
   my $cpu  = $info->device( CPU => %options );

Example:

   printf "CPU: %s\n", scalar($cpu->identify)  || 'N/A';
   printf "CPU speed is %s MHz\n", $cpu->speed || 'N/A';
   printf "There are %d CPUs\n"  , $cpu->count || 1;
   printf "CPU load: %s\n"       , $cpu->load  || 0;

=head1 DESCRIPTION

Collects and returns information about the Central Processing Unit
(CPU) on the host machine.

Some platforms can limit the available information under some
user accounts and this will affect the accessible amount of
data. When this happens, some methods will not return
anything usable.

=head1 METHODS

=head2 new

Acceps parameters in C<< key => value >> format.

=head3 cache

If has a true value, internal cache will be enabled.
Cache timeout can be controlled via C<cache_timeout>
parameter.

On some platforms, some methods can take a long time
to be completed (i.e.: WMI access on Windows platform).
If cache is enabled, all gathered data will be saved
in an internal in-memory cache and, the related method will
serve from cache until the cache expires.

Cache only has a meaning, if you call the related method
continiously (in a loop, under persistent environments
like GUI, mod_perl, PerlEx, etc.). It will not have any
effect if you are calling it only once.

=head3 cache_timeout

Must be used together with C<cache> parameter. If cache
is enabled, and this is not set, it will take the default
value: C<10>.

Timeout value is in seconds.

=head2 identify

If called in a list context; returns an AoH filled with
CPU metadata. If called in a scalar context, returns the
name of the CPU (if CPU is multi-core or there are multiple CPUs,
it'll also include the number of CPUs).

Returns C<undef> upon failure.

=head2 speed

Returns the CPU clock speed in MHz if successful.
Returns C<undef> otherwise.

=head2 count

Returns the number of CPUs (or number of total cores).

=head2 load [, LEVEL]

Returns the CPU load percentage if successful.
Returns C<undef> otherwise.

The average CPU load average in the last minute. If you pass a 
level argument, it'll return the related CPU load.

    use Sys::Info::Constants qw( :device_cpu );
    printf "CPU Load: %s\n", $cpu->load(DCPU_LOAD_LAST_01);

Load level constants:

    LEVEL               MEANING
    -----------------   -------------------------------
    DCPU_LOAD_LAST_01   CPU Load in the last  1 minute
    DCPU_LOAD_LAST_05   CPU Load in the last  5 minutes
    DCPU_LOAD_LAST_10   CPU Load in the last 10 minutes

C<LEVEL> defaults to C<DCPU_LOAD_LAST_01>.

Using this method under I<Windows> is not recommended since,
the C<WMI> interface will possibly take at least C<2> seconds
to complete the request.

=head2 hyper_threading

=head2 ht

Returns the number of threads if hyper threading is supported, returns false
otherwise.

=head1 SEE ALSO

L<Sys::Info>, L<Sys::Info::OS>.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006-2009 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.8.8 or, 
at your option, any later version of Perl 5 you may have available.

=cut
