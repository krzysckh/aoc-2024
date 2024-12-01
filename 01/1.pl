use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';

my @data = map {[split / +/, $_]} split '\n', read_file("input");
my @ls = sort {$a <=> $b} map {0+$_->[0]} @data;
my @rs = sort {$a <=> $b} map {0+$_->[1]} @data;

sub p1 {
  my $sum;
  my $it = each_array(@ls, @rs);
  while (($a, $b) = $it->()) {
    $sum += abs($a-$b);
  }

  say "p1: $sum"
}

sub p2 {
  my ($sum, %h);

  $h{$_}++ for @rs;
  $sum += $_ * ($h{$_} or 0) for @ls;

  say "p2: $sum"
}

p1;
p2;
