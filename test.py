from requests import get

a = get('https://ru.wikipedia.org/wiki/Скан-код')

st = '''<table class="wikitable">
<tbody><tr>
<th>Клавиша</th>
<th>Код нажатия XT</th>
<th>Код отпускания XT</th>
<th>Код нажатия AT</th>
<th>Код отпускания AT
</th></tr>'''

et = '</tbody></table>'

i1 = a.text.index(st)
text = a.text[i1+len(st):]
i2 = text.index(et)
text = text[:i2]

for line in text.split('\n<tr>\n')[1:]:
	if '<th>' in line:
		args = line.split('<th>')[1:]
		key = args.pop(0)[:-6]
		while '<kbd' in key:
			i1 = key.index('<kbd')
			i2 = key.index('</kbd>')+6
			xt = key[i1:i2-6]
			i3 = xt.rindex('>')
			xt = xt[i3+1:]
			key = key[:i1] + xt + key[i2:]
		args.pop(0)
		args.pop(0)
		down = args.pop(0)[:-6]
		up = args.pop(0)[:-11]
		print(key, down, up)
	else:
		i1 = line.index('">')+2
		print(';', line[i1:-11])