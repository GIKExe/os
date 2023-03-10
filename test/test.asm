%define bool 1, 1

%define u1 2, 1
%define u2 3, 2

%define i1 18, 1
%define i2 19, 2

%define string(size, d) 34, size, d
%define tuple(size, d+) 35, size, d
%define var(size, name, d) 36, size, name, d
%define func(size, name, d+) 37, size, name, d

%macro def 1
%1:
	pusha
%endmacro

%macro defend 0
	popa
	ret
%endmacro

def test
	mov AX, 10
	inc AX
defend

data:
db var(18, \
	string(1, "a"), \
	tuple(14, \
		string(5, "hello"), \
		string(5, "world") \
	) \
)

db func(3, \
	string(1, "a") \
)