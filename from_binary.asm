	.data
	.align 0
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"
	.text
	.globl bin_to_dec
	.globl bin_to_hexa

	
#começo da função que converte binario para decimal e da função que converte binario para hexadecimal
#Parâmetros
# --->  $t2  : endereço do inicio do espaço alocado (acum_c)
# ---> $t9  :   base de saida


#Binario -> Decimal
bin_to_dec: 
	lb $s1, 0 ($t2) 				# $s1 recebe o valor da posição da string que $t2 aponta ($s1 recebe o byte)
	li $t6, 0 						#acumula o valor decimal - os bits serão inseridos nele um por um 
	li $t4, 0 						# contador do número de digitos do valor colocado

#loop que valida o valor de entrada e adiciona bit a bit no registrador que guarda o resultado em inteiro	
loop_one:
	beq $t4, 32, end_loop_one		#se o contador $t4 chegar em 32, que é o tamanho máximo de digitos suportado em binario, a entrada é invalida 
	beq $s1, $zero,  end_loop_one 	#se o conteudo do elemento da string de bits for igual a '\0', acaba o loop 
	beq $s1, 10, end_loop_one 		# se o conteudo do elemento da string de bits for igual a '\n', acaba o loop
	sll $t6, $t6, 1					#desloca o valor dentro de $t6 1 bit para a esquerda 
								#inicialmente $t6 tem 0, o primeiro deslocamento ainda deixa o valor em 0.
	
check_bin:
	beq $s1, '0', transfer 			#checa se o byte colocado em $s1 representa o caractere '0', caso positivo vai para a função transfer
	beq $s1, '1', transfer_one 		#checa se o byte colocado em $s1 representa o caractere ' 1', caso positivo vai para a função transfer_one
	j invalid					# caso no byte tiver uma valor que não representa nem 0 e nem 1, então o número colocado é inválido

#Valor de entrada invalido
invalid:
	

	#imprime a string que diz a invalidade do número colocado
	li $v0, 4
	la $a0, again
	syscall
	
	li $t6, 0
	
	
	#volta para o número função que lê o número em binario
	j num_bin 
	
transfer_one: 					#em transfer_one o  1 é adicionado ao bit menos significativo de $t6
	addi $t6, $t6, 1
transfer:						#se  transfer for chamado diretamente  o bit menos significativo de $t6 continua 0
	addi $t2, $t2, 1			#vai ao próximo byte do valor de entrada contido no espaço alocado
	lb $s1, 0($t2) 			#coloca o valor do byte em $s1
	addi $t4, $t4, 1  			#aumenta o contador de +1 digito
	j loop_one				#volta ao loop_one
	
end_loop_one: # Fim bin_to_dec
	
	beq $t9, 10, print_output_dec 		#verifica se a base de saida é realmente decimal
	jr $ra							#caso não seja, ele volta para função que chamou 'bin_to_dec' como procedimento
									#que no caso foi 'bin_to_hexa'

#Binario -> Hexadecimal
bin_to_hexa:
	jal bin_to_dec 					#chama bin_to_dec para cconverter binario para decimal
	move $t2, $t6						#passa o valor decimal de $t6 para $t2, dessa forma o parâmetros de' dec_to_hexa' ficam certos
	j dec_to_hexa						# processamento vai para 'dec_to_hexa', para converter decimal para hexadecimal 
									#de lá  retornar para a arquivo main na função 'print_output_bin_hexa'
	
	

	
	
