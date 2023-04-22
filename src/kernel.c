
unsigned char *vidmem = (unsigned char*)0xB8000;
unsigned char *keymem = (unsigned char*)0x7E00;
unsigned int cursor = 0;

void print(unsigned char sumbol, unsigned char color)
{
	vidmem[cursor] = sumbol;
	vidmem[cursor+1] = color;
	cursor = cursor + 2;
}

void clear(void)
{	
	cursor = 0;
	while(cursor < 4000) { print(0, 0x0F); }
	cursor = 0;
}

void prints(unsigned char *text)
{
	unsigned int i = 0;
	while(text[i] != '\0') { print(text[i], 0x0F); ++i; }
}

static inline void outb(unsigned short port, unsigned char val)
{
    asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
}

void update_cursor(void)
{
	unsigned short pos = cursor / 2;
	outb(0x3D4, 0x0F);
	outb(0x3D5, (unsigned char) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (unsigned char) ((pos >> 8) & 0xFF));
}

unsigned char* input(void)
{	
	unsigned char running = 1;
	unsigned char text[40];
	unsigned char text_index = 0;

	unsigned char index;
	unsigned char sumbol;
	unsigned char counter;

	while(running)
	{
		index = 0;
		while (index < 128)
		{	
			sumbol = keymem[index*2];
			counter = keymem[index*2+1];
			if (sumbol > 0)
			{
				// выполняется при нажитии клавиши
				if (counter == 1)
				{	
					keymem[index*2+1] = 3;

					if (sumbol == 0x08) // BackSpace
					{	
						if ((cursor >= 2) & (text_index > 0))
						{
							cursor = cursor - 2;
							vidmem[cursor] = 0;
							vidmem[cursor+1] = 0x0F;

							--text_index;
							text[text_index] = 0;
						}
					}
					else if (sumbol == 0x0A) // Enter
					{
						running = 0;
					}
					else if (text_index < 40)
					{
						text[text_index] = sumbol;
						++text_index;
						print(sumbol, 0x02);
					}
					update_cursor();
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
	return(text);
}

void kmain(void)
{
	unsigned char* text;

	prints("my first kernel 3.0 ");
	text = input();
	cursor = 160;
	print('[', 4);
	prints(text);
	print(']', 4);
	return;
}