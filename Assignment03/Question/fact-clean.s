    .data    #insert
	.globl	p
arr: 
    .space  40	#replace .comm at the bottom by this
p:
	.word	arr
$LC0:
	.asciiz	"The factorial of 5 is:"
	.text
	.globl	main
	.ent	main

main:
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	li	$2,5			
	sw	$2,28($fp)
	li	$2,1			
	sw	$2,24($fp)
	b	$L2
	nop

$L3:
	lw	$3,24($fp)
	lw	$2,28($fp)
	nop
	mult	$3,$2
	mflo	$2
	sw	$2,24($fp)
	lw	$2,28($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,28($fp)
$L2:
	lw	$2,28($fp)
	nop
	bgtz	$2,$L3
	nop
   ##################################
   #Syscall code
	la      $4,  $LC0
	li      $2,  4
        syscall
	lw      $4,  24($fp)
        li      $2,  1
	syscall
   ####################################
	nop
	lw	$28,16($fp)
	move	$2,$0
	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	addiu	$sp,$sp,40
	j	$31
	nop
	.end	main
