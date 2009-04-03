package Sys::Info::Device;
use strict;
use vars qw($VERSION);
use constant SUPPORTED => qw( CPU BIOS );
use Carp qw( croak );
use base qw( Sys::Info::Base );
use Sys::Info::Constants qw( OSID );

$VERSION = '0.69_10';

BEGIN {
    MK_ACCESSORS: {
        no strict qw(refs);
        foreach my $device ( SUPPORTED ) {
            *{ '_device_' . lc( $device ) } = sub {
                my $self = shift;
                return  Sys::Info::Base->load_module(
                            'Sys::Info::Device::' . $device
                        )->new(@_);
            }
        }
    }
}

sub new {
    my $class  = shift;
    my $device = shift || croak "Device ID is missing";
    my $self   = {};
    bless $self, $class;

    my $method = '_device_' . lc($device);
    croak "Bogus device ID: $device" if ! $self->can( $method );
    return $self->$method( @_ ? (@_) : () );
}

sub _device_available {
    my $self = shift;
    local $@;
    local $SIG{__DIE__};
    my @buf;

    foreach my $test ( SUPPORTED ) {
        eval { $self->new( $test ) };
        next if $@;
        push @buf, $test;
    }

    return @buf;
}

1;

__END__

=head1 NAME

Sys::Info::Device - Information about devices

=head1 SYNOPSIS

    use Sys::Info;
    my $info      = Sys::Info->new;
    my $device    = $info->device( $device_id );
    my @available = $info->device('available');

or

    use Sys::Info::Device;
    my $device    = Sys::Info::Device->new( $device_id );
    my @available = Sys::Info::Device->new('available');

=head1 DESCRIPTION

This is an interface to the available devices such as the C<CPU>.

=head1 METHODS

=head2 new DEVICE_ID

Returns an object to the related device or dies if C<DEVICE_ID> is
bogus or false.

If C<DEVICE_ID> has the value of C<available>, then the names of the
available devices will be returned.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006-2009 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.10.0 or, 
at your option, any later version of Perl 5 you may have available.

=cut
