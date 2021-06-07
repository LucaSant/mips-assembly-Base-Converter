
	.data
	.align 0
str_input_base: .asciiz  "\n Coloque a base de entrada: "   
str_output_base: .asciiz "\n Coloque a base de saida: "
str_result:   .asciiz "\n O resultado: "
str_input_base_error:  .asciiz "\nBase de entrada  incorreta, coloque valores v�lidos (2, 10 ou 16)... \n"
hexa_values: .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G'
acum_c:     .space 33
end_acum:

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
	
	#l� um valor inteiro, sendo esse a base de entrada
	li $v0, 5
	syscall
	move $t0, $v0   
	
	#salva em registradores os endere�os alguns dados
	la $t8, acum_c 		#o come�o do espa�o alocado 
	la $a2 , end_acum		#o fim do espa�o alocado
	la $a3, hexa_values	#a string com os valores hexadecimais em ordem (0 a F)
		
	#A partir da base de entrada, o n�mero a ser convertido ser� de tipos diferentes e seguiram caminhos de processamento distintos
	#Decimal : int 
	#Hexadecimal e binario: string
	
	#para binario
	li $s6, 2
	li $a1, 33 				#numero m�ximo de bytes a ser lido do n�mero de entrada  ( ser� melhor explicado no decorrer do c�digo)
	beq $s6, $t0, num_bin  		#se a base colocado for 2, vai para num_bin
	
	#para decimal 
	li $s6, 10				
	beq $s6, $t0, num_dec		#se a base colocada for 10, vai para num_dec
	
	#para hexadecimal
	li $s6, 16
	la $a1, 9					#numero m�ximo de bytes a ser lido no n�mero de entrada (...)
	beq $s6, $t0, num_hexa		#se a base colocada for 16, vai para num_hexa
	
#se a base de entrada inserida pelo usuario n�o for nem 2, 10 ou 16 ...
#imprime uma mensagem de base inv�lida
	li $v0, 4					
	la $a0, str_input_base_error
	syscall
	j main 					#volta para o inicio

output_base:
	
	#imprime frase pedido a base de sa�da
	li $v0, 4 
	la $a0,  str_output_base
	syscall
	
	#l� a base de sa�da
	li $v0, 5
	syscall
	
	# a fun��o output_base � chamada dentro de num_bin, num_dec ou num_hexa, ent�o com 'jr $ra' ele retorna para elas 
	jr $ra #volta 
		

# Fun��es para fazer o print do resultado

#Fun��o para imprimir decimal
print_output_dec:
	
	#imprime string indicando que o resultado vem logo depois 
	li $v0, 4
	la $a0, str_result
	syscall
	
	#imprime o inteiro de sa�da (que est� em $t6)
	li $v0, 1
	la $a0, ($t6)
	syscall
	j end

#Fun��o para imprimir decimal e binario
print_output_bin_hexa:
	
	#imprime string indicando que o resultado vem logo depois
	li $v0, 4
	la $a0, str_result
	syscall
	
	#imprime a string no endere�o indicado por $a2
	li $v0, 4
    	la $a0, ($a2)
    	syscall
    	
end:
	li $v0, 10 	# Fim do programa
	syscall
