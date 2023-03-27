# from requests import get

# a = get('https://ru.wikipedia.org/wiki/Скан-код')

# st = '''<table class="wikitable">
# <tbody><tr>
# <th>Клавиша</th>
# <th>Код нажатия XT</th>
# <th>Код отпускания XT</th>
# <th>Код нажатия AT</th>
# <th>Код отпускания AT
# </th></tr>'''

# et = '</tbody></table>'

# i1 = a.text.index(st)
# text = a.text[i1+len(st):]
# i2 = text.index(et)
# text = text[:i2]

# for line in text.split('\n<tr>\n')[1:]:
# 	if '<th>' in line:
# 		args = line.split('<th>')[1:]
# 		key = args.pop(0)[:-6]
# 		while '<kbd' in key:
# 			i1 = key.index('<kbd')
# 			i2 = key.index('</kbd>')+6
# 			xt = key[i1:i2-6]
# 			i3 = xt.rindex('>')
# 			xt = xt[i3+1:]
# 			key = key[:i1] + xt + key[i2:]
# 		args.pop(0)
# 		args.pop(0)
# 		down = args.pop(0)[:-6]
# 		up = args.pop(0)[:-11]
# 		print(key, down, up)
# 	else:
# 		i1 = line.index('">')+2
# 		print(';', line[i1:-11])


with open('test.txt', 'r', encoding='1251') as file:
	text = file.read().split('\n')

# with open('test.txt', 'w') as file:
# 	for line in text:
# 		line = list(line.split('\t'))
# 		if len(line) == 5:
# 			line = line[:3]
# 		# print(line)
# 		line = ('\t'.join(line)) + '\n'
# 		file.write(line)

with open('key.fasm', 'w') as file:
	file.write('key: ')

	com = text.pop(0)
	table = {i:None for i in range(128)}

	for line in text:
		line = list(line.split('\t'))
		
		if len(line) == 3:
			name, did, uid = line

			byte = 0
			com = ''

			if len(name) == 1:
				if name.lower() != name:
					byte = f'"{name.lower()}"'
				else:
					if name in ['"', "'"]:
						byte = 0
						com = ' ; "'+"'"
					else:
						byte = f'"{name}"'
			else:
				com = f' ; {name}'

			if ',' in did:
				did2, did = did.split(',')
				# did = hex(int(did2, 16) + int(did, 16))[2:].upper()

			id = int(did, 16)
			if table[id] is None:
				table[id] = [byte, com]
				# print(f'{did} {uid} {sumbol}')
			else:
				print(f'[{id}] OLD:', table[id],'\n    ','NEW:', f'{did} {uid}, {byte}{com}')
	
	for key in table:
		# print(key, table[key])
		if table[key] is None:
			file.write('dw 0\n')
		else:
			file.write(f'dw {table[key][0]}{table[key][1]}\n')