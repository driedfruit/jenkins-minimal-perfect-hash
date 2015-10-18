CFLAGS = -O

.cc.o:
	gcc $(CFLAGS) -c $<

O_TEST = lookupa.o recycle.o test_hash.o testperf.o
O_TEST1 = lookupa.o recycle.o words_hash.o testperf.o
OBJECTS = lookupa.o recycle.o perfhex.o perfect.o
WORDS  = /usr/share/dict/words

all: perfect test

perfect : $(OBJECTS)
	gcc -o perfect $(OBJECTS) -lm
test : $(O_TEST)
	gcc -o test $(O_TEST) -lm
test1 : $(O_TEST1)
	gcc -o test1 $(O_TEST1) -lm

check: test test1
	./test -nm < samperf.txt | sort -n | perl -anle'print $$F[0]'|\
		uniq -c | perl -anle'print "FAIL $$_" if $$F[0] != 1'
	./test1 -n < $(WORDS) | sort -n | perl -anle'print $$F[0]'|\
		uniq -c | perl -anle'print "FAIL $$_" if $$F[0] != 1'

clean:
	-rm ./*.o perfect test test1 *_hash.c *_hash.h

# SAMPLE PHASH FILES

test_hash.h test_hash.c : perfect
	-rm test_hash.h test_hash.c
	./perfect -N test < samperf.txt
words_hash.c : perfect
	-rm test_hash.h test_hash.c
	./perfect -N test < $(WORDS)
	cp test_hash.c words_hash.c

# DEPENDENCIES

lookupa.o  : lookupa.c lookupa.h

recycle.o  : recycle.c recycle.h

test_hash.o : test_hash.c test_hash.h lookupa.h

words_hash.o : words_hash.c test_hash.h lookupa.h

testperf.o : testperf.c recycle.h test_hash.h

perfhex.o : perfhex.c lookupa.h recycle.h perfect.h

perfect.o : perfect.c lookupa.h recycle.h perfect.h
