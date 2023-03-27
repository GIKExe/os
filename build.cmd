@echo off
"FASM/fasm.exe" "main.fasm"
"C:\Program Files (x86)\UltraISO\UltraISO.exe" -file "C:\os\main.bin" -bootfile "C:\os\main.bin" -output "C:\os\main.iso"
pause