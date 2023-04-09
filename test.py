from asm import *

def my_function(x: int = 1) -> int:
	if x > 20:
		return x / 20
	return x

deserializer = Deserializer(my_function.__code__)
print(deserializer.deserialize())

# file = open('test.fasm', 'w')

# byte = 'byte'
# word = 'word'
# dword = 'dword'
# qword = 'qword'

# regt = {
# 	'ax': ['al', 'ah', 'ax'],
# 	'bx': ['bl', 'bh', 'bx'],
# 	'cx': ['cl', 'ch', 'cx'],
# 	'dx': ['dl', 'dh', 'dx'],
# 	'si': ['si'],
# 	'di': ['di'],

# 	'eax': ['eax'],
# 	'ebx': ['ebx'],
# 	'ecx': ['ecx'],
# 	'edx': ['edx'],
# 	'esi': ['esi'],
# 	'edi': ['edi'],
# }

# def asm(data):
# 	t = type(data)
# 	if t == str:
# 		file.write(data+'\n')
# 	elif t == type(asm):
# 		pprint(data)
# 		pprint(dir(data.__code__))
# 		# pprint(data.__code__.co_varnames)

# 		f = data.__code__
# 		regs = []

# 		asm(f'macro {f.co_name} ' + ', '.join(f.co_varnames))
# 		asm('{')
# 		for varname in f.co_varnames[::-1]:
# 			asm(f'	push {varname}')
# 		asm(f'	call f_{f.co_name}')
# 		asm('}\n')

# 		asm(f'f_{f.co_name}:')
# 		sp = 4
# 		asm('\tpushf')
# 		for const in f.co_consts:
# 			if type(const) != str:
# 				continue
# 			for key in regt:
# 				for regname in regt[key]:
# 					if ' ' + regname not in const:
# 						continue
# 					if regname in regs:
# 						continue
# 					asm('\tpush '+regname)
# 					regs.insert(0, regname)
# 		asm('.main:')
# 		for const in f.co_consts:
# 			if type(const) != str:
# 				continue
# 			asm('\t' + const)
# 		asm('.return:')
# 		for regname in regs:
# 			asm('\tpop '+regname)
# 		asm('\tpopf')
# 		asm('\tret')

# pprint = print
# def print(sumbol_color:word):
# 	asm('mov ebx, [cursor]')
# 	asm('pop word [ebx]')

# if __name__ == '__main__':
# 	asm('include "boot.fasm"')
# 	asm('include "pm.fasm"')
# 	asm('jmp main\n')

# 	asm('cursor dd 0')
# 	asm(print)

# 	asm('\nmain:')
# 	asm('	jmp $')