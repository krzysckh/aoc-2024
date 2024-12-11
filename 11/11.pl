use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;

my @s = split /\s+/, read_file 'input';

sub blink {
  my ($sum, %l); # l: hash of value -> count
  $l{$_}++ for @s;

  for (1..$_[0]) {
    my %apply;
    for my $v (keys %l) {
      if ($v == 0) {
        $apply{1} += $l{$v};
        $apply{$v} -= $l{$v};
      } elsif (length($v) % 2 == 0) {
        my $len = length $v;
        $apply{0+substr $v, $len/2} += $l{$v}; # +0 to delete prefixing zeros
        $apply{substr $v, 0, $len/2} += $l{$v};
        $apply{$v} -= $l{$v};
      } else {
        $apply{$v*2024} += $l{$v};
        $apply{$v} -= $l{$v};
      }
    }

    while (my ($k, $v) = each %apply) {
      $l{$k} += $v;
    }
  }

  $sum += $_ for values %l;
  $sum
}

sub p1 {
  say "p1: ", blink 25
}

sub p2 {
  say "p2: ", blink 75
}

p1;
p2;
