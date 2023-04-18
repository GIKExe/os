
unsigned char *vidmem = (unsigned char*)0xb8000;
unsigned int cursor = 0;
unsigned int i = 0;

void clear(void)
{	
	cursor = 0;
	while(cursor < 80 * 25 * 2)   // этот цикл очищает экран
	{ 
		vidmem[cursor] = ' ';     // пустой символ
		vidmem[cursor+1] = 0x07;  // байт атрибутов
		cursor = cursor + 2;
	}
	cursor = 0;
}

void print(char *text)
{
	i = 0;
	while(text[i] != '\0')         // в этом цикле строка записывается в видео память 
	{
		vidmem[cursor] = text[i];  // ascii отображение
		vidmem[cursor+1] = 0x0F;
		++i;
		cursor = cursor + 2;
	}
}

void kmain(void)
{	
	print("my first kernel 3.0");
	return;
}