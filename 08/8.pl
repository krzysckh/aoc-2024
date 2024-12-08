use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::Util qw(reduce);
use List::MoreUtils ':all';
use Class::Struct;
use autobox;

struct Node => {
  x => '$',
  y => '$',
};

my @l = map {chomp; [split '']} read_file 'input';
my %nodes; # hash of T -> Node
my ($vx, $vy) = ([0..scalar @l-1], [0..scalar @{$l[0]}-1]); # xs and ys on map

for my $y (0..@l-1) {
  $_ = $l[$y];
  for my $x (0..@$_-1) {
    push @{$nodes{$_->[$x]}}, Node->new(x => $x, y => $y, T => $_->[$x])
      unless $_->[$x] eq '.'
  }
}

sub ARRAY::has   { any {$_ eq $_[1]} @{$_[0]} }
sub ARRAY::onmap { $vx->has($_[0]->[0]) and $vy->has($_[0]->[1]) }

sub p1 {
  my %antinodes; # hash of X -> Y -> n
  for (keys %nodes) {
    my $l = $nodes{$_};

    for (0..@$l-1) {
      my ($x, $y) = ($l->[$_]->x, $l->[$_]->y);
      for (@$l) {
        next if $_->x == $x and $_->y == $y;
        my ($dx, $dy) = ($_->x - $x, $_->y - $y);
        my ($x1, $y1) = ($x - $dx, $y - $dy);
        my ($x2, $y2) = ($_->x + $dx, $_->y + $dy);

        $antinodes{$x1}->{$y1}++ if [$x1, $y1]->onmap;
        $antinodes{$x2}->{$y2}++ if [$x2, $y2]->onmap;
      }
    }
  }

  say "p1: " . reduce { $a + keys %$b } 0, values %antinodes;
}

sub p2 {
  my %antinodes;
  for (keys %nodes) {
    my $l = $nodes{$_};

    for (0..@$l-1) {
      my ($x, $y) = ($l->[$_]->x, $l->[$_]->y);
      for (@$l) {
        next if $_->x == $x and $_->y == $y;
        my ($dx, $dy) = ($_->x - $x, $_->y - $y);

        $antinodes{$_->x}->{$_->y}++;
        for (my $i = 1; ; ++$i) {
          my ($nx, $ny) = ($x - $dx*$i, $y - $dy*$i);
          last unless [$nx, $ny]->onmap;
          $antinodes{$nx}->{$ny}++;
        }

        for (my $i = 1; ; ++$i) {
          my ($nx, $ny) = ($_->x + $dx*$i, $_->y + $dy*$i);
          last unless [$nx, $ny]->onmap;
          $antinodes{$nx}->{$ny}++;
        }
      }
    }
  }

  say "p2: " . reduce { $a + keys %$b } 0, values %antinodes;
}

p1;
p2;
