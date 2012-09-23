CFLAGS = -O

.cc.o:
	gcc $(CFLAGS) -c $<

O_TEST = lookupa.o recycle.o phash.o testperf.o

OBJECTS = lookupa.o recycle.o perfhex.o perfect.o

all: perfect test

perfect : $(OBJECTS)
	gcc -o perfect $(OBJECTS) -lm

test : $(O_TEST)
	gcc -o test $(O_TEST) -lm

clean:
	rm ./*.o perfect test
	
# SAMPLE PHASH FILES

phash.c : perfect
	./perfect < samperf.txt

phash.h : perfect
	./perfect < samperf.txt

# DEPENDENCIES

lookupa.o  : lookupa.c lookupa.h

recycle.o  : recycle.c recycle.h

phash.o    : phash.c phash.h lookupa.h

testperf.o : testperf.c recycle.h phash.h

perfhex.o : perfhex.c lookupa.h recycle.h perfect.h

perfect.o : perfect.c lookupa.h recycle.h perfect.h
