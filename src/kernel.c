
unsigned char* vidmem = (unsigned char*)0xB8000;
unsigned char* keymem = (unsigned char*)0x7E00;
unsigned int cursor = 0;

unsigned char left_shift = 0;
unsigned char right_shift = 0;

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

void prints(unsigned char* text)
{
	unsigned int i = 0;
	while(text[i] != '\0') { print(text[i], 0x0F); ++i; }
}

void print_by_index(unsigned char* text, unsigned short len)
{	
	unsigned short index = 0;
	while (len > 0)
	{
		print(text[index], 0x90);
		++index;
		--len;
	}
}

unsigned char* dec_to_str(unsigned short num)
{
	unsigned char index = 4;
	unsigned char str[5] = {48, 48, 48, 48, 48};

	// while (num > 0 && index >= 0)
	// {
	// 	// str[index] = (unsigned char) num % 10 + 48;
	// 	num = num / 10;
	// 	--index;
	// }
	return(str);
}

unsigned char streq(unsigned char* str1, unsigned char* str2)
{
	unsigned short index;
	if (str1[0] == '\0' && str2[0] == '\0') { return(1); }
	for (index=0; str1[index] != '\0'; index++)
	{ if (str1[index] != str2[index]) { return(0); } }
	if (str2[index] != '\0') { return(0); }
	return(1);
}

// Иван: успешно спизжено, но нихера не понимаю(
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
		while (index < 512)
		{	
			// выход если символ пустой
			if (left_shift || right_shift) { sumbol = keymem[index + 3]; }
			else { sumbol = keymem[index + 2]; }

			if (sumbol == 0) {index = index + 4; continue; }

			// выполняется при нажитии клавиши
			counter = keymem[index];
			if (counter == 1)
			{	
				keymem[index] = 3;

				if (sumbol == 0x0A) // Enter
				{
					// prints("EXIT");
					running = 0;
					break;
				}
				else if (sumbol == 0x08) // BackSpace
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
				else if (sumbol == 0x0E)
				{
					left_shift = 1;
				}
				else if (sumbol == 0x0F)
				{
					right_shift = 1;
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
				keymem[index] = 0;
				if (sumbol == 0x0E)
				{
					left_shift = 0;
				}
				else if (sumbol == 0x0F)
				{
					right_shift = 0;
				}
			}
			index = index + 4;
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
	if (streq(text, "123"))
	{
		prints("ok");
	}
	return;
}