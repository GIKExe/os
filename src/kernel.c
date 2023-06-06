#include "lib/io.c"
#include "lib/string.c"

void kmain(void)
{
	unsigned char* text;
	unsigned char* str;
	unsigned short index;
	print("Kernel 3.0");
	new_line();

	while (1)
	{
		print("> ");
		index = 0;
		text = input(40);

		if (strcmp(text, "ping"))
		{
			print("pong");
			new_line();
		}

	}
	
	return;
}