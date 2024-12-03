use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use Switch::Back;

my $data = read_file('input');

sub p1 {
  my @muls = $data =~ /mul\((\d{1,3}),(\d{1,3})\)/g;
  my $sum = 0;

  my $it = natatime(2, @muls);
  while (($a, $b) = $it->()) {
    $sum += ($a * $b);
  }

  say "p1: $sum";
}

sub p2 {
  my ($sum, $dont) = (0, 0);
  for ($data =~ /(?:don\'t\(\))|(?:do\(\))|(?:mul\((?:\d{1,3}),(?:\d{1,3})\))/g) {
    given ($_) {
      when (/mul/) { do { my @l = /mul\((\d+),(\d+)\)/; $sum += $l[0]*$l[1] } unless $dont };
      when (/don/) { $dont = 1 }
      default      { $dont = 0 }
    }
  }

  say "p2: $sum";
}

p1;
p2;
