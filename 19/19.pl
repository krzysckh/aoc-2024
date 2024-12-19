use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use List::Util 'reduce';
use autobox;

sub SCALAR::sw { substr($_[0], 0, length $_[1]) eq $_[1] } # starts-with
sub SCALAR::fw { substr($_[0], $_[1]) } # forward

($a, $b) = (split '\n\n', read_file 'input');

my @vs = sort {length $b <=> length $a} split ', ', $a;
my @opts = split '\n', $b;

sub p1 {
  my $sum = 0;
  my $reg = reduce {"$a|$b"} @vs;

  for (@opts) {
    $sum++ if $_ =~ /^($reg)+$/x;
  }

  say "p1: $sum";
}

my %cache;

sub solve;
sub solve {
  my ($s) = @_;
  my ($ret) = (0);
  return 1 if $s eq "";

  return $cache{$s} if defined $cache{$s};

  for (@vs) {
    if ($s->sw($_)) {
      $ret += solve $s->fw(length $_);
    }
  }

  $cache{$s} = $ret;
  return $ret;
}

sub p2 {
  my $sum = 0;

  $sum += solve $_ for @opts;

  say "p2: $sum";
}

p1;
p2;
