use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use List::MoreUtils ':all';
use Class::Struct;
use Storable 'dclone';
use autobox;

use GD;

our ($mx, $my) = (101, 103);

sub SCALAR::wrapx { $_[0] % $mx }
sub SCALAR::wrapy { $_[0] % $my }

struct Robot => {
  x  => '$',
  y  => '$',
  vx => '$',
  vy => '$',
};

my @robots;

for (read_file 'input') {
  /p=(\d+),(\d+) v=(-?\d+),(-?\d+)/;
  push @robots, Robot->new(x => $1, y => $2, vx => $3, vy => $4);
}

sub p1 {
  my ($q1, $q2, $q3, $q4) = (0) x 4; # cartesian
  my @rs = @{dclone \@robots};

  for (@rs) {
    $_->x(($_->x + $_->vx*100)->wrapx);
    $_->y(($_->y + $_->vy*100)->wrapy);

    next if $_->x == ($mx-1)/2 or $_->y == ($my-1)/2;

    if ($_->x < $mx/2) {
      if ($_->y < $my / 2) {
        $q2++;
      } else {
        $q3++;
      }
    } else {
      if ($_->y < $my / 2) {
        $q1++;
      } else {
        $q4++;
      }
    }
  }

  say "p1: ", $q1*$q2*$q3*$q4;
}

sub p2 {
  say "generating out.gif...";
  my $im = GD::Image->new($mx, $my);
  $im->trueColor(1);
  my $bg = $im->colorAllocate(0x2b, 0x33, 0x39);
  my $fg = $im->colorAllocate(0xa7, 0xc0, 0x80);
  $im->fill(0, 0, $bg);
  my $GIF = $im->gifanimbegin;

  my @rs = @{dclone \@robots};
  my @begin = @{dclone \@robots};

  for (my $i = 0;; $i++) {
    $im->filledRectangle(0, 0, $mx, $my, $bg);

    for (@rs) {
      $_->x(($_->x + $_->vx)->wrapx);
      $_->y(($_->y + $_->vy)->wrapy);
      $im->setPixel($_->x, $_->y, $fg);
    }

    $GIF .= $im->gifanimadd(0, 0, 0, 10);

    my $same = 0;
    for (0..@begin-1) {
      $same++ if $begin[$_]->x == $rs[$_]->x and $begin[$_]->y == $rs[$_]->y;
    }
    last if $same == @begin;
  }

  $GIF .= $im->gifanimend;

  open my $f, "|-", "gifsicle --optimize -o out.gif";
  print $f $GIF;
  close $f;
}

p1;
p2;
