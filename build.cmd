@echo off
cd src
"..\prog\nasm.exe" main.nasm -f elf32 -o ..\out\main.o
cd ..
"prog\tcc.exe" -m32 -c -ffreestanding -nostdlib -nostdinc src\kernel.c -o out\kernel.o
"prog\ld.exe" --script src\link.ld out\main.o out\kernel.o -o out\kernel.pe
"prog\objcopy.exe" -O binary out\kernel.pe out\kernel.bin
pause