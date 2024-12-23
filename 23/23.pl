use strict;
use warnings;

use Modern::Perl '2023';
use File::Slurp;
use Array::Utils ':all';
use List::MoreUtils ':all';
use autobox;
use Class::Struct;

sub ARRAY::hasa  { any {@$_ ~~ $_[1]} @{$_[0]} }
sub Puter::names { map {$_->id} @{$_[0]->next} }

struct Puter => {
  id   => '$',
  next => '@'
};

my %map;
my %puters;

sub puter_of {
  my ($n) = @_;
  my $v = $puters{$n};

  if (defined $v) {
    return $v;
  } else {
    $puters{$n} = Puter->new(id => $n);
    return $puters{$n};
  }
}

for (read_file 'input') {
  /(.*)-(.*)/;
  $map{$1}->{$2}++;
  $map{$2}->{$1}++;
  push @{puter_of($1)->next}, puter_of($2);
  push @{puter_of($2)->next}, puter_of($1);
}

sub p1 {
  my @hist;
  for $a (keys %map) {
    next unless $a =~ /t./;
    for $b (keys %{$map{$a}}) {
      for (keys %{$map{$b}}) {
        if (defined $map{$_}->{$a}) {
          my @l = sort {$a cmp $b} ($a, $b, $_);
          push @hist, [@l] unless @hist->hasa(\@l);
        }
      }
    }
  }

  say "p1: ", scalar @hist;
}

my %cache;

sub j {
  join ",", sort {$a cmp $b} @_;
}

sub maxnet {
  my ($p) = @_;
  my @names = ($p->names, $p->id);
  my @ls = map {[$_->names, $_->id]} @{$p->next};
  my %h;

  for (@ls) {
    my @l = intersect(@names, @$_);
    push @{$h{scalar @l}}, [@l];
  }

  for my $v (sort {$b <=> $a} keys %h) {
    return ($v, j @{$h{$v}->[0]}) if scalar @{$h{$v}} == $v-1;
  }

  return 0;
}

sub p2 {
  my ($l, $p) = 0;
  for $a (values %puters) {
    ($a, $b) = maxnet $a;
    if ($a > $l) {
      $l = $a;
      $p = $b;
    }
  }

  say "p2: $p";
}

p1;
p2;
