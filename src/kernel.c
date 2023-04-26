#include "string.c"

unsigned char* vidmem = (unsigned char*)0xB8000;
unsigned char* keymem = (unsigned char*)0x7E00;
unsigned int cursor = 0;

// левый шифт
// правый шифт
unsigned char op = 0;

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

void new_line(void)
{
	// unsigned char x = 0;
	unsigned char y = 0;
	y = cursor/160;
	// x = cursor%160;
	cursor = (y+1)*160;
}

void print(unsigned char sumbol, unsigned char color)
{
	vidmem[cursor] = sumbol;
	vidmem[cursor+1] = color;
	cursor = cursor + 2;
	update_cursor();
}

void clear(void)
{	
	cursor = 0;
	while(cursor < 4000)
	{
		vidmem[cursor] = 0;
		vidmem[cursor+1] = 0x0F;
		cursor = cursor + 2;
	}
	cursor = 0;
}

void prints(unsigned char* text)
{
	unsigned int i = 0;
	while(text[i] != '\0') { print(text[i], 0x0F); ++i; }
}

void printi(unsigned char* text, unsigned short len)
{	
	unsigned short index = 0;
	while (len > 0)
	{
		print(text[index], 0x90);
		++index;
		--len;
	}
}

unsigned char* input(unsigned char len)
{	
	if (len > 40) {len = 40;}
	len = 40 - len;

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
			
			// переходим ко второму символу если нажат левый или правый шифт
			if ((op & 0b1) || (op & 0b10)) { sumbol = keymem[index + 3]; }
			else { sumbol = keymem[index + 2]; }
			
			// переходим к следующему элементу таблицы если символ пустой
			if (sumbol == 0) {index = index + 4; continue; }

			counter = keymem[index];
			if (counter == 1)
			{	
				keymem[index] = 3;

				if (sumbol == 0x0A) // Enter
				{	
					new_line();

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
						update_cursor();

						--text_index;
						text[text_index] = 0;
					}
				}
				else if (sumbol == 0x0E) // L shift
				{
					op = op | 0b1;
				}
				else if (sumbol == 0x0F) // R shift
				{
					op = op | 0b10;
				}
				else if (text_index + len < 40)
				{
					text[text_index] = sumbol;
					++text_index;
					print(sumbol, 0x02);
				}
			}

			// выполняется при отпускании клавиши
			if (counter == 2)
			{
				keymem[index] = 0;
				if (sumbol == 0x0E)  // L shift
				{
					op = op & 0b11111110;
				}
				else if (sumbol == 0x0F) // R shift
				{
					op = op & 0b11111101;
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
	unsigned char* str;
	unsigned short index;
	prints("my first kernel 3.0 ");

	while (1)
	{		
		clear();
		prints("> ");
		index = 0;
		text = input(40);

		// print(count(text, ' ')+48, 0x0E);
		prints(hex_to_str(0xFFFF));

		// str = split(text, ' ', &index);
		// prints(str);
		// new_line();
		// str = split(text, ' ', &index);
		// prints(str);
		// new_line();
		// str = split(text, ' ', &index);
		// prints(str);

		input(0);
		// if (streq(str, "print"))
		// {
		// 	str = split(text, ' ', &index);
		// 	if (streq(str, "mem"))
		// 	{
		// 		str = split(text, ' ', &index);
		// 		if (streq(str, "0"))
		// 		{
		// 			printi((unsigned char*)0x0, 512);
		// 			input(0);
		// 		}
		// 	}
		// }
	}
	
	return;
}