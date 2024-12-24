.globl	_main
.text
_main:
mov r5,-(sp); mov sp,r5
add	$-6,sp
movb	$103,-6.(r5)
mov	$173,2.+-6.(r5)
.data;L1:.byte 164,145,163,164,0;.even;.text
mov	$L1,4.+-6.(r5)
.data;L2:.byte 170,40,75,40,47,45,143,47,54,40,171,40,75,40,45,144,54,40,172,40,75,40,42,45,163,42,12,0;.even;.text
mov	4.+-6.(r5),-(sp)
mov	2.+-6.(r5),-(sp)
movb	-6.(r5),r0
mov	r0,-(sp)
mov	$L2,-(sp)
jsr	pc,_printf
add	$10,sp
jmp	retrn
