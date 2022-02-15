.686
.model flat
extern _ExitProcess@4 : PROC
public _main
.data

suma_kontrolna db ? ; miejsce na przechowanie sumy kontrolnej
znaki db 1,1,1,5   ;0
dw 0
db 1,1,2,4 ;1
dw 15
db 1,1,3,3 ;2
dw 17
db 1,1,4,2 ;3
dw 29
db 1,1,5,1 ;4
dw 11
db 1,2,1,4 ;5
dw 33
db 1,2,2,3 ; 6
dw 19
db 1,2,3,2 ;7
dw 21
db 1,2,4,1  ;8
dw 8
db 1,3,1,3 ;9
dw 2
db 1,3,2,2 ;A
dw 7
db 1,3,3,1  ;B
dw 25
db 1,4,1,2 ;C
dw 20
db 1,4,2,1 ;D
dw 22
db 1,5,1,1 ;E
dw 9
db 2,1,1,4 ;F
dw 30
db 2,1,2,3 ;G
dw 3
db 2,1,3,2 ;H
dw 6
db 2,1,4,1 ;I
dw 27
db 2,2,1,3 ;J
dw 16
db 2,2,2,2 ;K
dw 24
db 2,2,3,1 ;L
dw 4
db 2,3,1,2 ;M
dw 34
db 2,3,2,1 ;N
dw 12
db 2,4,1,1 ;P
dw 32
db 3,1,1,3 ;Q
dw 18
db 3,1,2,2 ;R
dw 1
db 3,1,2,2 ;S
dw 14
db 3,2,1,2 ;T
dw 13
db 3,2,2,1 ;U
dw 26
db 3,3,1,1 ;V
dw 5
db 4,1,1,2 ;W
dw 31
db 4,1,2,1 ;X
dw 28
db 4,2,1,1 ;Y
dw 23
db 5,1,1,1 ;Z
dw 10

lancuch db 'Z', 'B', 'G', 'K', 'A', 'B', 'P', 'R' 
bufor dw 8 dup (?)


.code
_main PROC

mov esi, offset lancuch ;adres obszaru z tekstem do zakodowania
mov edi, offset bufor ;adres na kody w BC412
mov ecx, 8 ; liczba znakow w buforze do zakodowania
mov suma_kontrolna, 0 ;inicjalna suma kontrolna ustawiona na 0

nastepny_znak:
mov ebx, 8
sub ebx, ecx  ; To bedzie nasz indeks do pobrania znaku
xor eax, eax  
mov al, byte ptr [esi+ebx] ; wkładam do AL pobrany znak
mov ebx, offset znaki ; Bedziemy musieli pobrac 4 liczby odpowiadajace naszemu znakowi


; Aby móc pobrać 4 liczby dla naszego znaku bedziemy musieli sie przesunac w tablicy znaki o 6*X bajtów, np. dla znaku '2'
; przesuniemy się o 6*2 = 12 bajtów itp. Ponieważ mamy 3 segmenty znaków (pomieważ między 9, a A w ASCII są jeszcze inne znaki, tak samo
; miedzy N i P znajduje się znak O), musimy podzielić na 3 przypadki, by uzyskać prawidłowy indeks w tablicy znaki.


cmp al, 9 ; sprawdzamy czy nasz znak jest cyfrą (0-9)
jle liczba
cmp al, 80 ; sprawdzamy czy nasz znak jest literą przed P (A-N)
jl litera_przed_p

jmp litera_po_p ; litera P-Z

liczba:
sub al, 30h ; otrzymamy indeks 0-9
jmp idz

litera_przed_p:
sub al, 41h ; otrzymamy indeks 10-23
jmp idz

litera_po_p:
sub al, 56 ; otrzymamy indeks 24-34
jmp idz


idz:
mov edx, 6 ; tyle bajtów w tablicy znaki dzieli jeden element od drugiego (4*db+1*dw)
mul edx  ; mnożymy nasz indeks przez 6 i otrzymujemy właściwe przesunięcie
add ebx, eax  ; przesuwamy odpowiednio ebx, który zawiera offset tablicy znaki
xor edx, edx ; w edx przechowamy czwórkę cyfr odpowiadającą naszemu znakowi

; 1) wrzuc do dl pierwszą liczbę
; 2) przesun edx o 2 bajty
; 3) przesun indeks o 1 bajt
; 4) powtorz 3 razy

mov dl, byte ptr [ebx] 
shl edx, 8
inc ebx
mov dl, byte ptr [ebx]
shl edx, 8
inc ebx
mov dl, byte ptr [ebx]
shl edx, 8
inc ebx
mov dl, byte ptr [ebx]


; SUMA KONTROLNA
inc ebx ;indeks wartosci do sumy kontrolnej
mov bx, word ptr [ebx] 
add suma_kontrolna, bl



jmp dalej
dalej:

mov eax, 0 ; indeks rejestru ebx, 
xor ebx, ebx 

; ustawiamy bity od prawej, czyli jak mamy np. 1,1,1,5 to najpierw ustawiamy 5 zer i jedynkę

dalej2:
btr ebx,eax ; ustawiamy 0
dec dl 
cmp dl, 0
jne dokoncz

przesun: ; jak w dl mamy 0, to ustawiamy bit na jedynke, a nastepnie zajmujemy sie nastepna cyfra po lewej
shr edx, 8 ; przesuwamy edx, by w dl miec kolejna cyfre
inc eax
bts ebx, eax ; ustawiamy 1
jmp dokoncz
dokoncz:
inc eax
cmp eax, 12 ; ustawiamy 12 bitow, 4 najstarsze są zerami
jl dalej2
mov word ptr [edi], bx ; wrzucamy do bufora otrzymany wynik
add edi, 2 ; przesuwamy indeks w tablicy bufor 2 bajty


loop nastepny_znak

; dzielimy sume wartosci przez 35 by otrzymac sume kontrolna

mov al, suma_kontrolna
mov bl, 35
div bl ; wynik w al, reszta w ah, interesuje nas ah
mov byte ptr suma_kontrolna, ah



 push 0
 call _ExitProcess@4 ; zakończenie programu
_main ENDP
END
