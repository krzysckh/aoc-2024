use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use List::MoreUtils ':all';
use List::Util 'sum';

my @vs = map {[map {[split '']} split /\n/]} split /\n\n/, read_file 'input';

my @locks;
my @keys;

for my $v (@vs) {
  my ($l, @a) = join('', @{$v->[0]}) eq '#' x 5 ? \@keys : \@locks;
  for $b (0..4) {
    push @a, sum(map {$v->[$_]->[$b] eq '#' ? 1 : 0} 1..5)
  }
  push @$l, [@a];
}

sub p1 {
  my $n = 0;
  for my $l (@locks) {
    for my $k (@keys) {
      $n++ if all {$_ <= 5} map {$k->[$_]+$l->[$_]} 0..4;
    }
  }

  say "p1: $n";
}

sub p2 {
  'uhh'
}

p1;
p2;
