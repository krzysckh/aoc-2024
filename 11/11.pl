use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';

no warnings;

my @s = split /\s+/, read_file 'input';

sub blink ($) {
  my ($sum, %l);                              # l: hash of value -> count
  $l{$_}++ for @s;

  for (1..$_[0]) {                            # perlcritic can suck my left nut
    my %diff;
    for my $v (keys %l) {
      if ($v eq '0') {
        $diff{'1'} += $l{$v};
        $diff{$v} -= $l{$v};
      } elsif (length($v) % 2 == 0) {
        my $len = length $v;
        $diff{0+substr $v, $len/2} += $l{$v}; # +0 to delete prefixing zeros
        $diff{substr $v, 0, $len/2} += $l{$v};
        $diff{$v} -= $l{$v};
      } else {
        $diff{$v*2024} += $l{$v};
        $diff{$v} -= $l{$v};
      }
    }

    for my ($k, $v) (%diff) {
      $l{$k} += $v;
    }
  }

  $sum += $_ for values %l;
  $sum
}

sub p1 {
  say "p1: " . blink 25
}

sub p2 {
  say "p2: " . blink 75
}

p1;
p2;
