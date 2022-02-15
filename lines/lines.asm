.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy
linia PROC
; przechowanie rejestrów
push ax
push bx
push es
push cx
push si
push dx
push di


mov ax, 0A000h ;adres pamięci ekranu
mov es, ax

mov dx, cs:sekundy 
add dx, 1
cmp dx, 5
jbe zolty
 
mov cs:kolor, 0
jmp koncz
  
jmp koncz
zolty:
mov cs:kolor, 14
cmp cs:czy_zmiana_koloru, 37
jae czerwony
jmp koncz
czerwony:
mov cs:kolor, 4

koncz:
cmp dx, 10
jne ignoruj
mov dx, 0
ignoruj:

mov bx, cs:adres_piksela ; adres bieżący piksela
mov al, cs:kolor
mov cx, 20

mov si, 0
add esi, 400+320*40
narysuj_kwadrat:
	mov es:[bx+si], al
    mov es:[bx+si+1], al
    mov es:[bx+si+2], al
	mov es:[bx+si+3], al
    mov es:[bx+si+4], al
    mov es:[bx+si+5], al
	mov es:[bx+si+6], al
    mov es:[bx+si+7], al
    mov es:[bx+si+8], al
	mov es:[bx+si+9], al
	mov es:[bx+si+10], al
	mov es:[bx+si+11], al
	mov es:[bx+si+12], al
	mov es:[bx+si+13], al
	mov es:[bx+si+14], al
	mov es:[bx+si+15], al
	mov es:[bx+si+16], al
	mov es:[bx+si+17], al
	mov es:[bx+si+18], al
	mov es:[bx+si+19], al
	add si, 320
loop narysuj_kwadrat

 
; przejście do następnego wiersza na ekranie
;add bx, 320
; sprawdzenie czy cała linia wykreślona
cmp bx, 320*200
jb dalej ; skok, gdy linia jeszcze nie wykreślona
; kreślenie linii zostało zakończone - następna linia będzie
; kreślona w innym kolorze o 10 pikseli dalej


dalej:

wysw_dalej_2:
 mov cs:sekundy,dx
mov cs:adres_piksela, bx
; odtworzenie rejestrów
pop di
pop dx
pop si
pop cx
pop es
pop bx
pop ax
; skok do oryginalnego podprogramu obsługi przerwania
; zegarowego
jmp dword PTR cs:wektor8
; zmienne procedury
kolor db 0 ; bieżący numer koloru
adres_piksela dw 10 ; bieżący adres piksela
przyrost dw 0
wektor8 dd ?
koniec db 0
sekundy dw 0
czy_zmiana_koloru dw 0
linia ENDP

zacznij:
mov ah, 0
mov al, 13H ; nr trybu
int 10H
mov bx, 0
mov es, bx ; zerowanie rejestru ES
mov eax, es:[32] ; odczytanie wektora nr 8
mov cs:wektor8, eax; zapamiętanie wektora nr 8
; adres procedury 'linia' w postaci segment:offset
mov ax, SEG linia
mov bx, OFFSET linia
cli ; zablokowanie przerwań
; zapisanie adresu procedury 'linia' do wektora nr 8
mov es:[32], bx
mov es:[32+2], ax
sti ; odblokowanie przerwań


 aktywne_oczekiwanie:
    mov ah, 1
    int 16h

  jz aktywne_oczekiwanie  

  mov ah, 0
  int 16H
  in al,60h
  cmp al, 19
  jne nic_sie_nie_dzieje

  add czy_zmiana_koloru, 1
  nic_sie_nie_dzieje:


  cmp al, 45   ; porównanie z kodem litery 'x'
  jne aktywne_oczekiwanie    ; skok, gdy inny znak



mov ah, 0 ; funkcja nr 0 ustawia tryb sterownika
mov al, 3H ; nr trybu
int 10H
; odtworzenie oryginalnej zawartości wektora nr 8
mov eax, cs:wektor8
mov es:[32], eax
; zakończenie wykonywania programu
mov ax, 4C00H
int 21H
rozkazy ENDS
stosik SEGMENT stack
db 256 dup (?)
stosik ENDS
END zacznij
