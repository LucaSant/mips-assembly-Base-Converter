	.data
	.align 0

str_output_base_error: .asciiz "\nBase de saida incorreta, coloque valores validos (2, 10 ou 16)... \n"
input_num_dec:	.asciiz "\nColoque um numero na base decimal ( ate +-  2147483647): "
input_num_hexa:	.asciiz "\n Coloque um numero na base hexadecimal (0123456789ABCDEF em ate 8 digitos): "
input_num_bin:	.asciiz "\n Coloque um numero na base binaria (ate 32 digitos): "
equal_base:        	.asciiz "\n As duas bases inseridas sao iguais!\n"
	.text
	.globl num_bin
	.globl num_hexa
	.globl num_dec
	
	
	
num_bin:
#inserir o numero de entrada
	li $v0, 4
	la $a0, input_num_bin
	syscall 

	
	li $v0, 8			#para binario a entrada deve ser uma string 
	la $a0, ($t8)		#$a0 guarda o endereco onde a string vai ser inserida
	la $t2, ($a0)		#movemos para $t2 utilizar em outra funcoes
	syscall

	jal  output_base	#chama funcao para ler a base de saida
	move $t9, $v0		#na volta a base estao em $v0, passamor para $t9 
	
	#a partir da base de saida definmos qual conversao sera realizada
	beq $t9, 10, bin_to_dec	
	beq  $t9, 16, bin_to_hexa
	
#caso a base nao seja nem 10 e 16, que sao bases diferentes da atual, nao havera conversao
noconversion_bin:

	bne $t9 ,2,  output_base_error	#se a base de saida tambem nao for binaria, estao eh invalida

#se for binaria, temos apenas que conferir se o valor digitado eh valido
	jal bin_to_dec					#chamamos a funcao para converter para decimal

	li $v0, 4						#se chamada volta da funcao, estao eh valida
	la $a0, equal_base				#vamos imprimir que as bases sao iguais
	syscall
	
	move $t2, $t6					#move valores de registradores pois a saida de bin_to_dec e a entrada de dec_to_bin estao em registradores diferente
	
	j dec_to_bin					# converte de volta para depois imprimir 
	
	
num_hexa:
#a operacao de num_hexa eh muito semelhante ao num_bin
	li $v0, 4
	la $a0, input_num_hexa
	syscall

	li $v0, 8
	la $a0, ($t8)
	la $t2, ($a0)
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
	
	li $v0, 4			#a entrada na base decimal eh um inteiro
	la $a0, input_num_dec
	syscall

	li $v0, 8
	la $a0, ($t8)
	la $t2, ($a0)
	syscall

	jal output_base        #chama a funcao responsavel por ler a base de saida
	move $t9, $v0         # move o valor da base para o registrador $a3
	
	jal char_to_int	#chama a funcao para pegar os caracteres e transformar em inteiros
 	
	#vai para funcao de conversao especifica
	beq $t9, 2, dec_to_bin   
	beq $t9, 16, dec_to_hexa
	
	#se a base de saida digitado nao eh 2 nem 16 ....
noconversio_dec:

	bne $t9, 10,  output_base_error   	# se a base de entrada e saida nao sao iguais, estao a base de saida eh invalida
	
	li $v0, 4
	la $a0, equal_base
	syscall
	
	move $t6, $t2						#se nao eh invalido, muda o valor de registrador para  que seja impresso por print_output_dec
	j print_output_dec

 output_base_error:						#quando a base de saida eh invalida, imprime o fato e pede para entrar com um novo valor

	li $v0, 4
	la $a0, str_output_base_error
	syscall
	j output_base
	
