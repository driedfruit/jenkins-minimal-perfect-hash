CFLAGS = -O

.cc.o:
	gcc $(CFLAGS) -c $<

O_TEST = lookupa.o recycle.o test_hash.o testperf.o

OBJECTS = lookupa.o recycle.o perfhex.o perfect.o

all: perfect test

perfect : $(OBJECTS)
	gcc -o perfect $(OBJECTS) -lm

test : $(O_TEST)
	gcc -o test $(O_TEST) -lm

clean:
	rm ./*.o perfect test

# SAMPLE PHASH FILES

test_hash.c : perfect
	./perfect -N test < samperf.txt

test_hash.h : perfect
	./perfect -N test < samperf.txt

# DEPENDENCIES

lookupa.o  : lookupa.c lookupa.h

recycle.o  : recycle.c recycle.h

test_hash.o : test_hash.c test_hash.h lookupa.h

testperf.o : testperf.c recycle.h test_hash.h

perfhex.o : perfhex.c lookupa.h recycle.h perfect.h

perfect.o : perfect.c lookupa.h recycle.h perfect.h
