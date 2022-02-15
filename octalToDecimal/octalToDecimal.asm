.686
.model flat
extern __write : PROC
extern __read : PROC

extern _ExitProcess@4 : PROC
public _main
.data
znaki db 12 dup (?)
czy_ujemna db 0
mnoze db 0
dziele db 0
dzielnik dd ?
ile_po_przecinku db 0
liczba dd 0
.code

wyswietl_eax PROC

pusha
mov esi, 10 ; indeks w tablicy 'znaki'
mov ebx, 10 ; dzielnik równy 10

cmp ile_po_przecinku, 0
je konwersja
sprawdz:

sprawdz2:
shl ecx, 4
shr cl,4 
mov znaki[esi], cl
add znaki[esi], 30h
dec esi
mov cl, 0
shr ecx, 8
cmp ecx, 0
jne sprawdz2
mov znaki[esi], '.'
dec esi

konwersja:
xor edx, edx ; zerowanie starszej części dzielnej
div ebx ; dzielenie przez 10, reszta w EDX,
; iloraz w EAX
add dl, 30H ; zamiana reszty z dzielenia na kod
; ASCII
mov znaki [esi], dl; zapisanie cyfry w kodzie ASCII
dec esi ; zmniejszenie indeksu
cmp eax, 0 ; sprawdzenie czy iloraz = 0
jne konwersja ; skok, gdy iloraz niezerowy
; wypełnienie pozostałych bajtów spacjami i wpisanie
; znaków nowego wiersza
wypeln:
or esi, esi
jz wyswietl ; skok, gdy ESI = 0
mov byte PTR znaki [esi], 20H ; kod spacji
dec esi ; zmniejszenie indeksu
jmp wypeln
wyswietl:

cmp czy_ujemna, 1
jne dalej
mov byte PTR znaki[4], '-'

dalej:

mov byte PTR znaki [0], 0AH ; kod nowego wiersza
mov byte PTR znaki [11], 0AH ; kod nowego wiersza
; wyświetlenie cyfr na ekranie
push dword PTR 12 ; liczba wyświetlanych znaków
push dword PTR OFFSET znaki ; adres wyśw. obszaru
push dword PTR 1; numer urządzenia (ekran ma numer 1)
call __write ; wyświetlenie liczby na ekranie
add esp, 12 ; usunięcie parametrów ze stosu
popa 
ret

wyswietl_eax ENDP

wczytaj_do_eax_hex PROC
; wczytywanie liczby szesnastkowej z klawiatury – liczba po
; konwersji na postać binarną zostaje wpisana do rejestru EAX
; po wprowadzeniu ostatniej cyfry należy nacisnąć klawisz
; Enter
push ebx
push edx
push esi
push edi
push ebp
; rezerwacja 12 bajtów na stosie przeznaczonych na tymczasowe
; przechowanie cyfr szesnastkowych wyświetlanej liczby
sub esp, 12 ; rezerwacja poprzez zmniejszenie ESP
mov esi, esp ; adres zarezerwowanego obszaru pamięci
push dword PTR 10 ; max ilość znaków wczytyw. liczby
push esi ; adres obszaru pamięci
push dword PTR 0; numer urządzenia (0 dla klawiatury)
call __read ; odczytywanie znaków z klawiatury
; (dwa znaki podkreślenia przed read)
add esp, 12 ; usunięcie parametrów ze stosu
mov eax, 0 ; dotychczas uzyskany wynik
pocz_konw:
mov dl, [esi] ; pobranie kolejnego bajtu
inc esi ; inkrementacja indeksu
cmp dl, 10 ; sprawdzenie czy naciśnięto Enter
je gotowe ; skok do końca podprogramu

cmp dl, '*'
je mnozenie
cmp dl, '/'
je dzielenie
cmp dl, '-'
je minus

; sprawdzenie czy wprowadzony znak jest cyfrą 0, 1, 2 , ..., 9
cmp dl, '0'
jb pocz_konw ; inny znak jest ignorowany
cmp dl, '7'
ja sprawdzaj_dalej
sub dl, '0' ; zamiana kodu ASCII na wartość cyfry
dopisz:
shl eax, 3 ; przesunięcie logiczne w lewo o 4 bity
or al, dl ; dopisanie utworzonego kodu 4-bitowego
jmp pocz_konw


mnozenie:
mov ebx, eax
xor eax, eax
mov mnoze, 1
jmp pocz_konw

dzielenie:
mov ebx, eax
xor eax, eax
mov dziele, 1
jmp pocz_konw
minus:
inc czy_ujemna
 ; na 4 ostatnie bity rejestru EAX
jmp pocz_konw ; skok na początek pętli konwersji
; sprawdzenie czy wprowadzony znak jest cyfrą A, B, ..., F
sprawdzaj_dalej:

jmp dopisz
gotowe:
; zwolnienie zarezerwowanego obszaru pamięci
cmp mnoze, 1
je mnozonko
cmp dziele, 1
je dzielonko

mnozonko:
mul ebx
jmp koniec
dzielonko:

mov esi, eax

xor ecx, ecx
dzielonkoo:

mov dzielnik, eax
mov eax, ebx
mov ebx, dzielnik
xor edx, edx
div esi
mov ebx, eax 
cmp ile_po_przecinku, 0
jne pomin
mov liczba, eax


pomin:
cmp edx, 0
je koniec
mov eax, 10
mul edx
div esi
shl ecx, 4
add ecx, eax
inc ile_po_przecinku

cmp ile_po_przecinku, 5
ja koniec

jmp dzielonkoo

koniec:
cmp liczba, 0
je idz
mov eax, liczba
idz:
add esp, 12
pop ebp
pop edi
pop esi
pop edx
pop ebx
ret
wczytaj_do_eax_hex ENDP

_main PROC

call wczytaj_do_eax_hex
call wyswietl_eax

push 0
call _ExitProcess@4
_main ENDP
END
