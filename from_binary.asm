	.data
	.align 0
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"
	.text
	.globl bin_to_dec
	.globl bin_to_hexa

	
#comeco da funcao que converte binario para decimal e da funcao que converte binario para hexadecimal
#Parametros
# --->  $t2  : endereco do inicio do espaco alocado (acum_c)
# ---> $t9  :   base de saida


#Binario -> Decimal
bin_to_dec: 
	lb $s1, 0 ($t2) 				# $s1 recebe o valor da posicao da string que $t2 aponta ($s1 recebe o byte)
	li $t6, 0 						#acumula o valor decimal - os bits serao inseridos nele um por um 
	li $t4, 0 						# contador do numero de digitos do valor colocado

#loop que valida o valor de entrada e adiciona bit a bit no registrador que guarda o resultado em inteiro	
	loop_one:
		beq $t4, 33, invalid	#se o contador $t4 chegar em 32, que eh o tamanho maximo de digitos suportado em binario, a entrada eh invalida 
		beq $s1, $zero,  end_loop_one 	#se o conteudo do elemento da string de bits for igual a '\0', acaba o loop 
		beq $s1, 10, end_loop_one 		# se o conteudo do elemento da string de bits for igual a '\n', acaba o loop
		sll $t6, $t6, 1					#desloca o valor dentro de $t6 1 bit para a esquerda 
								#inicialmente $t6 tem 0, o primeiro deslocamento ainda deixa o valor em 0.
	
		check_bin:
			beq $s1, '0', transfer 			#checa se o byte colocado em $s1 representa o caractere '0', caso positivo vai para a funcao transfer
			beq $s1, '1', transfer_one 		#checa se o byte colocado em $s1 representa o caractere ' 1', caso positivo vai para a funcao transfer_one
			j invalid					# caso no byte tiver uma valor que nao representa nem 0 e nem 1, entao o numero colocado eh invalido

			transfer_one: 					#em transfer_one o  1eh adicionado ao bit menos significativo de $t6
				addi $t6, $t6, 1
			transfer:						#se  transfer for chamado diretamente  o bit menos significativo de $t6 continua 0
				addi $t2, $t2, 1			#vai ao proximo byte do valor de entrada contido no espaço alocado
				lb $s1, 0($t2) 			#coloca o valor do byte em $s1
				addi $t4, $t4, 1  			#aumenta o contador de +1 digito
				j loop_one				#volta ao loop_one


									
	#Valor de entrada invalido
	invalid:
		#imprime a string que diz a invalidade do numero colocado
		li $v0, 4
		la $a0, again
		syscall
	
		li $t6, 0
		
		#volta para o numero para a funcao que eh o numero em binario
		j num_bin 

	end_loop_one: # Fim bin_to_dec
	
		beq $t9, 10, print_output_dec 		#verifica se a base de saidaeh realmente decimal
		jr $ra							#caso nao seja, ele volta para funcao que chamou 'bin_to_dec' como procedimento
									#que no caso foi 'bin_to_hexa'


#Binario -> Hexadecimal
bin_to_hexa:
	jal bin_to_dec 					#chama bin_to_dec para cconverter binario para decimal
	move $t2, $t6						#passa o valor decimal de $t6 para $t2, dessa forma o parametros de' dec_to_hexa' ficam certos
	j dec_to_hexa						# processamento vai para 'dec_to_hexa', para converter decimal para hexadecimal 
									#de la  retornar para a arquivo main na funcao 'print_output_bin_hexa'
	
	

	
	
