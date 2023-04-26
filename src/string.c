
unsigned short len(unsigned char* str)
{
	unsigned short index = 0;
	while (str[index] != 0) { ++index; }
	return(index);
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

unsigned short count(unsigned char* str, unsigned char separator)
{	
	unsigned short n = 0, i = 0;
	while(str[i]){ if(str[i] == separator) { str[i] = 0; n++; } i++; }
	return(n);
}

unsigned char* hex_to_str(unsigned int num)
{	
	unsigned char table[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	unsigned char str[11] = {48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 0};
	unsigned char index = 9;
	while (index >= 0)
	{
		str[index] = table[(unsigned char) num % 16];
		num = num / 16;
		index--;
	}
	return(str);
}

// пример использования split
// unsigned short index = 0;
// unsigned char* str = "Hello World";
// unsigned char* str2;

// str2 = split(str, ' ', &index);
// str2 хранит "Hello"
// index хранит 6