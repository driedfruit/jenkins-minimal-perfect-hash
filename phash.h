/* Perfect hash definitions */
#ifndef STANDARD
#include "standard.h"
#endif /* STANDARD */
#ifndef PHASH
#define PHASH

extern ub1 tab[];
#define PHASHLEN 0x2  /* length of hash mapping table */
#define PHASHNKEYS 2  /* How many keys were hashed */
#define PHASHRANGE 2  /* Range any input might map to */
#define PHASHSALT 0x5a0541b9 /* internal, initialize normal hash */

ub4 phash();

#endif  /* PHASH */

