use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use Class::Struct;
use autobox;

sub SCALAR::integerp { $_[0] =~ /^\d+$/ }

struct Pt => {
  x => '$',
  y => '$',
};

struct Machine => {
  A => 'Pt', # button A
  B => 'Pt', # button B
  P => 'Pt'  # point of the Prize
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
  push @machs, Machine->new(A => $a, B => $b, P => Pt->new(x => $1, y => $2));
}

sub solve {
  my (@bs) = @_;
  my $sum = 0;
  for (@bs) {
    my ($xa, $ya, $xb, $yb, $x, $y) = ($_->A->x, $_->A->y, $_->B->x, $_->B->y, $_->P->x, $_->P->y);
    my $n = (($xb*$y)-($yb*$x))/(($xb*$ya)-($yb*$xa));
    my $m = ($x-($n*$xa))/$xb;

    $sum += $n*3+$m if $n->integerp and $m->integerp;
  }

  $sum
}

sub p1 {
  say "p1: ", solve @machs;
}

sub p2 {
  say "p2: ", solve map {Machine->new(A => $_->A, B => $_->B, P => Pt->new(x => $_->P->x + $amnt,
                                                                           y => $_->P->y + $amnt))} @machs;
}

p1;
p2;
