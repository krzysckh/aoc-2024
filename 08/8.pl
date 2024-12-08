use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::Util qw(reduce);
use List::MoreUtils ':all';
use Class::Struct;
use autobox;

sub ARRAY::has { any {$_ eq $_[1]} @{$_[0]} }

struct Node => {
  x => '$',
  y => '$',
};

my @l = map {chomp; [split '']} read_file 'input';
my %nodes; # hash of T -> Node
my ($mx, $my) = (scalar @l, scalar @{$l[0]});

for my $y (0..@l-1) {
  $_ = $l[$y];
  for my $x (0..@$_-1) {
    push @{$nodes{$_->[$x]}}, Node->new(x => $x, y => $y, T => $_->[$x])
      unless $_->[$x] eq '.'
  }
}

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

        $antinodes{$x1}->{$y1}++ if [0..$mx-1]->has($x1) and [0..$my-1]->has($y1);
        $antinodes{$x2}->{$y2}++ if [0..$mx-1]->has($x2) and [0..$my-1]->has($y2);
      }
    }
  }

  say "p1: " . reduce { $a + scalar keys %$b } 0, values %antinodes;
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
          last unless [0..$mx-1]->has($nx) and [0..$my-1]->has($ny);
          $antinodes{$nx}->{$ny}++;
        }

        for (my $i = 1; ; ++$i) {
          my ($nx, $ny) = ($_->x + $dx*$i, $_->y + $dy*$i);
          last unless [0..$mx-1]->has($nx) and [0..$my-1]->has($ny);
          $antinodes{$nx}->{$ny}++;
        }
      }
    }
  }

  say "p2: " . reduce { $a + scalar keys %$b } 0, values %antinodes;
}

p1;
p2;
