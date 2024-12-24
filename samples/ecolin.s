.globl	_main
.text
_main:
mov r5,-(sp); mov sp,r5
tst	-(sp)
L1:jsr	pc,_getchar
movb	r0,-2.(r5)
bne	l10000
jmp	l2
l10000:movb	-2.(r5),r0
mov	r0,-(sp)
jsr	pc,_putchar
tst	(sp)+
jmp	l1
L2:jmp	retrn
