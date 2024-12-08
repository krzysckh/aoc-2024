use strict;
use warnings;

use Modern::Perl;
use File::Slurp;
use Data::Printer;
use List::Util qw(reduce);
use List::MoreUtils ':all';
use Class::Struct;
use autobox;

use GD;

struct Node => {
  x => '$',
  y => '$',
  T => '$'
};

my @l = map {chomp; [split '']} read_file 'input';
my %nodes;  # hash of T -> Node
my %colors; # hash of T -> Color
my ($vx, $vy) = ([0..scalar @l-1], [0..scalar @{$l[0]}-1]); # xs and ys on map

my $im = GD::Image->new($vx->[-1], $vy->[-1]);
$im->trueColor(1);
my $bg = $im->colorAllocate(0x3B, 0x32, 0x28);

my @colors = (
  $im->colorAllocate(0x53, 0x46, 0x36),
  $im->colorAllocate(0x64, 0x52, 0x40),
  $im->colorAllocate(0x7e, 0x70, 0x5a),
  $im->colorAllocate(0xb8, 0xaf, 0xad),
  $im->colorAllocate(0xd0, 0xc8, 0xc6),
  $im->colorAllocate(0xe9, 0xe1, 0xdd),
  $im->colorAllocate(0xf5, 0xee, 0xeb),
  $im->colorAllocate(0xcb, 0x60, 0x77),
  $im->colorAllocate(0xd2, 0x8b, 0x71),
  $im->colorAllocate(0xf4, 0xbc, 0x87),
);

$im->fill(0, 0, $bg);
my $GIF = $im->gifanimbegin;

do {
  my $i = 0;
  for my $y (0..@l-1) {
    $_ = $l[$y];
    for my $x (0..@$_-1) {
      unless (defined $colors{$_->[$x]}) {
        $colors{$_->[$x]} = $colors[$i++%@colors];
      }
      push @{$nodes{$_->[$x]}}, Node->new(x => $x, y => $y, T => $_->[$x]) unless $_->[$x] eq '.';
    }
  }
};

sub ARRAY::has   { any {$_ eq $_[1]} @{$_[0]} }
sub ARRAY::onmap { $vx->has($_[0]->[0]) and $vy->has($_[0]->[1]) }

sub p1 {
  my %antinodes; # hash of X -> Y -> n
  for (keys %nodes) {
    my $l = $nodes{$_};

    for (0..@$l-1) {
      my ($x, $y) = ($l->[$_]->x, $l->[$_]->y);
      for (@$l) {
        next if $_->x == $x and $_->y == $y;
        my ($dx, $dy) = ($_->x - $x, $_->y - $y);
        my ($x1, $y1) = ($x - $dx, $y - $dy);
        my ($x2, $y2) = ($_->x + $dx, $_->y + $dy);

        $antinodes{$x1}->{$y1}++ if [$x1, $y1]->onmap;
        $antinodes{$x2}->{$y2}++ if [$x2, $y2]->onmap;
      }
    }
  }

  say "p1: " . reduce { $a + keys %$b } 0, values %antinodes;
}

sub p2 {
  my %antinodes;
  for (keys %nodes) {
    my $l = $nodes{$_};

    for (0..@$l-1) {
      my ($x, $y) = ($l->[$_]->x, $l->[$_]->y);
      for (@$l) {
        next if $_->x == $x and $_->y == $y;
        my ($dx, $dy) = ($_->x - $x, $_->y - $y);
        my $color = $colors{$_->T};

        $antinodes{$_->x}->{$_->y}++;
        for (my $i = 1; ; ++$i) {
          my ($nx, $ny) = ($x - $dx*$i, $y - $dy*$i);
          last unless [$nx, $ny]->onmap;
          $im->setPixel($nx, $ny, $color);
          $GIF .= $im->gifanimadd;
          $antinodes{$nx}->{$ny}++;
        }

        for (my $i = 1; ; ++$i) {
          my ($nx, $ny) = ($_->x + $dx*$i, $_->y + $dy*$i);
          last unless [$nx, $ny]->onmap;
          $im->setPixel($nx, $ny, $color);
          $GIF .= $im->gifanimadd;
          $antinodes{$nx}->{$ny}++;
        }
      }
    }
  }

  $GIF .= $im->gifanimend;

  say "p2: " . reduce { $a + keys %$b } 0, values %antinodes;

  my ($w, $h) = ($im->width * 10, $im->height * 10);
  open my $f, "|-", "gifsicle --resize $w"."x$h --optimize -o out.gif";
  print $f $GIF;
  close $f;

  `ffmpeg -y -f gif -i out.gif -vf "setpts=0.01*PTS" -r 30 -pix_fmt yuv420p -c:v libx264 out.mp4`
}

p1;
p2;
