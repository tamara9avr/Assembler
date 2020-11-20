! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije


org x.4000

!Inicijalizacija IV tabele

ldimm x.300, r0
mvrir r0, ivtp

ldimm x.2000, r0
stmem x.300, r0

ldimm x.1500, r0
stmem x.301, r0

ldimm x.2500, r0
stmem x.302, r0

ldimm x.500, r0
stmem x.303, r0

ldimm x.1000, r0
stmem x.304, r0

ldimm x.3000, r0
stmem x.305, r0

!Kraj inicijalizacije IVT

!Prenos podataka sa periferija u memoriju

ldimm x.3, r0
stmem x.f102,r0	!Dodeljuje broj ulaza u ivt za KP1.1

ldimm x.1, r0
stmem x.f202, r0	!Dodeljuje broj ulaza u ivt za KP2.1

ldimm x.9, r0	!brojac za PER1
ldimm x.9, r1	!brojac za PER2

ldimm x.5000, r2	!Adersa za smestanje niza A
ldimm x.6000, r3	!Adresa za smestanje niza B

clr r4	!semafor za PER1
clr r5	!semafor za PER2

ldimm x.f, r6
stmem x.f100, r6	!Startovanje KP1.1

ldimm x.f, r6
stmem x.f200, r6	!Startovanje KP2.1

!Cekamo da se zavrsi proces prenosa sa KP1.1

ldimm x.1, rf
Wait0: and r4,r4,rf	!Provera da li je semafor1 jednak 0
       beql Wait0

!Cekamo da se zavrsi proces prenosa sa KP2.1

ldimm x.1,rf
Wait1: and r5,r5,rf		!Provera da li je semafor2 jednak 0
       beql Wait1

!Priprema za prenos na KP1.2

ldimm x.5000, r0	!Adresa niza A
ldimm x.9, r1	!Brojac

clr r2		!Semafor

ldimm x.4, r3	!Broj ulaza za ivt
stmem x.f142, r3	!Upisuje broj ulaza u entry

ldimm x.e, r4
stmem x.f140, r4	!Pokrece KP1.2 u rezimu prekida sa izlazom

!Cekamo da se zavrsi proces prenosa na KP1.2

ldimm x.1,rf
WaitOUT: and r2,r2,rf
	beql WaitOUT

!Pozivanje potprograma

ldimm x.5000, r0
ldimm x.6000, r1
ldimm x.8, r2

push r2
push r1
push r0

jsr xorArr

pop r0
pop r0
pop r0


ldmem x.5000, r0
stmem x.9999,r0

!Prenos nultog elementa niza A preko DMA1.4

ldimm x.8, r0
stmem x.f0c4, r0	!Count

ldimm x.5, r0
stmem x.f0c2, r0	!Ulas u ivt

ldimm x.5100, r0
stmem x.f0c6, r0	!Destination addr

ldimm x.5000, r0
stmem x.f0c5, r0	!Source addr

ldimm x.9e, r0
stmem x.f0c0,r0	!Control 

clr r1		!Semafor

ldimm x.1, r2
WaitMem: and r1,r1,r2
	beql WaitMem


!Priprema za prenos podatka u DMA1.2

ldimm x.2, r0
stmem x.f042, r0	!Broj ulaza u ivt

ldimm x.1, r0
stmem x.f044, r0	!Upis u count registar

ldimm x.9999, r1	!Adresa podatka
stmem x.f045, r1	!Izvorisni adresni registar AR1

clr r2		!Semafor

ldimm x.ae, r3
stmem x.f040, r3	!Pokrece DMA1.2


ldimm x.1, r4
WaitDMA: and r2,r2,r4
	beql WaitDMA


halt
!---------------------------------------------------------------------------------!

!Potprogram
xorArr:

mvrpl r0, sp
!SP = retPC, array1, array2, size
ldrid [r0]x.1,ra	!niz A
ldrid [r0]x.2,rb	!niz B
ldrid [r0]x.3,rc	!counter

loop:	ldrid [ra]x.0,r1
	ldrid [rb]x.0,r2
	xor r1,r1,r2
	stri [ra],r1
	inc ra
	inc rb
	dec rc
	bneq loop

rts

!Kraj potprograma

!Prekidna rutina DMA1.4
org x.3000
ldimm x.1,r1
clr r5
stmem x.f0c0, r5
rti
!Kraj

!Prekidna rutina KP1.1
org x.500
dec r0
bneq Per1 
clr r0
stmem x.f100,r0
ldimm x.1, r4
jmp Back1

Per1:  	ldmem x.f103,r8
      	stri [r2],r8
	inc r2

Back1: 	rti
!Kraj


!Prekidna rutina za KP2.1

org x.1500

dec r1
bneq Per2
stmem x.f200,r1
ldimm x.1, r5
jmp Back2

Per2:  	ldmem x.f203,r9
      	stri [r3],r9
	inc r3

Back2: 	rti
!Kraj

!Prekidna rutina za KP1.2

org x.1000
dec r1
bneq PerOUT
stmem x.f140, r1
ldimm x.1, r2
jmp BackOut

PerOUT:	ldrid [r0]x.0,r5
	stmem x.f143,r5
	inc r0

BackOut: rti
!Kraj

!Prekidna rutina za DMA1.2
org x.2500
ldimm x.1,r2
clr r5
stmem x.f040, r5
rti
!Kraj
