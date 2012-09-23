Bob Jenkins's Minimal Perfect Hashing is a little old, yet robust algorithm for
generating minimal perfect hash functions in C form, with a pretty solid cross-
platform implementaiton and small footprint.

I think it should be interesting to anyone studying (minimal) perfect hashing,
but it is also usable as is.

Project aim:

Update it to a modern form-factor (a git repo) to rise accessibility. Replace
"standart.h" with real standart headers, merge Makefiles, write small man page, 
etc (Maybe rewrite the text below to be less personal, to allow easier tweaks).

Dedicated to Public Domain.

Original code and article could be found [here].
 [here]: http://burtleburtle.net/bob/hash/perfect.html


## Minimal Perfect Hashing

**Perfect hashing** guarantees that you get no collisions at all. It is 
possible when you know exactly what set of keys you are going to be hashing
when you design your hash function. It's popular for hashing keywords for
compilers. (They _ought_ to be popular for [optimizing switch statements][1].)
**Minimal perfect hashing** guarantees that n keys will map to 0..n-1 with no
collisions at all. 

### C code and a sanity test

Here is my C code for minimal perfect hashing, plus a test case.

        links to source files were here, see git repository.

The generator is run like so, _"perfect -nm < samperf.txt"_ , and it produces the
C files [phash.h][21] and [phash.c][22]. The sanity test program, which uses
the generated hash to hash all the original keys, is run like so, _"test -nm <
samperf.txt"_.

### Usage

There are options (taken by both perfect and the sanity test):

         perfect [-{NnIiHhDdAa}{MmPp}{FfSs}] < key.txt 

Only one of NnIiHhAa may be specified. N is the default. These say how to
interpret the keys. The input is always a list of keys, one key per line.

N,n 

>	Normal mode, key is any string string (default). About 42+6n
	instructions for an n-byte key, or a 119+7n instructions if there are more
	than 218 keys. 

I,i

>  	Inline, key is any string, user will do initial hash. The initial hash must
	be

		  hash = PHASHSALT;
		  for (i=0; i<keylength; ++i) {
	    	  hash = (hash ^ key[i]) + ((hash<<26)+(hash>>6));
		  }

>	Note that this can be inlined in any user loop that walks through the key
	anyways, eliminating the loop overhead.

H,h

>	Keys are 4-byte integers in hex in this format:
    
		  ffffffff

>	In the worst case for up to 8192 keys whose values are all less than 0x10000,
	the perfect hash is this:

		  hash = key+CONSTANT;
		  hash += (hash>>8);
		  hash ^= (hash<<4);
		  b = (hash >> j) & 7;
		  a = (hash + (hash << k)) >> 29;
		  return a^tab[b];

>	...and it's usually faster than that. Hashing 4 keys takes up to 8
	instructions, three take up to 4, two take up to 2, and for one the hash is
	always "return 0".

>	Switch statements could be compiled as a perfect hash (perfect -hp < hex.txt),
	followed by a jump into a spring table by hash value, followed by a test of
	the case (since non-case values could have the same hash as a case value).
	That would be faster than the binary tree of branches currently used by gcc
	and the Solaris compiler.

D,d

>	Decimal. Same as H,h, but decimal instead of
	hexidecimal. Did I mention this is good for switch statement optimization?
	For 	example, the perfect hash for 1,16,256 is hash=((key+(key>>3))&3); 
	and the	perfect hash for 1,2,3,4,5,6,7,8 is hash=(key&7); and the perfect 
	hash for 1,4,9,16,25,36,49 is

		  ub1 tab[] = {0,7,0,2,3,0,3,0};
		  hash = key^tab[(key<<26)>>29];

A,a

>	An (A,B) pair is supplied in hex in this format:

		  aaaaaaaa bbbbbbbb

>	This mode does nothing but find the values of tab[]. If n is the number of
	keys and 2i <= n <= 2i+1, then A should be less than 2i if the hash is
	minimal, otherwise less than 2i+1. The hash is A^tab[B], or A^scramble[ tab[B] ]
	if there is a B bigger than 2048. The user must figure out how to generate
	(A,B). Unlike the other modes, the generator cannot rechoose (A,B) if it has
	problems, so the user must be prepared to deal with failure in this mode.
	Unlike other modes, this mode will attempt to increase smax.

>	Parse tables for production rules, or any static sparse tables, could be
	efficiently compacted using this option. Make B the row and A the column.
	For parse tables, B would be the state and A would be the ID for the next
	token. 
		-ap is a good option.
 
B,b

>	Same as A,a, except in decimal not hexidecimal.

Only one of MmPp may be specified. M is the default. These say whether to do a
minimal perfect hash or just a perfect hash.

M,m

>	Minimal perfect hash. Hash values will be in 0..nkeys-1, and every
	possible hash value will have a matching key. This is the default. The size
	of tab[] will be 3..8 bits per key.

P,p

>	Perfect hash. Hash values will be in 0..n-1, where n the smallest
	power of 2 greater or equal to the number of keys. The size of tab[] will
	be 1..4 bits per key.

Only one of FfSs may be specified. S is the default.

F,f

>	Fast mode. Don't construct the transitive closure. Try to find an
	initial hash within 10 tries, rather than within 2000 tries. (Transitive
	closure is used anyways for minimal perfect hashes with tab[] of size 2048
	or bigger because you just can't succeed without it.) This will generate a
	perfect hash in linear time in the number of keys. It will result in tab[]
	being much bigger than it needs to be.

S,s

>	Slow mode. Take more time generating the perfect hash in hopes of making
	tab[] as small as possible.


### Examples and Performance

Timings were done on a 500mhz Pentium with 128meg RAM, and it's actually the
number of cursor blinks not seconds. ispell.txt is a list of English words
that comes with EMACS. mill.txt was a million keys where each key was three
random 4-byte numbers in hex. tab[] is always an array of 1-byte values.
Normally I use a 166mhz machine with 32meg RAM, but a million keys died
thrashing virtual memory on that.

<b>

	Usage 						keys 	sec.	tab[] 	size minimal?

</b>

	perfect < samperf.txt		58		0		64		yes
	perfect -p < samperf.txt	58		0		32		no
	perfect < ispell.txt		38470	11		16384	yes
	perfect -p < ispell.txt		38470	4		4096	no
	perfect < mill.txt			1000000	65		524288	yes
	perfect -p < mill.txt		1000000	100		524288	no

### Algorithm

#### Initial hash returns (A,B), final hash is A^tab[B]

The perfect hash algorithm I use isn't a [Pearson hash][7]. My perfect hash
algorithm uses an initial hash to find a pair (A,B) for each keyword, then it
generates a mapping table tab[] so that A^tab[B] (or A^scramble[tab[B]]) is
unique for each keyword. tab[] is always a power of two. When tab[] has 4096
or more entries, scramble[] is used and tab[] holds 1-byte values. scramble[]
is always 256 values (2-byte or 4-byte values depending on the size of hash
values).

I found the idea of generating (A,B) from the keys in "Practical minimal
perfect hash functions for large databases", Fox, Heath, Chen, and Daoud,
Communications of the ACM, January 1992. (Dean Inada pointed me to that
article shortly after I put code for a Pearson-style hash on my site.)

Any specific hash function may or may not produce a distinct (A,B) for each
key. There is some probability of success. If the hash is good, the
probability of success depends only on the size of the ranges of A and B
compared to the number of keys. So the initial hash for this algorithm
actually must be a set of independent hash functions ("universal hashing").
Different hashes are tried from the set until one is found which produces
distinct (A,B). A probability of success of .5 is easy to achieve, but smaller
ranges for B (which imply smaller probabilities of success) require a smaller
tab[].

The different input modes use different initial hashes. Normal mode uses my
general hash [lookup()][13] (42+6n instructions) (or [checksum()][13] if there
are more than 218 keys). Inline mode requires the user to compute the initial
hash themself, preferably as part of tokenizing the key in the first place (to
eliminate the loop overhead and the cost of fetching the characters in the
key). Hex mode, which takes integer keys, does a brute force search to find
how little mixing it can get away with. AB mode gets the (A,B) pairs from the
user, giving the user complete control over initial mixing.

The final hash is always A^tab[B] or A^scramble[tab[B]]. scramble[] is
initialized with random distinct values up to smax, the smallest power of two
greater or equal to the number of keys. The trick is to fill in tab[].
Multiple keys may share the same B, so share the same tab[B]. The elements of
tab[] are handled in descending order by the number of keys.

#### Spanning Trees and Augmenting Paths

Finding values for tab[] such that A^tab[B] causes no collisions is known as
the "sparse matrix compression problem", which is NP complete. ("Computers and
Intractability, A Guide to the Theory of NP-Completeness", Garey & Johnson,
1979) Like most NP complete problems, there are fast heuristics for getting
reasonable (but not optimal) solutions. The heuristic I use involves spanning
trees.

Spanning trees and augmenting paths (with elements of tab[] as nodes) are used
to choose values for tab[b] and to rearrange existing values in tab[] to make
room. The element being added is the root of the tree.

Spanning trees imply a graph with nodes and edges, right? The nodes are the
elements of tab[]. Each element has a list of keys (tab[x] has all the keys
with B=x), and needs to be assigned a value (the value for tab[x] when
A^tab[B] is computed). Keys are added to the perfect hash one element of tab[]
at a time. Each element may contain many keys. For each possible value of
tab[x], we see what that value causes the keys to collide with. If the keys
collide with keys in only one other element, that defines an edge from the
other element pointing back to this element. If the keys collide with nothing,
that's a leaf, and the augmenting path follows that leaf along the nodes back
to the root.

If an augmenting path is found and all the nodes in it have one key apiece, it
is guaranteed the augmenting path can be applied. Changing the leaf makes room
for its parent's key, and so forth, until room is made for the one key being
mapped. (If the element to be mapped has only one key, and there is no
restriction on the values of tab[], augmenting paths aren't needed. A value
for tab[B] can be chosen that maps that key directly to an open hash value.)

If the augmenting path contains nodes with multiple keys, there is no
guarantee the agumenting path can be applied. Moving the keys for the leaf
will make room for the keys of the parent that collided with that leaf
originally, but there is no guarantee that the other keys in the leaf and the
parent won't apply. Empirically, this happens a around once per ten minimal
perfect hashes generated. There must be code to handle rolling back an
augmenting path that runs into this, but it's not worthwhile trying to avoid
the problem.

A possible strategy for finding a perfect hash is to accept the first value
tried for tab[x] that causes tab[x]'s keys to collide with keys in zero other
already-mapped elements in tab[]. ("Collide" means this some key in this
element has the same hash value as some key in the other element.) This
strategy is called "first fit descending" (recall that elements are tried in
descending order of number of keys).

A second, more sophisticated, strategy would allow the keys of tab[x] to
collide with zero or one other elements in tab[]. If it collides with one
other element, the problem changes to mapping that one other element. There is
no upper bound on the running time of this strategy.

The use of spanning trees and augmenting paths is almost as powerful as the
second strategy, and it is guaranteed to terminate within O(nn) time (per
element mapped). Is it faster or better on average? I don't know. I would
guess it is. Spanning trees can ignore already-explored nodes, while the
random jumping method doesn't.

How much do spanning trees help compared to first fit descending? First
consider the case where tab[] values can be anything. Minimal perfect hashes
need tab[] 31% bigger and perfect hashes need tab[] 4% bigger (on average) if
multikey spanning trees aren't used. Next the case where tab[] values are one
of 256 values. Minimal perfect hashes cannot be found at all, and perfect
hashes need tab[] 15% bigger on average.

It turns out that restricting the size of A in A^tab[B] is also a good way to
limit the size of tab[].

### Pointers to Non-Bob perfect hashing

Pointers to other implementations of perfect hashing

  1. [gperf][23] is a perfect hashing package available under the GNU license.
The hash it generates is usually slightly faster than mine, but it can't handle
anagrams (like if and fi, or tar and art), and it can't handle more than a
couple hundred keys. 
  2. [mph (Minimal Perfect Hash)][24] can do perfect hashes, minimal perfect
hashes, and order preserving minimal perfect hashes. I haven't looked into it
much yet, but it's promising. It's based on a paper by Majewski, who is an
expert in academia on the current state of the art of perfect hashes. Its doc
starts out "I wrote this for fun...", so download it and see what you can get
it to do! Perfect hashing IS fun. 
  3. Gonnet/Baeza-Yates of Chile have a [handbook on the web][25] with a
[section on perfect hashing][26]. I haven't tested this. 

### Minimal perfect hashing with Pearson hashes

A minimal perfect Pearson hash looks like this:
    
    
      hash = 0;
      for (i=0; i<len; ++i)
        hash = tab[(hash+key[i])%n];
    

It is almost always faster than my perfect hash in -i mode, by 0..3 cycles per
character (mostly depending on whether your machine has a barrelshift
instruction).

A _minimal perfect hash_ maps n keys to a range of n elements with no
collisions. A _perfect hash_ maps n keys to a range of m elements, m>=n, with
no collisions. If perfect hashing is implemented as a special table for
[Pearson's hash][27] (the usual implementation), minimal perfect hashing is
not always possible, with probabilities given in the table below. For example
the two binary strings {(0,1),(1,0)} are not perfectly hashed by the table
[0,1] or the table [1,0], and those are all the choices available. For sets of
8 or more elements, the chances are negligible that no perfect hash exists,
specifically (1-n!/nn)n!. Even if they do exist, finding one may be an
intractable problem.

	Number of elements	Chance that no mimimal perfect hash exists
	2					.25
	3					.2213773
	4					.0941787
	5					.0091061
	6					.0000137
	7					.0000000000000003

Although Pearson-style minimal perfect hashings do not always exist, minimal
perfect hashes always exist. For example, the hash which stores a sorted table
of all keywords, and the location of each keyword is its hash, is a minimal
perfect hash of n keywords into 0..n-1. This sorted-table minimal perfect hash
might not even be slower than Pearson perfect hashing, since the sorted-table
hash must do a comparison per bit of key, while the Pearson hash must do an
operation for every character of the key.

* * *

[Zbigniew J. Czech][28], an academic researcher of perfect hash functions

[ISAAC and RC4, fast stream ciphers][29]

[Hash functions for table lookup][30]

[Ye Olde Catalogue of Boy Scout Skits][31]

[jenny, generate cross-functional tests][32]

[Bob Jenkins' Web Site][33]

   [8]: jenkins-perfect/blob/master/makeperf.txt
   [9]: jenkins-perfect/blob/master/standard.h
   [10]: jenkins-perfect/blob/master/recycle.h
   [11]: jenkins-perfect/blob/master/recycle.c
   [12]: jenkins-perfect/blob/master/lookupa.h
   [13]: jenkins-perfect/blob/master/lookupa.c
   [14]: jenkins-perfect/blob/master/perfect.h
   [15]: jenkins-perfect/blob/master/perfect.c
   [16]: jenkins-perfect/blob/master/perfhex.c
   [17]: jenkins-perfect/blob/master/samperf.txt
   [18]: jenkins-perfect/blob/master/samperf2.txt
   [19]: jenkins-perfect/blob/master/testperf.c
   [20]: jenkins-perfect/blob/master/makeptst.txt
   [21]: jenkins-perfect/blob/master/phash.h
   [22]: jenkins-perfect/blob/master/phash.c
   [23]: http://www.gnu.org/software/gperf/
   [24]: http://metalab.unc.edu/pub/Linux/devel/lang/c/!INDEX.short.html
   [25]: http://www.dcc.uchile.cl/~oalonso/handbook/hbook.html
   [26]: http://www.dcc.uchile.cl/~oalonso/handbook/algs/3/3316.ins.c.html
   [27]: http://burtleburtle.net/bob/hash/pearson.html
   [28]: http://sun.iinf.polsl.gliwice.pl/~zjc/
   [29]: http://burtleburtle.net/bob/hash/../rand/isaac.html
   [30]: http://burtleburtle.net/bob/hash/index.html#lookup
   [31]: http://burtleburtle.net/bob/hash/../scout/index.html
   [32]: http://burtleburtle.net/bob/hash/../math/jenny.html
   [33]: http://burtleburtle.net/bob/hash/../index.html
