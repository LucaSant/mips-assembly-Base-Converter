	.data
	.align 0
str_output_base_error: .asciiz "\nBase de sa�da incorreta, coloque valores v�lidos (2, 10 ou 16)... \n"
input_num_dec:	.asciiz "\nColoque um numero na base decimal ( at� +-  2147483647): "
input_num_hexa:	.asciiz "\n Coloque um numero na base hexadecimal (0123456789ABCDEF em at� 8 digitos): "
input_num_bin:	.asciiz "\n Coloque um numero na base binaria (at� 32 digitos): "
equal_base:        	.asciiz "\n As duas bases inseridas s�o iguais!\n""
	.text
	.globl num_bin
	.globl num_hexa
	.globl num_dec
	
	
num_bin:
#inserir o n�mero de entrada
	li $v0, 4
	la $a0, input_num_bin
	syscall 

	
	li $v0, 8			#para binario a entrada deve ser uma string 
	la $a0, ($t8)		#$a0 guarda o endere�o onde a string vai ser inserida
	la $t2, ($a0)		#movemos para $t2 utilizar em outra fun��es
	syscall

	jal  output_base	#chama fun��o para ler a base de sa�da
	move $t9, $v0		#na volta a base est� em $v0, passamor para $t9 
	
	#a partir da base de sa�da definmos qual convers�o ser� realizada
	beq $t9, 10, bin_to_dec	
	beq  $t9, 16, bin_to_hexa
	
#caso a base n�o seja nem 10 e 16, que s�o bases diferentes da atual, n�o haver� convers�o
noconversion_bin:	
	bne $t9, 2,  output_base_error	#se a base de sa�da tamb�m n�o for binaria, ent�o � inv�lida

#se for bin�ria, temos apenas que conferir se o valor digitado � v�lido
	jal bin_to_dec					#chamamos a fun��o para converter para decimal

	li $v0, 4						#se chamada volta da fun��o, ent�o � v�lida
	la $a0, equal_base				#vamos imprimir que as bases s�o iguais
	syscall
	
	move $t2, $t6					#move valores de registradores pois a saida de bin_to_dec e a entrada de dec_to_bin est�o em registradores diferente
	
	j dec_to_bin					# converte de volta para depois imprimir 
	
	
num_hexa:
#a opera��o de num_hexa � muito semelhante ao num_bin
	li $v0, 4
	la $a0, input_num_hexa
	syscall

	li $v0, 8
	la $t2, ($t8)
	syscall
	
	
	jal  output_base
	move $t9, $v0
	

	beq $t9, 2, hexa_to_bin
	beq $t9, 10, hexa_to_dec
	
noconversion_hexa:

	bne $t9, 16,  output_base_error
	jal hexa_to_dec
	
	li $v0, 4
	la $a0, equal_base
	syscall
	
	move $t2, $t6
	
	j dec_to_hexa
	

num_dec:
	
	li $v0, 4			#a entrada na base decimal � um inteiro
	la $a0, input_num_dec
	syscall

	li $v0, 5        # L� o n�mero em decimal
	syscall
	move $t2, $v0  #o n�mero de entrada fica em $t2
	
	jal output_base        #chama a fun��o respons�vel por ler a base de sa�da
	move $t9, $v0         # move o valor da base para o registrador $a3
	
	#vai para fun��o de conver��o espec�fica 
	
	
	beq $t9, 2, dec_to_bin   
	beq $t9, 16, dec_to_hexa
	
	#se a base de sa�da digitado n�o � 2 nem 16 ....
noconversio_dec:

	bne $t9, 10,  output_base_error   	# se a base de entrada e sa�da n�o s�o iguais, ent�o a base de sa�da � inv�lida
	
	move $t6, $t2						#se n�o � inv�lido, muda o valor de registrador para  que seja impresso por print_output_dec
	j print_output_dec

 output_base_error:						#quando a base de s�ida � inv�lida, imprime o fato e pede para entrar com um novo valor

	li $v0, 4
	la $a0, str_output_base_error
	syscall
	j output_base
	
