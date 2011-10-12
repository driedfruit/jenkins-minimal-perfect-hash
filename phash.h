/* Perfect hash definitions */
#ifndef STANDARD
#include "standard.h"
#endif /* STANDARD */
#ifndef PHASH
#define PHASH

extern ub1 tab[];
#define PHASHLEN 0x8000  /* length of hash mapping table */
#define PHASHNKEYS 61406  /* How many keys were hashed */
#define PHASHRANGE 65536  /* Range any input might map to */
#define PHASHSALT 0x78dde6e4 /* internal, initialize normal hash */

ub4 phash();

#endif  /* PHASH */

