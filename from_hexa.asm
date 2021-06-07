	.data
	.align 0
	
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"

	.text
	.globl hexa_to_bin
	.globl hexa_to_dec
	
#Par�metros para as fun��es de convers�o a partir da base hexadecimal...

# --->  $t2  : endere�o do inicio do espa�o alocado (acum_c)
# ---> $t9  :   base de sa�da

hexa_to_dec:
	
	li $t6, 0 # somar os valores aqui
	li $t4, 0 #conta o numero de digitos

loop:
	lb $s2, 0 ($t2)		#atualiza $s2 como o valor da nova posi��o de $t2 ( novo caractere dentro da string inserida pelo usu�rio)

	beq $t4, 8, end_loop		#se o contador $t4 chegar em 8, que � o tamanho m�ximo de digitos suportado em hexadecimal, a entrada � invalida 
	beq $s2, $zero,  end_loop 	#se o conteudo do elemento da string de bits for igual a '\0', acaba o loop 
	beq $s2, 10, end_loop	# se o conteudo do elemento da string de bits for igual a '\n', acaba o loop
	
	sll $t6, $t6, 4			#$t6 (que ser� a sa�da) � deslocado 4 bits para a esquerda. Isso � feito para depois somar $t1 (0 a 15) em seu primeiro byte
	li $t1, 0				#zera $t1 para recome�ar a contage
	la $a1, ($a3)			#salva em $a1 o endere�o contido em $a3. $a1 que ser� incrementado para percorrer a string de valores hexadecimais 

loop_check:				#loop percorre a string hexadecimal para achar o caractere correspondente
	lb $t0, 0 ($a1)		#atualiza $t0 com o valor da nova posi��o de $a1 (novo caractere dentro da string de valores hexadecimais)
	beq $t0, 'G', invalid 		#G representa o fim dos valores hexadecimais, n�o sendo um deles. Indica aqui que j� passou por todos os elementos e
						# (...) nenhum deles tem correspondencia com o caractere digitado pelo usu�rio, logo o n�mero � inv�lido 
	beq $s2, $t0, valid 		#Se o caractere atual, dentro o input do usu�rio, for igual a um dos caracteres hexadecimais, ent�o o caractere est� v�lido 
	addi $t1, $t1, 1		#incrementa o n�mero correspondente ao caractere
	addi $a1, $a1, 1		#incrementa a posi��o dentro da string de valores hexadecimais 
		
	j loop_check

valid:					#quando o caractere � v�lido, temos seu n�mero correspondente dentro da string hexadecimal, o valor est� em $t1.
	 add $t6, $t6, $t1		#somamos o valor contido em $t1 com o valor contido em $t6 (j� deslocado)  e resultado fica em $t6
	 add $t2, $t2, 1		#vai para o pr�ximo caractere dentro da string digitada pelo usuario
	 
	 add $t4, $t4, 1		#incrementa o contador de digitos
	 
	 j loop				#continua o loop
	 
	
invalid:					#caractere invalido, n�mero invalido
	#imprime pedindo que o valor seja colocado novamente, pois o atual � inv�lido
	li $v0, 4				
	la $a0, again
	syscall
	
	j num_hexa			#volta para pedir que insira o valor novamente

end_loop:					#fim da convers�o de hexa para decimal
	beq $t9, 10, print_output_dec	#se a base de saida form menos decimal, volta para o arquivo principal para imprimir o resultado
	jr $ra						#caso contr�rio, outra fun��o a chamou para ser intermedi�ria ou para fazer a valida��o da entrada

hexa_to_bin: 				
	
	jal hexa_to_dec		#chama para converter de hexa para decimal 
	move $t2, $t6			#como a sa�da de hexa_to_dec � $t6 e a entrada de dec_to_bin � $t2, precisamos mover 
	j dec_to_bin			#chama para converte de decimal para binario. dec_to_bin mandar� para print_output_bin_hexa
	
	
	

