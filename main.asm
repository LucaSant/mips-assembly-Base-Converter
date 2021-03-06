# ... Lucas H. Sant'Anna

	.data
	.align 0
str_input_base: .asciiz  "\n Coloque a base de entrada: "   
str_output_base: .asciiz "\n Coloque a base de saida: "
str_result:   .asciiz "\n O resultado: "
str_input_base_error:  .asciiz "\nBase de entrada  incorreta, coloque valores validos (2, 10 ou 16)... \n"
hexa_values: .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G'
acum_c:     .space 50
end_acum: .asciiz "\0"

	.text 
	.globl main 
	.globl print_output_dec
	.globl output_base
	.globl print_output_bin_hexa

main:
	#imprime a string pedindo a base de entrada
	li $v0, 4
	la $a0, str_input_base
	syscall
	
	#le um valor inteiro, sendo esse a base de entrada
	li $v0, 5
	syscall
	move $t0, $v0   
	
	#salva em registradores os enderecos alguns dados
	la $t8, acum_c 		#o comeco do espaco alocado 
	la $a2 , end_acum		#o fim do espaco alocado
	la $a3, hexa_values	#a string com os valores hexadecimais em ordem (0 a F)
		
	#A partir da base de entrada, o numero a ser convertido sera de tipos diferentes e seguiram caminhos de processamento distintos
	#Decimal : int 
	#Hexadecimal e binario: string
	
	#para binario
	li $a1, 50 				#numero maximo de bytes a ser lido do numero de entrada  ( sera melhor explicado no decorrer do c�digo)
	beq $t0, 2, num_bin  		#se a base colocado for 2, vai para num_bin

	#para decimal
	li $a1, 50 			
	beq $t0, 10, num_dec		#se a base colocada for 10, vai para num_dec
	
	#para hexadecimal
	la $a1, 50					#numero maximo de bytes a ser lido no numero de entrada (...)
	beq $t0, 16, num_hexa		#se a base colocada for 16, vai para num_hexa
	
#se a base de entrada inserida pelo usuario nao for nem 2, 10 ou 16 ...
#imprime uma mensagem de base invalida
	li $v0, 4					
	la $a0, str_input_base_error
	syscall
	j main 					#volta para o inicio

output_base:
	
	#imprime frase pedido a base de saida
	li $v0, 4 
	la $a0,  str_output_base
	syscall
	
	
	#le a base de saida
	li $v0, 5
	syscall
	
	move $t9, $v0
	
	# a funcao output_base eh chamada dentro de num_bin, num_dec ou num_hexa, estao com 'jr $ra' ele retorna para elas 
	jr $ra #volta 
		

# Funcoes para fazer o print do resultado

#Funcao para imprimir decimal
print_output_dec:
	
	#imprime string indicando que o resultado vem logo depois 
	li $v0, 4
	la $a0, str_result
	syscall
	
	#imprime o inteiro de saida (que estao em $t6)
	li $v0, 36
	la $a0, ($t6)
	syscall
	j end

#Funcao para imprimir decimal e binario
print_output_bin_hexa:
	
	#imprime string indicando que o resultado vem logo depois
	li $v0, 4
	la $a0, str_result
	syscall
	
	#imprime a string no endereco indicado por $a2
	li $v0, 4
    	la $a0, ($a2)
    	syscall
    	
end:
	li $v0, 10 	# Fim do programa
	syscall
