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
#inserir o número de entrada
	li $v0, 4
	la $a0, input_num_bin
	syscall 

	
	li $v0, 8			#para binario a entrada deve ser uma string 
	la $a0, ($t8)		#$a0 guarda o endereço onde a string vai ser inserida
	la $t2, ($a0)		#movemos para $t2 utilizar em outra funções
	syscall

	jal  output_base	#chama função para ler a base de saida
	move $t9, $v0		#na volta a base estão em $v0, passamor para $t9 
	
	#a partir da base de saida definmos qual conversão será realizada
	beq $t9, 10, bin_to_dec	
	beq  $t9, 16, bin_to_hexa
	
#caso a base não seja nem 10 e 16, que são bases diferentes da atual, não haverá conversão
noconversion_bin:

	bne $t9 ,2,  output_base_error	#se a base de saida tambem não for binaria, então é inválida

#se for binaria, temos apenas que conferir se o valor digitado é válido
	jal bin_to_dec					#chamamos a função para converter para decimal

	li $v0, 4						#se chamada volta da função, então é válida
	la $a0, equal_base				#vamos imprimir que as bases são iguais
	syscall
	
	move $t2, $t6					#move valores de registradores pois a saida de bin_to_dec e a entrada de dec_to_bin estão em registradores diferente
	
	j dec_to_bin					# converte de volta para depois imprimir 
	
	
num_hexa:
#a operação de num_hexa é muito semelhante ao num_bin
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
	
	li $v0, 4			#a entrada na base decimal é um inteiro
	la $a0, input_num_dec
	syscall

	li $v0, 5        # Lê o número em decimal
	syscall
	move $t2, $v0  #o número de entrada fica em $t2
	
	jal output_base        #chama a função responsável por ler a base de saida
	move $t9, $v0         # move o valor da base para o registrador $a3
	
	#vai para função de converção específica 
	
	
	beq $t9, 2, dec_to_bin   
	beq $t9, 16, dec_to_hexa
	
	#se a base de saida digitado não é 2 nem 16 ....
noconversio_dec:

	bne $t9, 10,  output_base_error   	# se a base de entrada e saida não são iguais, então a base de saida é inválida
	
	move $t6, $t2						#se não é inválido, muda o valor de registrador para  que seja impresso por print_output_dec
	j print_output_dec

 output_base_error:						#quando a base de saida é inválida, imprime o fato e pede para entrar com um novo valor

	li $v0, 4
	la $a0, str_output_base_error
	syscall
	j output_base
	
