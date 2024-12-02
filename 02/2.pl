use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';

no warnings 'experimental';

my @l = map {[split / /, $_]} read_file('input');

sub okp {
  ($_) = @_;
  return 0 unless @$_~~ [sort {$a <=> $b} @$_] or @$_~~ [sort {$b <=> $a} @$_];

  for (my $i = 1; $i < @$_; ++$i) {
    return 0 if not abs($_->[$i-1]-$_->[$i]) ~~ [1..3]
  }

  return 1
}

sub p1 {
  do { ++$a if okp $_ } for @l;

  say "p1: $a";
}

sub p2 {
  my $res = 0;
  a: for $a (@l) {
    if (okp $a) {
      ++$res;
    } else {
      for (my $i = 0; $i < @$_+1; ++$i) {
        my @temp = @$a;
        splice(@temp, $i, 1);
        if (okp \@temp) {
          ++$res;
          next a;
        }
      }
    }
  }

  say "p2: $res";
}

p1;
p2;
