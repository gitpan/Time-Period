package Time::Period;

use 5.006;
use strict;
use warnings;

use Time::Local;
use Carp;

our $VERSION = '0.01';

use overload q("") => '_to_string',
  '+' => 'add',
  '-' => 'subtract';

my @known = qw(y m w d H M S);
my @canon = qw(y m S);

my %conv  = (y => [1, 'y'],
	     m => [1, 'm'],
	     w => [7 * 24 * 60 * 60, 'S'],
	     d => [24 * 60 * 60, 'S'],
	     H => [60 * 60, 'S'],
	     M => [60, 'S'],
	     S => [1, 'S']);

my $known = join '', @known;
my $segment = qr/(\d+)([$known])/;

my %_const_handlers = 
  (q => sub { return __PACKAGE__->new($_[0]) || $_[1] });

sub import {
  overload::constant %_const_handlers;
}

sub unimport {
  overload::remove_constant(q => undef);
}

sub new {
  my $class = shift;

  my $str = shift;

  return unless $str =~/^$segment(\s+$segment)*$/;

  my @vals = $str =~ /$segment/g;

  return unless @vals;

  return if @vals % 2;

  my %vals = reverse @vals;

  my $self = {};
  $self->{$_} = 0 for @canon;

  foreach (@known) {
    next unless $vals{$_};
    $self->{$conv{$_}[1]} += $vals{$_} * $conv{$_}[0];
  }

  return bless $self, $class;
}

sub _to_string {
  my $self = shift;

  my %tmp = %$self;
  my %vals;

  foreach (@known) {
    $vals{$_} += int ($tmp{$conv{$_}[1]} / $conv{$_}[0]);
    $tmp{$conv{$_}[1]} %= $conv{$_}[0];
  }

  return join ', ', map { "$vals{$_}$_" } grep { $vals{$_} } @known;
}

sub add {
  my ($l, $r, $rev) = @_;

  if (ref $r) {
    if (UNIVERSAL::isa($r, __PACKAGE__)) {
      my %new;
      foreach (@canon) {
	$new{$_} = $l->{$_} + $r->{$_};
      }
      return (ref $l)->new(join ' ', map { "$new{$_}$_" } @canon);
    } else {
      croak "Can't add a ", ref $r, " to a ", __PACKAGE__;
    }
  } else {
    my @r = localtime($r);
    $r[5] += $l->{y};
    $r[4] += $l->{m};
    if ($r[4] > 11) {
      $r[4] -= 12;
      $r[5]++;
    }

    if ($r[3] > (_is_leap($r[5]+1900) ? 29 : 28)) {
      $r[3] = _is_leap($r[5]+1900) ? 29 : 28;
    }

    $r = timelocal(@r[0 .. 5]);
    return $r + $l->{S};
  }
}

sub subtract {
  my ($l, $r, $rev) = @_;

  if (ref $r) {
    if (UNIVERSAL::isa($r, __PACKAGE__)) {
      my %new;
      foreach (@canon) {
	$new{$_} = $rev ? $r->{$_} - $l->{$_} : $l->{$_} + $r->{$_};
      }
      return (ref $l)->new(join ' ', map { "$new{$_}$_" } @canon);
    } else {
      croak "Can't add a ", ref $r, " to a ", __PACKAGE__;
    }
  } else {
    croak "Can't subtract a number from a ", ref $l unless $rev;

    my @r = localtime($r);
    $r[5] -= $l->{y};
    $r[4] -= $l->{m};
    if ($r[4] < 0) {
      $r[4] += 12;
      $r[5]--;
    }

    if ($r[3] > (_is_leap($r[5]+1900) ? 29 : 28)) {
      $r[3] = _is_leap($r[5]+1900) ? 29 : 28;
    }

    $r = timelocal(@r[0 .. 5]);
    return $r - $l->{S};
  }
}

sub _is_leap {
  my $y = shift;
  return 1 unless $y % 400;
  return unless $y % 100;
  return 1 unless $y % 4;
  return;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Time::Period - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Time::Period;

  my $day = Time::Period->new('24H');
  print $day; # prints 1d
  print scalar localtime time + $day; # prints time one day in the future

or

  use Time::Period ':constants';

  my $day = '24H';
  print $day;

  print scalar localtime time + '1y';

  print scalar localtime time + '1y' + '1m';

=head1 ABSTRACT

Time::Period allows you to put constants in your code that represent periods
of time.

=head1 DESCRIPTION

Time::Period modules periods of time and allows you to work with them in
your Perl program. There are two ways to use it. Firstly ou can simply C<use>
the module as you would most other Perl modules.

  use Time::Period;

You can then create Time::Period objects by using the C<new> method.

  my $day = Time::Period->new('24H');

C<$day> now contains an object which represents 24 hours. You can print
the object out.

  print $day;

This will display C<1d> (as 24 hours is one day). Note that the display
is normalised (24 hours becomes 1 day).

The C<new> method takes one argument which is a string. The string must
be made up of segments where each segment is an integer followed by one
of the letters y, m, w, d, H, M, S. The segments are separated by one or
more space characters. The letters represent years, months, weeks, days,
hours, minutes and seconds. Notice that because "month" and "minute" both
begin with 'm', I have taken the arbitrary decision that 'm' is for
"month" and 'M' is for "minute". To impose some kind of consistancy, I<all>
units of time smaller than a day are signified by an upper case letter.

These are therefore all valid calls to C<new>.

  my $fortnight    = Time::Period->new('2w');
  my $soccer_game  = Time::Period->new('90M');
  my $spell_length = Time::Period->new('1y 1d');

You can add two (or more) Time::Period object to get a longer period.

  my $week = Time::Period->new('1w');
  my $day  = Time::Period->new('1d');
  my $a_week_and_a day = $week + $day;

If you add a plain number to a Time::Period object, then it is assumed
that the number is a date and time expressed in seconds since the epoch.
This means that it is easy to get the date (say) one month in the future
with code like:

  my $month = Time::Period->new('1m');
  my $then = time + $month;
  print scalar localtime $then;

The other, slightly more interesting way, to use Time::Period is to allow
it to grab all likely looking constants in your Perl code and convert
them automatically to Time::Period objects. To do this, pass the module
the string C<:constants> when you C<use> it.

  use Time::Period ':constants';

Having done this, all string constants in your program that could be valid 
as parameters to C<Time::Period->new> will be autoamtically changed into
Time::Period objects. That means that you can simply the earlier examples
to:

  my $day = '24H';

  my $fortnight    = '2w';
  my $soccer_game  = '90M';
  my $spell_length = '1y 1d';

and everything will work exactly the same way as it did.

=head2 CAVEATS

=over 4

=item *

This is a work in progress. There are almost certainly huge numbers of
bugs lurking within.

=item *

The date and time support within the module is based on the standard Perl
date and time support. This means that dealing with dates before the
"epoch" on your system (usually 1970-01-01) might return strange results.

=back

=head2 TO DO

Loads of stuff...

=over 4

=item *

More overloaded operators.

=item *

More (better!) documentation

=item *

More tests

=back

=head2 EXPORT

None


=head1 SEE ALSO

L<Time::Piece>, various other time and date modules.

=head1 AUTHOR

Dave Cross, E<lt>dave@dave.org.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Dave Cross

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
