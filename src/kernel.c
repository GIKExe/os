
void kmain(void)
{
	const char *str = "my first kernel";
	char *vidmem = (char*)0xb8000; 	//видео пямять начинается здесь
	unsigned int i = 0;
	unsigned int cursor = 0;

	// этот цикл очищает экран
	while(cursor < 80 * 25 * 2) {
		vidmem[cursor] = ' ';    // пустой символ
		vidmem[cursor+1] = 0x07; // байт атрибутов
		cursor = cursor + 2;
	}

	cursor = 0;

	// в этом цикле строка записывается в видео память 
	while(str[i] != '\0') {
		/* ascii отображение */
		vidmem[cursor] = str[i];
		vidmem[cursor+1] = 0x07;
		++i;
		cursor = cursor + 2;
	}
	return;
}