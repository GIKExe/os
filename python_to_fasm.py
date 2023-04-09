
# 16 bit
# 0x6A push byte
# 0x68 push word
# 0x50 push ax
# 0x53 push bx
# 0x51 push cx
# 0x52 push dx

# 83 F8 cmp ax, byte
# 83 FB cmp bx, byte

# 3B 06 0A 00 cmp ax, [10]

# 39 C3 cmp bx, ax
# 39 D8 cmp ax, bx


# 32 bit
# 0x66 0x50 push ax
# 0x66 0x53 push bx
# 0x66 0x51 push cx
# 0x66 0x52 push dx

inc_t8 = { # ключ FE
	'al': 0xC0, 'ah': 0xC4, 'bl': 0xC3, 'bh': 0xC7, 'cl': 0xC1, 'ch': 0xC5, 'dl': 0xC2, 'dh': 0xC6
}

inc_t16 = {
	'ax': 0x40, 'bx': 0x43, 'cx': 0x41, 'dx': 0x42, 'bp': 0x45, 'sp': 0x44, 'si': 0x46, 'di': 0x47 
}

inc_t32 = {'e'+i:inc_t16[i] for i in inc_t16}
inc_t64 = {'r'+i:inc_t16[i] for i in inc_t16}

# 1 - 16 bit
# 2 - 32 bit
# 3 - 64 bit
mode = 1

def inc(x, f=None):
	if x in inc_t8:
		return (0xFE, inc_t8[x])

	if x in inc_t16:
		if mode == 1:
			return (inc_t16[x])
		if mode == 2:
			return (0x66, inc_t16[x])
		if mode == 3:
			return (0x66, 0xFF, inc_t16[x])
		raise Exception('неподходящий режим')

	if x in inc_t32:
		if mode == 2:
			return (inc_t32[x])
		if mode == 3:
			return (0xFF, inc_t32[x])
		raise Exception('неподходящий режим')

	if x in inc_t64:
		if mode == 3:
			return (inc_t64[x])
		raise Exception('неподходящий режим')

	if type(x) == int:
		if x < 2**16:
			

	raise Exception('неподходящий операнд')

def mov(op1, op2):
	pass

def pushf():
	return b'\x9C'

def push(op1):
	pass

def popf():
	return b'\x9D'
