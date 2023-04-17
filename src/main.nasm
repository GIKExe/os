%include "boot.nasm"
%include "pm.nasm"

mov word [es:0], (4 << 8) + 'Y'
hlt