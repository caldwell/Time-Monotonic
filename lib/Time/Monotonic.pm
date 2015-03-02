# Copyright © 2015 David Caldwell <david@porkrind.org>.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself, either Perl version 5.12.4 or,
# at your option, any later version of Perl 5 you may have available.

use strict; use warnings;
package Time::Monotonic;
use Exporter 'import';
our @EXPORT_OK = qw(monotonic_time);

our $VERSION = '0.0.0';

require XSLoader;
XSLoader::load('Time::Monotonic', $VERSION);

sub monotonic_time {
    Time::Monotonic::clock_get_dbl();
}

sub backend {
    Time::Monotonic::monotonic_clock_name();
}

sub is_monotonic {
    Time::Monotonic::monotonic_clock_is_monotonic();
}

1;
__END__

=head1 NAME
Time::Monotonic - Incrementing clock source

=head1 SYNOPSIS

  use Time::Monotonic qw(monotonic_time);
  $t1 = monotonic_time();
  sleep(1);
  $t2 = monotonic_time();

  die unless Time::Monotonic::is_monotonic();
  say "Backend API: ".Time::Monotonic::backend();

=head1 DESCRIPTION

Time::Monotonic gives access to monotonic clocks on various platforms (Mac
OS X, Windows, and POSIX). A monotonic clock is a time source that won't
ever jump forward or backward (due to NTP or Daylight Savings Time updates).

Time::Monotonic uses Thomas Habets's cross platform "monotonic_clock"
library under the hood.

=head1 API

=over 4

=item C<monotonic_time()>

This function returns a monotonic time as a floating point number
(fractional seconds). Note that this time will not be comparable to times
from the built-in C<time> function. The only real use of the value is
comparing against other values returned from C<monotonic_time()>.

=item C<backend()>

This function returns which backend clock functions are in use. It will be
one of:

=over

=item C<'clock_gettime'> (POSIX)

=item C<'mach_absolute_time'> (Mac OS X)

=item C<'QueryPerformanceCounter'> (win32)

=item C<'generic'> (none of the above)

=back


=item C<is_monotonic()>

This will return true if the backend supports monotonic clocks. This I<can>
return false if there is no support for monotonic clocks in the current
Platform/OS/hardware combo.

=back

=head1 SEE ALSO

L<Source Code Repository|https://github.com/caldwell/Time-Monotonic>

L<Why are monotonic clocks important?|https://blog.habets.se/2010/09/gettimeofday-should-never-be-used-to-measure-time>

L<monotonic_clock library|https://github.com/ThomasHabets/monotonic_clock>

=head1 AUTHOR

David Caldwell E<lt>david@porkrind.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by David Caldwell

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
