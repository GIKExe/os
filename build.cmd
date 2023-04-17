@echo off
cd src
"..\nasm\nasm.exe" "main.nasm" -f elf32
pause