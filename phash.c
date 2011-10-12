/* table for the mapping for the perfect hash */
#ifndef STANDARD
#include "standard.h"
#endif /* STANDARD */
#ifndef PHASH
#include "phash.h"
#endif /* PHASH */
#ifndef LOOKUPA
#include "lookupa.h"
#endif /* LOOKUPA */

/* small adjustments to _a_ to make values distinct */
ub1 tab[] = {
  0,  1,};

/* The hash function */
ub4 phash(key, len)
char *key;
int   len;
{
  ub4 rsl, val = lookup(key, len, 0x5a0541b9);
  rsl = tab[val&0x1];
  return rsl;
}

