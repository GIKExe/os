@echo off

rmdir /s /q out
mkdir out

cd src
"..\prog\nasm.exe" main.nasm -f elf32 -o ..\out\main.o
cd ..
"prog\tcc.exe" -m32 -c -nostdlib src\kernel.c -o out\kernel.o
"prog\ld.exe" --script src\link.ld out\main.o out\kernel.o -o out\kernel.pe
"prog\objcopy.exe" -O binary out\kernel.pe out\kernel.bin
"prog\ultraliso.exe" -file out\kernel.bin -bootfile out\kernel.bin -out out\kernel.iso
pause