package Sys::Info::Base;
use strict;
use vars qw( $VERSION );
use IO::File;
use Carp qw( croak );
use File::Spec;
use Sys::Info::Constants qw( :date OSID );

$VERSION = '0.69_11';

my %LOAD_MODULE; # cache

sub load_subclass { # hybrid: static+dynamic
    my $self     = shift;
    my $template = shift || croak "Template missing for load_subclass()";
    my $class;

    eval { $class = $self->load_module( sprintf $template, OSID ); };

    if ( $@ ) {
        warn sprintf( "Operating system identified as: '%s'. %s. "
                     ."Falling back to compatibility mode", OSID, $@ );
        $class = $self->load_module( sprintf $template, 'Unknown' );
    }

    return $class;
}

sub load_module {
    my $self  = shift;
    my $class = shift || croak "Which class to load?";
    croak "Invalid class name: $class" if ref $class;
    return $class if $LOAD_MODULE{ $class };
    (my $check = $class) =~ tr/a-zA-Z0-9_://d;
    croak "Invalid class name: $class" if $check;
    my @raw_file = split /::/, $class;
    return $class if exists $INC{ join('/', @raw_file).".pm" };
    my $file = File::Spec->catfile( @raw_file ) . '.pm';
    (my $inc_file = $file) =~ tr///;
    eval { require $file; };
    croak "Error loading $class: $@" if $@;
    $LOAD_MODULE{ $class } = 1;
    return $class;
}

sub trim {
    my $self = shift;
    my $str  = shift;
    return if not defined $str;
    return $str if not $str;
    $str =~ s{ \A \s+    }{}xms;
    $str =~ s{    \s+ \z }{}xms;
    $str;
}

sub slurp { # fetches all data inside a flat file
    my $self   = shift;
    my $file   = shift;
    my $msgerr = shift || 'I can not open file %s for reading: ';
    my $FH     = IO::File->new;
       $FH->open($file) or croak sprintf($msgerr, $file) . $!;
    my $slurped;
    SLURP_SCOPE: {
       local $/;
       chomp($slurped = <$FH>);
    }
    close  $FH;
    return $slurped;
}

sub read_file {
    my $self   = shift;
    my $file   = shift;
    my $msgerr = shift || 'I can not open file %s for reading: ';
    my $FH     = IO::File->new;
       $FH->open($file) or die sprintf($msgerr, $file) . $!;
    my @flat   = <$FH>;
    close  $FH;
    return @flat;
}

sub date2time { # date stamp to unix time stamp conversion
    my $self   = shift;
    my $stamp  = shift || die "No date input specified!";
    my($i, $j) = (0,0); # index counters
    my %wdays  = map { $_ => $i++ } DATE_WEEKDAYS;
    my %months = map { $_ => $j++ } DATE_MONTHS;
    my @junk   = split /\s+/, $stamp;
    my $reg    = join    '|', keys %wdays;

    # remove until ve get a day name
    while ( @junk && $junk[0] !~ m{ \A ($reg) \z }xmsi ) {
       shift @junk;
    }
    return '' if ! @junk;

    my($wday, $month, $mday, $time, $zone, $year) = @junk;
    my($hour, $min, $sec)                         = split /\:/, $time;

    require POSIX;
    my $unix =  POSIX::mktime(
                    $sec,
                    $min,
                    $hour,
                    $mday,
                    $months{$month},
                    $year - 1900,
                    $wdays{$wday},
                    DATE_MKTIME_YDAY,
                    DATE_MKTIME_ISDST,
                );

    return $unix;
}

1;

__END__


=head1 NAME

Sys::Info::Base - Base class for Sys::Info

=head1 SYNOPSIS

    use base qw(Sys::Info::Base);
    #...
    sub foo {
        my $self = shift;
        my $data = $self->slurp("/foo/bar.txt");
    }

=head1 DESCRIPTION

Includes some common methods.

=head1 METHODS

=head2 load_module CLASS

Loads the module named with C<CLASS>.

=head2 load_subclass TEMPLATE

Loads the specified class via C<TEMPLATE>:

    my $class = __PACKAGE__->load_subclass('Sys::Info::Driver::%s::OS');

C<%s> will be replaced with C<OSID>. Apart from the template usage, it is
the same as C<load_module>.

=head2 trim STRING

Returns the trimmed version of C<STRING>.

=head2 slurp FILE

Caches all contents of C<FILE> into a scalar and then returns it.

=head2 read_file FILE

Caches all contents of C<FILE> into an array and then returns it.

=head2 date2time DATE_STRING

Converts C<DATE_STRING> into unix timestamp.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006-2009 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.10.0 or, 
at your option, any later version of Perl 5 you may have available.

=cut
