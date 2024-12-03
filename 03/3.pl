use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use Switch::Back;

my @data = read_file('input') =~ /(?:don\'t\(\))|(?:do\(\))|(?:mul\((?:\d{1,3}),(?:\d{1,3})\))/g;

sub p1 {
  my $sum;

  for (@data) {
    $sum += $1 * $2 if /mul\((\d+),(\d+)\)/
  }

  say "p1: $sum"
}

sub p2 {
  my ($sum, $dont);
  for (@data) {
    when (/mul\((\d+),(\d+)\)/) { $sum += $1 * $2 unless $dont }
    when (/don/)                { $dont = 1 }
    default                     { $dont = 0 }
  }

  say "p2: $sum"
}

p1;
p2;
