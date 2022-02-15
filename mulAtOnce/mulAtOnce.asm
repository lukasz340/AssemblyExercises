.686
.model flat
.XMM
public _mul_at_once;
.data

.code

_mul_at_once PROC
push ebp
mov ebp, esp

mov edi, [ebp+8]; one
mov esi, [ebp+12]; two


movups xmm0, dword ptr[edi]
movups xmm5, dword ptr[esi]

pmulld xmm0, xmm5


pop ebp
ret
_mul_at_once ENDP
END
