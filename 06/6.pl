use strict;
use warnings;

use Modern::Perl;
use File::Slurp;

no warnings 'experimental';

my @l = read_file 'input';
my (@map, $ox, $oy, @points);

my @dir = ([0, -1], [1, 0], [0, 1], [-1, 0]);
for my $i (0..@l-1) {
  $_ = $l[$i];
  ($ox, $oy) = (pos()-1, $i) if /\^/g;
  chomp;
  s/\^/./g;
  push @map, [split '', $_]
}

sub haltsp {
  my ($x, $y, $dp, %was) = ($ox, $oy, 0, ());
 l: while (1) {
    return 0 if defined $was{$x}->{$y}->{$dp};

    $was{$x}->{$y}->{$dp}++;
    my ($nx, $ny) = ($x + $dir[$dp]->[0], $y + $dir[$dp]->[1]);
    last l if $nx < 0 or $ny < 0;

    my $v = $map[$ny]->[$nx];
    if (not defined $v) {
      last l;
    } elsif ($v eq '#') {
      $dp = ($dp+1)%4
    } elsif ($v eq '.') {
     ($x, $y) = ($nx, $ny);
    }
  }

  return %was;
}

sub p1 {
  my %was = haltsp;

  for my ($x, $v) (%was) {
    for my ($y, $dps) (%$v) {
      push @points, [$x, $y];
    }
  }

  say "p1: " . scalar @points;
}

sub p2 {
  my $ctr = 0;
  for (@points) {
    my ($px, $py) = @$_;
    next if $px == $ox and $py == $oy;

    $map[$py]->[$px] = '#';
    $ctr++ if not haltsp;
    $map[$py]->[$px] = '.';
  }

  say "p2: $ctr";
}

p1;
p2; # must be executed after p1; depends on @points being correct
