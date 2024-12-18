use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use Class::Struct;

no warnings 'recursion';

my $mv = 70;
my %map;

my @full = map {chomp; [split /,/]} read_file 'input';

struct Edge => {
  x => '$',
  y => '$',
  v => '$'
};

sub solve1;
sub solve1 {
  my ($edges) = @_;

  my @fin;
  my @e;
  for my $p (@$edges) {
    if ($p->x == $mv and $p->y == $mv) {
      push @fin, $p;
    }
    for ([-1, 0], [1, 0], [0, -1], [0, 1]) {
      my ($y, $x) = ($p->y+$_->[0], $p->x+$_->[1]);
      if (not defined $map{$y}->{$x}) {
        next unless $y >= 0 and $x >= 0 and $x <= $mv and $y <= $mv;
        $map{$y}->{$x}++;
        push @e, Edge->new(y => $y, x => $x, v => $p->v + 1)
      }
    }
  }

  for (@e) {
    my @l = solve1 \@e;
    @fin = (@fin, @l);
  }

  return @fin;
}

# solve1 modified slightly to return right after a path was found
sub solve2;
sub solve2 {
  my ($edges) = @_;

  my @e;
  for my $p (@$edges) {
    if ($p->x == $mv and $p->y == $mv) {
      return [$p];
    }
    for ([-1, 0], [1, 0], [0, -1], [0, 1]) {
      my ($y, $x) = ($p->y+$_->[0], $p->x+$_->[1]);
      if (not defined $map{$y}->{$x}) {
        next unless $y >= 0 and $x >= 0 and $x <= $mv and $y <= $mv;
        $map{$y}->{$x}++;
        push @e, Edge->new(y => $y, x => $x, v => $p->v + 1)
      }
    }
  }

  for (@e) {
    my @l = solve2 \@e;
    return @l if scalar @l > 0;
  }

  return ();
}

sub map_upto {
  %map = ();

  for (@full[0..$_[0]-1]) {
    $map{$_->[1]}->{$_->[0]} = '#';
  }
}

sub p1 {
  map_upto 1024;
  my @r = solve1 [Edge->new(x => 0, y => 0, v => 0)];
  say "p1: ", [sort {$a <=> $b} map {$_->v} @r]->[0];
}

sub p2 {
  my $i;
  for ($i = 1024; $i < @full; $i++) {
    map_upto $i;
    my @r = solve2 [Edge->new(x => 0, y => 0, v => 0)];
    last if scalar @r == 0;
  }

  say "p2: ", join(",", $full[$i-1]->[0], $full[$i-1]->[1]);
}

p1;
p2;
