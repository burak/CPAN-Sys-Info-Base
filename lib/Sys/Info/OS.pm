package Sys::Info::OS;
use strict;
use vars qw( $VERSION @ISA   );
use base qw( Sys::Info::Base );
use Sys::Info::Constants qw( OSID );
use Carp qw( croak );

$VERSION = '0.69_10';

BEGIN {
    my $class = __PACKAGE__->load_subclass('Sys::Info::Driver::%s::OS');
    push @ISA, $class;

    CREATE_SYNONYMS_AND_UTILITY_METHODS: {
        no strict qw(refs);
        *is_admin   = *is_admin_user
                    = *is_adminuser
                    = *is_root_user
                    = *is_rootuser
                    = *is_super_user
                    = *is_superuser
                    = *is_su
                    = *{ $class.'::is_root' }
                    ;
        *is_win32   = *is_windows
                    = *is_win
                    = sub () { OSID eq 'Windows' }
                    ;
        *is_linux   = *is_lin
                    = sub () { OSID eq 'Linux'   }
                    ;
        *is_bsd     = sub () { OSID eq 'BSD'     };
        *is_unknown = sub () { OSID eq 'Unknown' };
        *workgroup  = *{ $class . '::domain_name' };
        *host_name  = *{ $class . '::node_name'   };
        *time_zone  = *{ $class . '::tz'          };
    }

    CREATE_FAKES: {
        # driver specific methods
        my @fakes = qw(
            is_winnt
            is_win95
            is_win9x
            product_type
            cdkey
        );

        no strict qw(refs);
        foreach my $meth ( @fakes ) {
            next if __PACKAGE__->can( $meth );
            *{ $meth } = sub {};
        }
    }

}

sub new {
    my $class = shift;
    my $self  = {
        scalar(@_) % 2 ? () : (@_), # options to new()
    };
    bless  $self, $class;
    $self->init if $self->can('init');
    return $self;
}

sub meta {
    my $self = shift;
    my $id   = shift;
    my %info = $self->SUPER::meta( $id );

    return %info if ! $id;

    my $lcid = lc $id;
    croak "$id meta value is not supported" if ! exists $info{ $lcid };

    return $info{ $lcid };
}

sub ip {
    my $self = shift;
    require Socket;
    require Sys::Hostname;
    my $host = gethostbyname Sys::Hostname::hostname() || return;
    my $ip   = Socket::inet_ntoa($host);
    if($ip && $ip =~ m{\A 127}xms) {
        if($self->SUPER::can('_ip')) {
            $ip = $self->SUPER::_ip();
        }
    }
    return $ip;
}

1;

__END__

=head1 NAME

Sys::Info::OS - Detailed os information.

=head1 SYNOPSIS

   use Sys::Info;
   my $info = Sys::Info->new;
   my $os   = $info->os(%options);

or

   use Sys::Info::OS;
   my $os = Sys::Info::OS->new(%options);

Example:

   use Data::Dumper;
   
   warn "Collected information can be incomplete\n" if $os->is_unknown;
   
   my %fs = $os->fs;
   print Data::Dumper->Dump([\%fs], ['*FILE_SYSTEM']);
   
   print  "B1ll G4teZ rull4z!\n" if $os->is_windows;
   print  "Pinguin detected!\n"  if $os->is_linux;
   if($os->is_windows) {
      printf "This is a %s based system\n", $os->is_winnt ? 'NT' : '9.x';
   }
   printf "Operating System: %s\n", $os->name( long => 1 );
   
   my $user = $os->login_name_real || $os->login_name || 'User';
   print "$user, You've Got The P.O.W.E.R.!\n" if $os->is_root;
   
   if(my $up = $os->uptime) {
      my $tick = $os->tick_count;
      printf "Running since %s\n"   , scalar localtime $up;
      printf "Uptime: %.2f hours\n" , $tick / (60*60      ); # probably windows
      printf "Uptime: %.2f days\n"  , $tick / (60*60*24   ); # might be windows
      printf "Uptime: %.2f months\n", $tick / (60*60*24*30); # hmm... smells like tux
   }

=head1 DESCRIPTION

Supplies detailed operating system information.

=head1 METHODS

=head2 new

Object constructor.

=head2 name

Returns the OS name. Supports these named parameters: C<edition>, C<long>:

   # also include the edition info if present
   $os->name( edition => 1 );

This will return the long OS name (with build number, etc.):

   # also include the edition info if present
   $os->name( long => 1, edition => 1 );

=head2 version

Returns the OS version.

=head2 build

Returns the OS build number or build date, depending on
the system.

=head2 uptime

Returns the uptime as a unix timestamp.

=head2 tick_count

Returns the uptime in seconds since the machine booted.

=head2 node_name

Machine name

=head2 domain_name

Returns the network domain name.

Synonyms:

=over 4

=item workgroup

=back

=head2 login_name

Returns the name of the effective user. Supports parameters in
C<< name => value >> format. Accepted parameters: C<real>:

    my $user = $os->login_name( real => 1 ) || $os->login_name;

=head2 ip

Returns the IP number.

=head2 fs

Returns an info hash about the filesystem. The contents of the hash can
vary among different systems.

=head2 host_name



=head2 time_zone



=head2 product_type

=head2 bitness

If successful, returns the bitness ( C<32> or C<64> ) of the OS. Returns
false otherwise.

=head2 meta

Returns a hash containing various informations about the OS.

=head2 cdkey



=head1 UTILITY METHODS

These are some useful utility methods.

=head2 is_windows

Returns true if the os is windows.
Synonyms:

=over 4

=item is_win32

=item is_win

=back

=head2 is_winnt

Returns true if the OS is a NT based system (NT/2000/XP/2003).

Always returns false if you are not under windows or you are
not under a NT based system.

=head2 is_win95

Returns true if the OS is a 9x based system (95/98/Me).

Always returns false if you are not under Windows or
Windows9x.

Synonyms:

=over 4

=item is_win9x

=back

=head2 is_linux

Returns true if the os is linux.
Synonyms:

=over 4

=item is_lin

=back

=head2 is_bsd

Returns true if the os is (free|open|net)bsd.

=head2 is_unknown

Returns true if this module does not support the OS directly.

=head2 is_root

Returns true if the current user has admin rights.
Synonyms:

=over 4

=item is_admin

=item is_admin_user

=item is_adminuser

=item is_root_user

=item is_rootuser

=item is_super_user

=item is_superuser

=item is_su

=back

=head1 CAVEATS

=over 4

=item *

I don't have any access to any other os, so this module
(currently) only supports Windows & Linux. Windows support is better.

=item *

Win32::IsAdminUser() implemented in 5.8.4 (However, it is possible to
manually upgrade the C<Win32> module). If your ActivePerl
is older than this, C<is_admin> method will always returns false.
(There I<may> be a workaround for that).

=item *

Contents of the filesystem hash may change in further releases.

=item *

Filesystem [Windows]

File system information can not be extracted under restricted
environments. If this is the case, we'll get an
I<access is denied> error.

=back

=head1 SEE ALSO

L<Win32>, L<POSIX>, 
L<Sys::Info>,
L<http://msdn.microsoft.com/library/en-us/sysinfo/base/osversioninfoex_str.asp>.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006-2009 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.10.0 or, 
at your option, any later version of Perl 5 you may have available.

=cut




use Socket;
sub network_name {
   my $self  = shift;
   my $ip    = shift;
   my $iaddr = inet_aton($ip);
   my $name  = gethostbyaddr($iaddr, AF_INET);
   return $name || $ip;
}




#<TODO>
sub disk_quota {}
#</TODO>
