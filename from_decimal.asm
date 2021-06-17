	.data
	.align 0
	
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"

	.text
	.globl dec_to_bin
	.globl dec_to_hexa
	.globl char_to_int
	
#Parametros para as funcoes de conversao a partir da base decimal...

# ---> $a3 : endereco da string com valores hexadecimais
# ---> $a2 : endereco do fim acumulador para construcao da saida em binario ou hexadecimal
#  ---> $t2 :  numero de entrada na base decimal

dec_to_bin:

	li $s1, 32 #configura o tamanho maximo de digitos da saida na base binaria
	li $t6, 1 
	li $t4, 1 #valor para criacao da mascara para base binaria
	
	j convert


dec_to_hexa:
	
	li $s1, 8 #config tamanho maximo de digitos da saida na base hexadecimal
	li $t6, 4 
	li $t4, 4 #valor para criacao da mascara para base hexadecimal
	
	j convert

convert:
	
	#criacao da mascara para isolar a quantidade de bits desejado
	# - binario: temos o interesse de isolar um bit por vez e assim verificar se ele eh 0 ou 1
	# - hexadecimal: isolamos 1 byte por vez e assim verificamos seu valor entre 0 e 15, depois procuramos o valor correspondente na string de hexa
	
	li $s0, 1 
	sllv $s0, $s0, $t4 #$t4 pode ser 1 (um bit por vez) ou pode ser 4 (1 byte por vez)
	sub $s0, $s0, 1 #mascara criada para 1 ou 4 bit 
	#forma das mascara:
	#para 1 bit:    0000 0000 0000 0000 0000 0000 0000 0001 
	#para 4 bits:  0000 0000 0000 0000 0000 0000 0000 1111
	

	li $s2, 0 #variavel que controla o numero de bits do numero contido $t2 que serao deslocados (...) 
	#(...) para assim isolarmos apenas os desejados usando a mascara
	li $t5, 0 #contador do numero de digitos do numero de saida


	
loop:
	 
	beq $t5, $s1, endloop 			# se o numero de digitos maximo for atingido, o loop acaba
	
	srlv $t3, $t2, $s2  				# $t3 recebe o numero de entrada descolado para a direita

	and $t1, $t3, $s0  				# realiza a operacao logica E entre o numero de entrada deslocado ($t3) e a mascara ($s0)
	# $t1 tem os bits isolados
	
	add $t7, $a3, $t1				 #soma esse valor ( entre 0 e 15, ou entre 0 e 1) no endereco do inicio da string hexadecimal e (...)
								# (...)  coloca o resultado em $t7
	
	
	addi $a2, $a2, -1				 # $a2 eh fim do espaco alocado, logo ao colocar -1 vamos aumentando o espaco onde (...)
								# (...) colocaremos os digitos do valor convertido
	
	
	
	lb $a0, 0 ($t7) 			#como a mascara ja esta criada, podemos usar $t4 outra vez. Coloquemos o valor contido no endereco (...) 
							# (...) armazenado em $t7
	
	sb $a0, 0 ($a2)			# depois colocar valor no endereco armazenado em $a2, ou seja, colcoar no acumulador
							#addi $a2, $a2, -1
	
	add $s2, $s2, $t6 			#aumenta em 1 ou 4 o numero de bits que serao deslocados para direita
	addi $t5, $t5,1 			# +1 digito do numero de saida (o loop para quando for 8 (para o hexadecimal) ou 32 (para binario)
	
	j loop 
	
endloop:
	j print_output_bin_hexa 	#volta ao principal para imprimir resultado


	
invalid:					#caractere invalido, numero invalido
	#imprime pedindo que o valor seja colocado novamente, pois o atual eh invalido
	li $v0, 4				
	la $a0, again
	syscall
	j num_dec	

valid:
	add $t2, $t2, -1
	add $t0, $t0, -1
	move $s7, $t3
	li $t4, 0
	li $s5, 0
	li $s6, 4294967295
	
loop_shift:
	
	beq $s7, 0, end_loop_shift   
	sll $t5, $t1, 3
	sll $t6, $t1, 1
	add $t1, $t5, $t6
	
	
	addi $s7, $s7, -1
	j loop_shift

end_loop_shift:

	subu $s5, $s6, $t1
	bleu  $t7, $s5, isvalid
	j invalid
	
isvalid:
	addi $t3, $t3, 1
	add $t7, $t7, $t1
	j loop_three
	
	

char_to_int:

	li $t0, 0
	
loop_two:

	lb $s2, 0 ($t2)
	beq  $t0, 11, invalid
	beq $s2, $zero,  end_loop_two
	beq $s2, 10, end_loop_two
	add $t0, $t0, 1
	add $t2, $t2, 1 
	
	
	j loop_two
	
end_loop_two:

	add $t2, $t2, -1
	
	li $t3, 0 #define quantas vezes vai fazer o loop de sll
	li $s7, 0
	li $t7, 0
	
loop_three:
	beq $t0, 0, end_loop_three
	lb $s2, 0 ($t2)
	la $a1, ($a3)
	li $t1, 0
	
loop_check:
	lb $t4, 0 ($a1)		#atualiza $t0 com o valor da nova )
	beq $t4, 'A', invalid 
	beq $s2, $t4, valid
	addi $t1, $t1, 1
	addi $a1, $a1,1
	
	j loop_check


end_loop_three:
	 move $t2, $t7
	jr $ra
	