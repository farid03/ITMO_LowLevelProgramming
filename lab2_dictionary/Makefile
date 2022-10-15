ASM=nasm
ASMFLAGS=-felf64
LD=ld

main: main.o dict.o lib.o
	$(LD) -o $@ $^

main.o: main.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


dict.o: dict.asm lib.inc
	$(ASM) $(ASMFLAGS) -o $@ $<

lib.o: lib.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f *.o main

.PHONY: clean
