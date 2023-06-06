#pragma once

#include "bool.c"
#include "mem.c"

unsigned int cursor = 0;
unsigned char op = 0;

static inline void outb(unsigned short port, unsigned char val)
{
	asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
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

void new_line(void)
{
	unsigned short pos = cursor / 2;
	outb(0x3D4, 0x0F);
	outb(0x3D5, (unsigned char) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (unsigned char) ((pos >> 8) & 0xFF));
	cursor = ((pos / 80)+1)*2;
}

void print_symbol(unsigned char sumbol, unsigned char color)
{
    vidmem[cursor] = sumbol;
	vidmem[cursor+1] = color;
	cursor = cursor + 2;
	new_line();
}
void print_color(unsigned char* text, unsigned char color)
{
    unsigned int i = 0;
	while(text[i] != '\0') { print_symbol(text[i], color); ++i; }
}
void print(unsigned char* text)
{
    print_color(text, 0x0F);
}

unsigned char* input(unsigned char len)
{
    if (len > 40) {len = 40;}
	len = 40 - len;

	bool running = true;
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

					running = false;
					break;
				}
				else if (sumbol == 0x08) // BackSpace
				{	
					if ((cursor >= 2) & (text_index > 0))
					{
						cursor = cursor - 2;
						vidmem[cursor] = 0;
						vidmem[cursor+1] = 0x0F;
						new_line();

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
					print_symbol(sumbol, 0x02);
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