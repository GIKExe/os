# MSYS2 UCRT64
# pacman -S mingw-w64-ucrt-x86_64-mtools

import os
import sys
import subprocess


# --- Настройки ---
NASM_EXE = "prog/nasm.exe"
NASM_SRC = "src/bootloader.nasm"
OUT_DIR = "out"
BOOTLOADER_FILE = f"{OUT_DIR}/bootloader.bin"
KERNEL_FILE = f"{OUT_DIR}/KERNEL.BIN"
KERNEL_SRC = "src/kernel.nasm"
IMAGE_NAME = "floppy.img"
IMAGE_SIZE = 1440 * 1024  # 1.44 МБ


def run_cmd(cmd, desc):
	"""Выполняет команду и выводит минималистичный статус."""
	print(f"[*] {desc}...", end=" ", flush=True)
	result = subprocess.run(cmd, capture_output=True, text=True)
	if result.returncode != 0:
		print("ОШИБКА")
		print(result.stderr.strip())
		sys.exit(1)
	print("OK")


def main():
	print(f"=== Сборка {IMAGE_NAME} ===")
	
	# 1.1 Компиляция загрузчика
	os.makedirs(OUT_DIR, exist_ok=True)
	run_cmd(
		[NASM_EXE, "-f", "bin", NASM_SRC, "-o", BOOTLOADER_FILE],
		"Компиляция bootloader"
	)
	
	# 1.2 Компиляция ядра
	os.makedirs(OUT_DIR, exist_ok=True)
	run_cmd(
		[NASM_EXE, "-f", "bin", KERNEL_SRC, "-o", KERNEL_FILE],
		"Компиляция kernel"
	)

	# 2. Создание и форматирование образа
	with open(IMAGE_NAME, "wb") as f:
		f.write(b'\x00' * IMAGE_SIZE)
	
	run_cmd(
		["mformat", "-i", IMAGE_NAME, "-f", "1440", "-v", "MYOS_DISK"],
		"Форматирование FAT12"
	)

	# 3. Запись загрузчика в сектор 0
	with open(BOOTLOADER_FILE, "rb") as bf:
		boot_code = bf.read(512)
	
	if len(boot_code) < 512:
		boot_code = boot_code.ljust(512, b'\x00')
	elif len(boot_code) > 512:
		print("[!] Внимание: Загрузчик обрезан до 512 байт")
		boot_code = boot_code[:512]
		
	if boot_code[510:512] != b'\x55\xaa':
		print("[!] Внимание: Отсутствует сигнатура 0x55AA")

	with open(IMAGE_NAME, "r+b") as img:
		img.seek(0)
		img.write(boot_code)
	print("[*] Запись загрузчика (MBR/VBR)... OK")

	# 4. Копирование ядра
	if os.path.exists(KERNEL_FILE):
		run_cmd(
			["mcopy", "-i", IMAGE_NAME, KERNEL_FILE, "::/"],
			"Копирование ядра"
		)
	else:
		print(f"[!] {KERNEL_FILE} не найден, пропуск.")

	print(f"[+] Готово: {IMAGE_NAME}")


if __name__ == "__main__":
	main()