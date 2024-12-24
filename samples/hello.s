.globl	_main
.text
_main:
mov r5,-(sp); mov sp,r5
.data;L1:.byte 110,145,154,154,157,40,127,157,162,154,144,41,12,0;.even;.text
mov	$L1,-(sp)
jsr	pc,_printf
tst	(sp)+
jmp	retrn
