CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o find_markers.o -f elf64 -g -l find_markers.lst find_markers.asm
cc :
	$(CC) -m64 -c -g -O0 main.cpp &> errors.txt
link :
	$(CC) -m64 -g -o find_markers main.o find_markers.o
clean :
	rm *.o
	rm find_markers
	rm errors.txt	
	rm find_markers.lst
