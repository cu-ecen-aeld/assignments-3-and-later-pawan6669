
ifdef CROSS_COMPILE
	cc=${CROSS_COMPILE}gcc
else
	cc=gcc
endif

all:
	${cc} -static finder-app/writer.c -o finder-app/writer


clean:
	rm -f finder-app/writer
