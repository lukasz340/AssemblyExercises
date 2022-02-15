.686
.model flat
public _find_max_range
.data
v dd ?
alpha dd ?
g dd 9.82
do_sinus dd 180.0
.code

_find_max_range PROC
push ebp
mov ebp, esp

mov edi, [ebp+8]; v
mov esi, [ebp+12]; alpha


mov dword ptr v, edi
mov dword ptr alpha, esi

finit

fld v
fld v
fmul ;v^2

fld alpha
fld alpha
fadd  ; 2alpha
fldpi
fmul
fld do_sinus
fdiv ;  2alfa rad

fsin
fmul

fld g
fld g
fadd

fdiv
fld1
fld1
fadd
fmul

pop ebp
ret
_find_max_range ENDP
END
