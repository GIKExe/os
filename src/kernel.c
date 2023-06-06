#include "lib/io.c"
#include "lib/string.c"

void kmain(void)
{
	unsigned char* text;
	unsigned char* str;
	unsigned short index;
	print("Kernel 3.0", 0x2);
	new_line();

	while (1)
	{
		print("> ", 0xE);
		index = 0;
		text = input(40);
		new_line();

		if (strcmp(text, "ping"))
		{
			print("pong", 0xF);
			new_line();
		}
		
	}
	return;
}