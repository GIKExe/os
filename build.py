# MSYS2 UCRT64
# pacman -S mingw-w64-ucrt-x86_64-mtools

import os
import sys
import subprocess

# --- Настройки ---
IMAGE_NAME = "floppy.img"
# Ваш скомпилированный загрузчик (ровно 512 байт)
BOOTLOADER_FILE = "src/bootloader"
# Ваше ядро
KERNEL_FILE = "ass.bin"
# 1.44 МБ (стандартный размер дискеты)
IMAGE_SIZE = 1440 * 1024


def create_blank_image():
	print(f"[*] Создание пустого образа размером {IMAGE_SIZE / 1024} КБ: {IMAGE_NAME}")
	with open(IMAGE_NAME, "wb") as f:
		f.write(b'\x00' * IMAGE_SIZE)


def format_fat12():
	print("[*] Форматирование образа в FAT12 с помощью mtools...")
	# -i: файл образа, -f 1440: геометрия 1.44МБ, -v: метка тома
	cmd = ["mformat", "-i", IMAGE_NAME, "-f", "1440", "-v", "MYOS_DISK"]
	result = subprocess.run(cmd, capture_output=True, text=True)
	if result.returncode != 0:
		print(f"[!] Ошибка форматирования: {result.stderr}")
		sys.exit(1)
	print("[+] Образ успешно отформатирован.")


def write_bootloader():
	if not os.path.exists(BOOTLOADER_FILE):
		print(f"[!] Файл загрузчика '{BOOTLOADER_FILE}' не найден. Пропуск записи загрузчика.")
		print("[*] Образ останется со стандартным загрузочным сектором от mtools.")
		return

	print(f"[*] Запись загрузчика из '{BOOTLOADER_FILE}' в сектор 0 (MBR/VBR)...")
	with open(BOOTLOADER_FILE, "rb") as bf:
		boot_code = bf.read(512)

	if len(boot_code) > 512:
		print("[!] Предупреждение: Загрузчик больше 512 байт. Он будет обрезан.")
		boot_code = boot_code[:512]
	elif len(boot_code) < 512:
		boot_code = boot_code.ljust(512, b'\x00')

	# Проверка сигнатуры загрузочного сектора (0x55AA)
	if boot_code[510:512] != b'\x55\xaa':
		print("[!] Предупреждение: Загрузчик не заканчивается на стандартную сигнатуру 0x55AA.")

	# Перезаписываем самые первые 512 байт образа
	with open(IMAGE_NAME, "r+b") as img:
		img.seek(0)
		img.write(boot_code)
	
	print("[+] Загрузчик успешно записан.")
	print("[!] ВАЖНО: Убедитесь, что ваш 'bootloader.bin' содержит валидный BPB (BIOS Parameter Block)")
	print("[!] для FAT12 в начале сектора. Иначе файловая система может считаться повреждённой.")


def copy_kernel():
	if not os.path.exists(KERNEL_FILE):
		print(f"[!] Файл ядра '{KERNEL_FILE}' не найден. Пропуск копирования ядра.")
		return

	print(f"[*] Копирование '{KERNEL_FILE}' в файловую систему образа...")
	# mcopy автоматически преобразует имена файлов в формат 8.3 (например, KERNEL.BIN)
	cmd = ["mcopy", "-i", IMAGE_NAME, KERNEL_FILE, "::/"]
	result = subprocess.run(cmd, capture_output=True, text=True)
	if result.returncode != 0:
		print(f"[!] Ошибка копирования ядра: {result.stderr}")
		sys.exit(1)
	print("[+] Ядро успешно скопировано.")


def main():
	print("=== Генератор загрузочного образа ===")
	create_blank_image()
	format_fat12()
	write_bootloader()
	copy_kernel()
	print("\n[+] Образ \"floppy.img\" готов.")


if __name__ == "__main__":
	main()