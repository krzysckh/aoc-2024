use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use Switch::Back;

my @vv = split '\n\n', read_file 'input';
my %dirs = ('^' => [0, -1], '>' => [1, 0], 'v' => [0, 1], '<' => [-1, 0]);
my @moves = split '\s+|', $vv[1];

my (%map, $bx, $by);
do {
  my $y = 0;
  for (split '\n', $vv[0]) {
    my $x = 0;
    for (split '', $_) {
      if ($_ eq '@') {
        ($bx, $by) = ($x, $y);
        $map{$y}->{$x++} = '.';
      } else {
        $map{$y}->{$x++} = $_;
      }
    }
    $y++;
  }
};

sub move {
  my ($x, $y, $move) = @_;
  my $delta = $dirs{$move};
  my ($nx, $ny) = ($x+$delta->[0], $y+$delta->[1]);
  given ($map{$ny}->{$nx}) {
    when ('.') { return ($nx, $ny) }
    when ('#') { return ($x, $y) }
    when ('O') {
      my ($nx2, $ny2) = ($nx+$delta->[0], $ny+$delta->[1]);
      my ($mx, $my) = move($nx, $ny, $move);
      if ($mx == $nx2 and $my == $ny2) {
        $map{$ny2}->{$nx2} = 'O';
        $map{$ny}->{$nx} = '.';
        return ($nx, $ny)
      } else {
        return ($x, $y)
      }
    }
  }
}

sub p1 {
  my ($x, $y) = ($bx, $by);
  for (@moves) {
    ($x, $y) = move $x, $y, $_;
  }

  my $sum = 0;
  for my $y (0..scalar(keys %map)-1) {
    for (0..scalar(keys %{$map{$y}})-1) {
      if ($map{$y}->{$_} eq 'O') {
        $sum += 100 * $y + $_;
      }
    }
  }

  say "p1: $sum";
}

p1;
