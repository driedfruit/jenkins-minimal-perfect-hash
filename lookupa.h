/*
------------------------------------------------------------------------------
By Bob Jenkins, September 1996.
lookupa.h, a hash function for table lookup, same function as lookup.c.
Use this code in any way you wish.  Public Domain.  It has no warranty.
Source is http://burtleburtle.net/bob/c/lookupa.h
------------------------------------------------------------------------------
*/

#ifndef LOOKUPA
#define LOOKUPA

#ifdef _MSC_VER
typedef __int8 int8_t;
typedef unsigned __int8 uint8_t;
typedef __int32 int32_t;
typedef unsigned __int32 uint32_t;
typedef __int64 int64_t;
typedef unsigned __int64 uint64_t;
#else
#include <stdint.h>
#endif

#define CHECKSTATE 8
#define hashsize(n) ((uint32_t)1<<(n))
#define hashmask(n) (hashsize(n)-1)

uint32_t lookup(uint8_t *k, uint32_t length, uint32_t level);
void checksum(uint8_t *k, uint32_t length, uint32_t *state);

#endif /* LOOKUPA */
