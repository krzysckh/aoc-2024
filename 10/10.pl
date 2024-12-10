use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use Class::Struct;

struct Point => {
  height => '$',
  whar => '$'
};

my %map; # hash of Y -> X -> Point
my @zeros;

my $y = 0;
for (read_file 'input') {
  chomp;
  my @xs = split //, $_;
  for (0..@xs-1) {
    $map{$y}->{$_} = Point->new(height => $xs[$_] eq '.' ? -1 : $xs[$_], whar => undef);
    if ($xs[$_] eq '0') {
      push @zeros, [$_, $y];
    }
  }
  ++$y;
}

sub search;
sub search {
  my ($x, $y, $p2) = @_;
  my $p = $map{$y}->{$x};

  return 0 if not defined $p;
  if ($p->height == 9) {
    return $p2 ? 1 : 0 if defined $p->whar;
    $p->whar(1);
    return 1;
  }

  my @maybe = (
    [$x-1, $y],
    [$x+1, $y],
    [$x, $y-1],
    [$x, $y+1]
  );

  my $ret = 0;
  for (@maybe) {
    my $mp = $map{$_->[1]}->{$_->[0]};
    next if not defined $mp;
    if ($mp->height == ($p->height+1)) {
      $ret += search $_->[0], $_->[1], $p2;
    }
  }

  $map{$y}->{$x}->whar($ret);
  $ret
}

sub uhh {
  my ($p2) = @_;

  my $sum = 0;
  for (@zeros) {
    my $v = search $_->[0], $_->[1], $p2;
    $sum += $v;
    for my $k (keys %map) {
      for (keys %{$map{$k}}) {
        $map{$k}->{$_}->whar(undef);
      }
    }
  }

  $sum
}

sub p1 {
  say "p1: " . uhh
}

sub p2 {
  say "p2: " . uhh 1
}

p1;
p2;
