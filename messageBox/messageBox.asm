.686
.model flat
extern _MessageBoxW@16 : PROC
extern _ExitProcess@4 : PROC
extern __write : PROC 
extern __read : PROC 
public _main
.data
tekst_pocz db 10, 'Proszę napisać jakiś tekst '
db 'i nacisnac Enter', 10
koniec_t db ?
magazyn db 80 dup (?)
nowa_linia db 10
liczba_znakow dd ?
wyjscie db 80 dup (?)
licznik_spacji db 0
wyjscie_2 dw 80 dup(?),0
.code
_main PROC

mov esi , 0 ;licznik liter
mov edi , 0 ;licznik slow
mov ebp , 0 ;indeks dla wyjscia


 mov ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
 push ecx
 push OFFSET tekst_pocz 
 push 1 

 call __write ; wyświetlenie tekstu początkowego
 add esp, 12 ; usuniecie parametrów ze stosu

 push 80 ; maksymalna liczba znaków
 push OFFSET magazyn
 push 0 ; nr urządzenia (tu: klawiatura - nr 0)
 call __read ; czytanie znaków z klawiatury
 add esp, 12 ; usuniecie parametrów ze stosu

 mov liczba_znakow, eax

 mov ecx, eax
 mov ebx, 0 
ptl: mov dl, magazyn[ebx] 

cmp magazyn[ebx], 20h
je  spacja
cmp magazyn[ebx], 2Ch
je  kolejna
cmp magazyn[ebx], 3Bh
je kolejna
cmp magazyn[ebx],3Ah
je kolejna

inc esi

jmp kolejna

spacja:
inc licznik_spacji
cmp esi,4 
jne nie_dodawaj
inc edi
nie_dodawaj:
mov esi,0

kolejna:
cmp magazyn[ebx],20h
je indeks_nie_rosnie
mov wyjscie[ebp],dl
mov wyjscie_2[2*ebp],dx
inc ebp
indeks_nie_rosnie:
 mov magazyn[ebx], dl
dalej: inc ebx ; inkrementacja indeksu
 loop ptl 

cmp esi, 5 
jne pomin
inc edi
pomin:


mov dl, licznik_spacji
mov wyjscie[ebp], dl
add wyjscie[ebp],30h

mov eax, edi

cmp licznik_spacji, al
jb kurczak
mov wyjscie_2[2*ebp],0D83Dh
inc ebp
mov wyjscie_2[2*ebp],0DC31h
jmp kotek
kurczak:
mov wyjscie_2[2*ebp],0D83Dh
inc ebp
mov wyjscie_2[2*ebp],0DC14h

kotek:

 push liczba_znakow
 push OFFSET wyjscie
 push 1
 call __write ; wyświetlenie przekształconego
 add esp, 12 ; usuniecie parametrów ze stosu


 push 0
 push offset liczba_znakow
 push offset wyjscie_2
 push 0
 call _MessageBoxW@16

 push 0
 call _ExitProcess@4 ; zakończenie programu
_main ENDP
END
