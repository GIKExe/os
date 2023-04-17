
void kmain(void)
{
	const char *str = "my first kernel";
	char *vidmem = (char*)0xb8000; 	//видео пямять начинается здесь
	unsigned int i = 0;
	unsigned int j = 0;

	// этот цикл очищает экран
	while(j < 80 * 25 * 2) {
		vidmem[j] = ' ';    // пустой символ
		vidmem[j+1] = 0x07; // байт атрибутов
		j = j + 2;
	}

	j = 0;

	// в этом цикле строка записывается в видео память 
	while(str[j] != '\0') {
		/* ascii отображение */
		vidmem[i] = str[j];
		vidmem[i+1] = 0x07;
		++j;
		i = i + 2;
	}
	return;
}