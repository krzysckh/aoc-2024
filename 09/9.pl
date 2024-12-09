use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::MoreUtils ':all';
use Class::Struct;
use Storable qw(dclone);

struct Block => {
  id => '$',
  size => '$',
};

our @Blocks;

my @l = split '', read_file 'input';
my $it = natatime(2, @l);

my $id = 0;
while (($a, $b) = $it->()) {
  push @Blocks, Block->new(id => $id++, size => $a);
  push @Blocks, Block->new(id => -1, size => $b) unless not defined $b;
}

sub sum {
  my ($i, $sum) = (0, 0);
  for (@_) {
    for (my $v = $_->size; $v > 0; $v--) {
      $sum += $i*$_->id unless $_->id < 0;
      $i++
    }
  }
  $sum;
}

sub p1 {
  my @blocks = @{dclone \@Blocks};
 l: while (1) {
    my $last = pop @blocks;
    next if $last->id < 0;

    if (defined $last->size) {
      for my $i (0..@blocks-1) {
        $_ = $blocks[$i];
        if ($_->id < 0) { # found empty block
          if ($_->size == $last->size) {
            $_->id($last->id);
            goto ok;
          } elsif ($_->size > $last->size) {
            $_->id($last->id);
            splice @blocks, $i+1, 0, Block->new(id => -1, size => $_->size-$last->size);
            $_->size($last->size);
            goto ok;
          } else { # $_->size < $last->size
            $_->id($last->id);
            $last = Block->new(id => $last->id, size => $last->size-$_->size);
          }
        }
      }
      push @blocks, $last;
      last l; # no more empty blocks
    ok:
    }
  }

  say "p1: " . sum @blocks;
}

sub p2 {
  my @blocks = @{dclone \@Blocks};
  my $pt = 0;
  while (1) {
    $pt--;
    last if -$pt >= @blocks;
    my $last = $blocks[$pt];
    next if $last->id < 0;

    if (defined $last->size) {
      for my $i (0..@blocks+$pt) {
        $_ = $blocks[$i];
        if ($_->id < 0) {
          if ($_->size == $last->size) {
            $_->id($last->id);
            $last->id(-1);
            last;
          } elsif ($_->size > $last->size) {
            $_->id($last->id);
            splice @blocks, $i+1, 0, Block->new(id => -1, size => $_->size-$last->size);
            $_->size($last->size);
            $last->id(-1);
            last;
          }
        }
      }
    }
  }

  say "p2: " . sum @blocks;
}

p1;
p2;
