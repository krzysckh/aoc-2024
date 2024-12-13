use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use List::Util qw(min max);
use POSIX qw(ceil floor);
use Class::Struct;
use autobox;

sub SCALAR::integerp { $_[0] =~ /^\d+$/ }

struct Pt => {
  x => '$',
  y => '$',
};

struct Machine => {
  A     => 'Pt',
  B     => 'Pt',
  prize => 'Pt'
};

my @machs;
our $amnt = 10000000000000;

for (split '\n\n', read_file 'input') {
  @_ = split '\n';
  $_[0] =~ /Button .: X\+(\d+), Y\+(\d+)/;
  $a = Pt->new(x => $1, y => $2);
  $_[1] =~ /Button .: X\+(\d+), Y\+(\d+)/;
  $b = Pt->new(x => $1, y => $2);
  $_[2] =~ /Prize: X=(\d+), Y=(\d+)/;
  push @machs, Machine->new(A => $a, B => $b, prize => Pt->new(x => $1, y => $2));
}

sub calc {
  my (@bs) = @_;
  my $sum = 0;
  for (@bs) {
    my ($A, $B) = ($_->A, $_->B);
    my ($xa, $ya, $xb, $yb, $x, $y) = ($A->x, $A->y, $B->x, $B->y, $_->prize->x, $_->prize->y);
    my $n = (($xb*$y)-($yb*$x))/(($xb*$ya)-($yb*$xa));
    my $m = ($x-($n*$xa))/$xb;

    if ($n->integerp and $m->integerp) {
      $sum += $n*3+$m;
    }
  }

  $sum
}

sub p1 {
  say "p1: ", calc @machs;
}

sub p2 {
  say "p2: ", calc map {Machine->new(A => $_->A,
                                     B => $_->B,
                                     prize => Pt->new(
                                       x => $_->prize->x + $amnt,
                                       y => $_->prize->y + $amnt))} @machs;
}

p1;
p2;
