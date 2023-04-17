@echo off
cd src
"..\nasm\nasm.exe" "main.nasm" -f elf32
"..\tcc\tcc.exe" -m32 -c kernel.c -o kernel.o
pause