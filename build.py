#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import subprocess


# ----------------------------
# Настройки
# ----------------------------

OUT_DIR = "out"
BOOTLOADER_FILE = os.path.join(OUT_DIR, "bootloader.bin")
KERNEL_FILE = os.path.join(OUT_DIR, "KERNEL.BIN")

NASM_SRC = os.path.join("src", "bootloader.nasm")
KERNEL_SRC = os.path.join("src", "kernel.nasm")

IMAGE_NAME = "floppy.img"
IMAGE_SIZE = 1440 * 1024  # 1.44 МБ
VOLUME_LABEL = "MYOS_DISK"

# Если есть локальный prog/nasm.exe, используем его.
# Иначе пробуем найти nasm в PATH.
_DEFAULT_NASM = os.path.join("prog", "nasm.exe")
if not os.path.exists(_DEFAULT_NASM):
	_FOUND_NASM = shutil.which("nasm")
	if _FOUND_NASM:
		_DEFAULT_NASM = _FOUND_NASM

NASM_EXE = os.environ.get("NASM_EXE", _DEFAULT_NASM)

# Кэш уже сконвертированных путей в WSL.
_WSL_PATH_CACHE = {}


# ----------------------------
# Определение платформы
# ----------------------------

def is_windows():
	"""
	Возвращает True, если скрипт запущен в Windows.

	Важно: внутри WSL это уже Linux, поэтому там нужно вызывать
	mformat/mcopy напрямую, а не через wsl.
	"""

	# Обычный Windows Python.
	if os.name == "nt":
		return True

	# Cygwin/MSYS2 тоже работают в Windows.
	if sys.platform.startswith(("win", "cygwin", "msys")):
		return True

	# Если мы внутри WSL, ядро обычно содержит строку microsoft.
	try:
		with open("/proc/sys/kernel/osrelease", "r", encoding="utf-8") as f:
			if "microsoft" in f.read().lower():
				return False
	except Exception:
		pass

	# Дополнительная проверка для окружений, где платформа определена странно.
	return os.environ.get("OS", "") == "Windows_NT"


def die(message):
	print(message, file=sys.stderr)
	sys.exit(1)


# ----------------------------
# WSL helpers
# ----------------------------

def wsl_base_cmd():
	"""
	Возвращает базовую команду WSL.

	Опционально можно задать конкретный дистрибутив переменной окружения:
		WSL_DISTRO=Ubuntu
	"""

	cmd = ["wsl"]

	distro = os.environ.get("WSL_DISTRO", "").strip()
	if distro:
		cmd.extend(["-d", distro])

	return cmd


def _manual_windows_path_to_wsl(path):
	"""
	Ручная конвертация Windows-пути в WSL-путь.

	Используется как запасной вариант, если wslpath недоступен
	или не смог корректно конвертировать путь.
	"""

	p = str(path).replace("\\", "/")

	# Служебный Windows-префикс \\?\
	if p.startswith("//?/"):
		p = p[4:]

	# UNC-путь вида //server/share или уже WSL-путь.
	if p.startswith("//"):
		return p

	# MSYS2/Cygwin-стиль: /c/... -> /mnt/c/...
	if len(p) >= 3 and p[0] == "/" and p[2] == "/" and p[1].isalpha():
		return f"/mnt/{p[1].lower()}{p[2:]}"

	# Обычный Windows-путь: C:/... -> /mnt/c/...
	if len(p) >= 2 and p[1] == ":":
		drive = p[0].lower()
		rest = p[2:].lstrip("/")

		if rest:
			return f"/mnt/{drive}/{rest}"

		return f"/mnt/{drive}"

	return p


def to_wsl_path(path):
	"""
	Конвертирует путь в путь, понятный внутри WSL.

	Пример:
		C:\\Projects\\os\\floppy.img
		->
		/mnt/c/Projects/os/floppy.img
	"""

	if not is_windows():
		return str(path)

	raw = str(path)

	# Если путь уже похож на WSL-путь.
	if raw.replace("\\", "/").startswith("/mnt/"):
		return raw

	absolute = os.path.abspath(raw)

	cached = _WSL_PATH_CACHE.get(absolute)
	if cached:
		return cached

	converted = None

	if shutil.which("wsl"):
		cmd = wsl_base_cmd() + ["wslpath", "-a", "-u", absolute]

		try:
			result = subprocess.run(
				cmd,
				capture_output=True,
				text=True,
				errors="replace"
			)

			if result.returncode == 0:
				candidate = result.stdout.strip()
				if candidate:
					converted = candidate

		except Exception:
			converted = None

	manual = _manual_windows_path_to_wsl(absolute)

	if converted is None:
		converted = manual
	else:
		# Если wslpath не понял путь в стиле /c/..., но ручной конвертер понял.
		if manual.startswith("/mnt/") and not converted.startswith("/mnt/"):
			converted = manual

	_WSL_PATH_CACHE[absolute] = converted
	return converted


# ----------------------------
# Команды mtools
# ----------------------------

def mformat_command(image_path):
	if is_windows():
		return wsl_base_cmd() + [
			"mformat",
			"-i",
			to_wsl_path(image_path),
			"-f",
			"1440",
			"-v",
			VOLUME_LABEL,
		]

	return [
		"mformat",
		"-i",
		image_path,
		"-f",
		"1440",
		"-v",
		VOLUME_LABEL,
	]


def mcopy_command(image_path, source_path):
	if is_windows():
		return wsl_base_cmd() + [
			"mcopy",
			"-i",
			to_wsl_path(image_path),
			to_wsl_path(source_path),
			"::/",
		]

	return [
		"mcopy",
		"-i",
		image_path,
		source_path,
		"::/",
	]


# ----------------------------
# Запуск команд
# ----------------------------

def run_cmd(cmd, desc, fatal=True):
	"""
	Выполняет команду и выводит минималистичный статус.
	"""

	print(f"[*] {desc}...", end=" ", flush=True)

	try:
		result = subprocess.run(
			cmd,
			capture_output=True,
			text=True,
			errors="replace"
		)

	except FileNotFoundError:
		print("ОШИБКА")
		print(f"Не найден исполняемый файл: {cmd[0] if cmd else ''}", file=sys.stderr)
		if fatal:
			sys.exit(1)
		return False

	except Exception as exc:
		print("ОШИБКА")
		print(str(exc), file=sys.stderr)
		if fatal:
			sys.exit(1)
		return False

	if result.returncode != 0:
		print("ОШИБКА")

		stdout = (result.stdout or "").strip()
		stderr = (result.stderr or "").strip()

		if stdout:
			print(stdout, file=sys.stderr)

		if stderr:
			print(stderr, file=sys.stderr)

		if fatal:
			sys.exit(1)

		return False

	print("OK")
	return True


# ----------------------------
# Сборка
# ----------------------------

def find_nasm():
	candidate = NASM_EXE

	if os.path.exists(candidate):
		return candidate

	found = shutil.which(candidate)
	if found:
		return found

	found = shutil.which("nasm")
	if found:
		return found

	return candidate


def preflight():
	"""
	Проверяет окружение перед сборкой.
	"""

	os.makedirs(OUT_DIR, exist_ok=True)

	if is_windows():
		if not shutil.which("wsl"):
			die(
				"[!] Скрипт запущен на Windows, но утилита 'wsl' не найдена.\n"
				"    Установите WSL или добавьте wsl.exe в PATH."
			)
	else:
		for tool in ("mformat", "mcopy"):
			if not shutil.which(tool):
				die(
					f"[!] Не найден '{tool}'.\n"
					f"    Установите пакет mtools.\n"
					f"    Пример для Debian/Ubuntu: sudo apt install mtools"
				)

	for src in (NASM_SRC, KERNEL_SRC):
		if not os.path.exists(src):
			die(f"[!] Исходный файл не найден: {src}")

	nasm = find_nasm()

	if not os.path.exists(nasm) and not shutil.which(nasm):
		die(
			f"[!] NASM не найден: {NASM_EXE}\n"
			f"    Положите nasm в prog/nasm.exe, установите nasm в PATH\n"
			f"    или задайте переменную окружения NASM_EXE."
		)

	return nasm


def create_empty_image(path, size):
	print("[*] Создание пустого образа...", end=" ", flush=True)

	with open(path, "wb") as f:
		f.write(b"\x00" * size)

	print("OK")


def write_bootsector(image_path, bootloader_path):
	with open(bootloader_path, "rb") as f:
		boot_code = f.read()

	if len(boot_code) == 0:
		die("[!] Файл загрузчика пуст.")

	if len(boot_code) < 512:
		boot_code = boot_code.ljust(512, b"\x00")

	elif len(boot_code) > 512:
		print("[!] Внимание: загрузчик больше 512 байт и будет обрезан до 512 байт.")
		boot_code = boot_code[:512]

	if boot_code[510:512] != b"\x55\xaa":
		print("[!] Внимание: сигнатура 0x55AA отсутствует в первых 512 байтах загрузчика.")

	with open(image_path, "r+b") as img:
		img.seek(0)
		img.write(boot_code)

	print("[*] Запись загрузчика в сектор 0... OK")


def main():
	print(f"=== Сборка {IMAGE_NAME} ===")

	if is_windows():
		print("[i] Платформа: Windows. mformat/mcopy будут вызваны через WSL.")
	else:
		print("[i] Платформа: Linux/Unix. mformat/mcopy будут вызваны напрямую.")

	nasm = preflight()

	# 1. Компиляция загрузчика
	run_cmd(
		[NASM_EXE if not nasm else nasm, "-f", "bin", NASM_SRC, "-o", BOOTLOADER_FILE],
		"Компиляция bootloader"
	)

	# 2. Компиляция ядра
	run_cmd(
		[NASM_EXE if not nasm else nasm, "-f", "bin", KERNEL_SRC, "-o", KERNEL_FILE],
		"Компиляция kernel"
	)

	# 3. Создание пустого образа
	create_empty_image(IMAGE_NAME, IMAGE_SIZE)

	# 4. Форматирование образа в FAT12
	run_cmd(
		mformat_command(IMAGE_NAME),
		"Форматирование FAT12"
	)

	# 5. Запись загрузчика в сектор 0
	write_bootsector(IMAGE_NAME, BOOTLOADER_FILE)

	# 6. Копирование ядра на образ
	if os.path.exists(KERNEL_FILE):
		run_cmd(
			mcopy_command(IMAGE_NAME, KERNEL_FILE),
			"Копирование ядра"
		)
	else:
		print(f"[!] {KERNEL_FILE} не найден, пропуск.")

	print(f"[+] Готово: {IMAGE_NAME}")


if __name__ == "__main__":
	main()