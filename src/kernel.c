
unsigned char *vidmem = (unsigned char*)0xB8000;
unsigned char *keymem = (unsigned char*)0x7E00;
unsigned int cursor = 0;

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

void print(unsigned char *text)
{
	unsigned int i = 0;
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
	unsigned char index;
	unsigned char *sumbol;
	unsigned char counter;

	// unsigned char *test = "F";
	// print(test);
	print("my first kernel 3.0 ");

	while(1)         
	{
		index = 0;
		while (index < 128)
		{	
			*sumbol = keymem[index*2];
			counter = keymem[index*2+1];
			if (sumbol[0] > 0)
			{
				// выполняется при нажитии клавиши
				if (counter == 1)
				{
					keymem[index*2+1] = 3;
					print(sumbol);
				}

				// выполняется при отпускании клавиши
				if (counter == 2)
				{
					keymem[index*2+1] = 0;
				}
			}
			++index;
		}
	}
	return;
}