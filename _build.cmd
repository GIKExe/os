@echo off

rmdir /s /q out
mkdir out

cd src
"..\prog\nasm.exe" boot.asm -f elf32 -o ..\out\boot.o
"..\prog\tcc.exe" -m32 -c -nostdlib kernel.c -o ..\out\kernel.o
cd ..
"prog\ld.exe" --script src\link.ld out\boot.o out\kernel.o -o out\kernel.pe
"prog\objcopy.exe" -O binary out\kernel.pe out\kernel.bin
"prog\ultraliso.exe" -file out\kernel.bin -bootfile out\kernel.bin -out out\kernel.iso
pause