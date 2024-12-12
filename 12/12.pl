use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use List::Util qw(reduce min max);
use Class::Struct;

no warnings 'recursion';

struct Plot => {
  T         => '$', # type
  flag      => '$', # was this point visited?
  area      => '$', # only true at 1st points
  perimeter => '$', # same as above
  pts       => '$', # list of [x, y]
};

my %map; # hash of Y -> X -> Plot

open my $f, '<', 'input';

for (my $y = 0; not eof $f; ++$y) {
  $_ = <$f>;
  chomp;
  my @c = split '';
  for (0..@c-1) {
    $map{$y}->{$_} = Plot->new(T => $c[$_], pts => [], area => 1, perimeter => 0);
  }
}

close $f;

sub flood;
sub flood {
  my ($x, $y) = @_;

  my $p = $map{$y}->{$x};
  $p->flag(1);
  push @{$p->pts}, [$x, $y];

  if ($x - 1 >= 0 and $map{$y}->{$x-1}->T eq $p->T) {
    if (not defined $map{$y}->{$x-1}->flag) {
      flood $x-1, $y;
      $p->area($p->area + $map{$y}->{$x-1}->area);
      $p->perimeter($p->perimeter + $map{$y}->{$x-1}->perimeter);
      push @{$p->pts}, @{$map{$y}->{$x-1}->pts};
    }
  } else {
    $p->perimeter($p->perimeter+1);
  }

  if ($y - 1 >= 0 and $map{$y-1}->{$x}->T eq $p->T) {
    if (not defined $map{$y-1}->{$x}->flag) {
      flood $x, $y-1;
      $p->area($p->area + $map{$y-1}->{$x}->area);
      $p->perimeter($p->perimeter + $map{$y-1}->{$x}->perimeter);
      push @{$p->pts}, @{$map{$y-1}->{$x}->pts};
    }
  } else {
    $p->perimeter($p->perimeter+1);
  }

  if (defined $map{$y+1} and $map{$y+1}->{$x}->T eq $p->T) {
    if (not defined $map{$y+1}->{$x}->flag) {
      flood $x, $y+1;
      $p->area($p->area + $map{$y+1}->{$x}->area);
      $p->perimeter($p->perimeter + $map{$y+1}->{$x}->perimeter);
      push @{$p->pts}, @{$map{$y+1}->{$x}->pts};
    }
  } else {
    $p->perimeter($p->perimeter+1);
  }

  if (defined $map{$y}->{$x+1} and $map{$y}->{$x+1}->T eq $p->T) {
    if (not defined $map{$y}->{$x+1}->flag) {
      flood $x+1, $y;
      $p->area($p->area + $map{$y}->{$x+1}->area);
      $p->perimeter($p->perimeter + $map{$y}->{$x+1}->perimeter);
      push @{$p->pts}, @{$map{$y}->{$x+1}->pts};
    }
  } else {
    $p->perimeter($p->perimeter+1);
  }
}

sub sidesof {
  my ($sides, %m) = (0);
  my %ptsof; # hash of DIR -> Y -> X -> bool
  $m{$_->[1]}->{$_->[0]}++ for @{$_[0]};

  my $ymin = min keys %m;
  my $ymax = max keys %m;
  my $xmin = min map {keys %{$_}} values(%m);
  my $xmax = max map {keys %{$_}} values(%m);

  for my $y ($ymin..$ymax) {
    for my $x ($xmin..$xmax) {
      # right to left
      if ($m{$y}->{$x} and not $m{$y}->{$x+1}) {
        $sides++ unless $ptsof{RL}->{$y-1}->{$x};
        $ptsof{RL}->{$y}->{$x}++;
      }

      # left to right
      if ($m{$y}->{$x} and not $m{$y}->{$x-1}) {
        $sides++ unless $ptsof{LR}->{$y-1}->{$x};
        $ptsof{LR}->{$y}->{$x}++;
      }

      # bottom to top
      if ($m{$y}->{$x} and not $m{$y+1}->{$x}) {
        $sides++ unless $ptsof{BT}->{$y}->{$x-1};
        $ptsof{BT}->{$y}->{$x}++;
      }

      # top to bottom
      if ($m{$y}->{$x} and not $m{$y-1}->{$x}) {
        $sides++ unless $ptsof{TB}->{$y}->{$x-1};
        $ptsof{TB}->{$y}->{$x}++;
      }
    }
  }

  $sides
}

my @pts; # points with right values of ->area, ->perimeter, and ->pts

for my $y (0..keys(%map)-1) {
  for my $x (0..keys(%{$map{$y}})-1) {
    if (not defined $map{$y}->{$x}->flag) {
      flood $x, $y;
      push @pts, $map{$y}->{$x};
    }
  }
}


sub p1 {
  say "p1: ", reduce { $a + $b->area*$b->perimeter } 0, @pts;
}

sub p2 {
  say "p2: ", reduce { $a + $b->area*sidesof $b->pts} 0, @pts
}

p1;
p2;
