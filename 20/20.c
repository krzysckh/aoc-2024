#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <limits.h>

static int lsz, Sx, Sy, Ex, Ey;
static char *omap; /* original map */

#define at(thing, x, y) (thing[((y)*lsz)+y+x])

/*
void
p(char *b)
{
  int i, j;

  for (i = 0; i < lsz; ++i) {
    for (j = 0; j < lsz; ++j)
      putchar(at(b, j, i));
    putchar('\n');
  }
}
*/

typedef struct {
  int x, y;
} Pt;

#define maybe_add(x, y, erm)                    \
  if (x >= 0 && x < lsz && y >= 0 && y < lsz) { \
    if (at(m, x, y) == 'E') {                   \
      return was+1;                             \
    } else if (at(m, x, y) != '#' || erm) {     \
      at(m, x, y) = '#';                        \
      new_edg[new_nedg++] = (Pt) { x, y };      \
    }                                           \
  }

int
search(char *m, int was, Pt *edg, int nedg)
{
  int i, new_nedg = 0, x, y;
  Pt new_edg[nedg*4];

  if (nedg == 0)
    return INT_MAX;

  // p(m);

  for (i = 0; i < nedg; ++i) {
    x = edg[i].x, y = edg[i].y;
    maybe_add(x+1, y, 0);
    maybe_add(x-1, y, 0);
    maybe_add(x, y+1, 0);
    maybe_add(x, y-1, 0);
  }

  return search(m, was+1, new_edg, new_nedg);
}

#if 0
int
search2(char *m, int was, Pt *edg, int nedg, int ticker)
{
  int i, new_nedg = 0, x, y, erm, v;
  Pt *new_edg = malloc(nedg*4*sizeof(Pt));

  if (nedg == 0) {
    free(new_edg);
    return INT_MAX;
  }

  // p(m);

  /* printf("ticker: %d\n", ticker); */

  for (i = 0; i < nedg; ++i) {
    x = edg[i].x, y = edg[i].y;
    erm = ticker <= 0 && ticker > -20;

    maybe_add(x+1, y, erm);
    maybe_add(x-1, y, erm);
    maybe_add(x, y+1, erm);
    maybe_add(x, y-1, erm);
  }

  v = search2(m, was+1, new_edg, new_nedg, ticker-1);
  free(new_edg);
  return v;
}
#endif

int
p1(void)
{
  int base = INT_MAX, above = 0, i, j, wlen;
  char *map = malloc(lsz * (lsz+1)+1);

  memcpy(map, omap, lsz*(lsz+1)-1);
  base = search(map, 0, (Pt[1]){(Pt){Sx, Sy}}, 1);

  for (i = 0; i < lsz; ++i) {
    for (j = 0; j < lsz; ++j) {
      memcpy(map, omap, lsz*(lsz+1)-1);
      wlen = INT_MAX;
      if (at(map, j, i) != '.') {
        at(map, j, i) = '.';
        wlen = search(map, 0, (Pt[1]){(Pt){Sx, Sy}}, 1);
      }

      // mfw int_max+1 is < base
      if (wlen < base && wlen+100 <= base)
        above++;
    }
  }

  free(map);

  return above;
}

// 1144 too low
// 13784 too low
// 23038 too low
// 23511 bad
#if 0
int
p2(void)
{
  int base = INT_MAX, above = 0, i, j, k, di, dj, wlen, mapn = 0;
  char *map = malloc(lsz * (lsz+1)+1), *maps[1<<18];

  memcpy(map, omap, lsz*(lsz+1)-1);
  base = search(map, 0, (Pt[1]){(Pt){Sx, Sy}}, 1);

    p(map);
  printf("base: %d\n", base);

  for (i = 0; i < base; ++i) {
    memcpy(map, omap, lsz*(lsz+1));
    wlen = search2(map, 0, (Pt[1]){(Pt){Sx, Sy}}, 1, i);
    /* p(map); */

    printf("wlen: %d\n", wlen);
    if (wlen < base && wlen+50 <= base) {
      printf("saved %d picoseconds\n", base - wlen);
    }

    if (wlen < base && wlen+100 <= base)
      above++;
  }

  free(map);

  return above;
}
#endif

int
main(void)
{
  FILE *fp = fopen("input", "r");
  size_t sz;
  int i, j;

  fseek(fp, 0, SEEK_END);
  sz = ftell(fp);
  rewind(fp);
  omap = malloc(sz+1);
  omap[sz] = 0;

  fread(omap, 1, sz, fp);

  for (lsz = 0; omap[lsz] != '\n'; lsz++) /* find lsz */
    ;

  for (i = 0; i < lsz; ++i)
    for (j = 0; j < lsz; ++j)
      if (at(omap, j, i) == 'S')
        Sx = j, Sy = i, at(omap, j, i) = '.';
      else if (at(omap, j, i) == 'E')
        Ex = j, Ey = i;

  printf("p1: %d\n", p1());
  /* printf("p2: %d\n", p2()); */

  free(omap);
}
