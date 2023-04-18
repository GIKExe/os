
OUTPUT_FORMAT(pe-i386)
ENTRY(start)
SECTIONS
{
	. = 0x7c00;
	.text : { 
		*(.text);
		*(.data);
		*(.bss);
	}
}