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


	

	

char_to_int:

	li $t0, 0 #contador do numero de digitos do numero na base decimal
	
	loop_two:# esse segundo loop checa o numero de caracteres e vai ate a ultima posicao
	 #estar na ultima posicao da direita da string eh um ponto relevante para transformar a string em um inteiro
	#loop continua enquanto o numero de caracteres for menor igual a 10 ou ate chegar o final da string
		lb $s2, 0 ($t2) 		#o caractere no endereco atual da string que abriga o "numero" na base decimal eh colocado no registrado $s2
		beq  $t0, 11, invalid 		# se o numero de digitos for igual a 11
		beq $s2, $zero,  end_loop_two	#se o caractere atual for '\0' acaba o loop, entao estamos no final da string
		beq $s2, 10, end_loop_two		#se o caractere atual for '\n' acaba o loop, entao ...
		add $t0, $t0, 1				#dentro do loop_two: incrementa o contador de digitos
		add $t2, $t2, 1 				#incrementa o indice da string, vai ao proximo caractere 
		j loop_two					#continua loop
	
	end_loop_two:	#se o numero de caracteres (max 10) eh valido e chegou ao final da string

		add $t2, $t2, -1 #volta uma posicao na string, assim estamos no endereço da primeira letra da direita
	
		li $t3, 0 		#define quantas vezes vai fazer o loop_shift
					# primeiro caractere da direita para esquerda (0 vezes), segundo (1 vez), terceiro (2 vezes), ... , decimo(9 vezes)
		li $s7, 0 		#zera 
		li $t7, 0		#zera
	
	loop_three:	#loop que percorre a string da direita para a esquerda

			beq $t0, 0, end_loop_three #t0 eh o numero de digitos do "numero". Entao quando ele for zero (ja tiver percorrido toda a string), o loop acaba 
			lb $s2, 0 ($t2)		#$s2 recebe o caracter do posicao atual da string
			la $a1, ($a3)			#$a1 recebe a posicao inicial de hexa_values
			li $t1, 0				# zera valor de t1 - o numero que o caractere representa
	
		loop_check:	#percorre hexa_values
			lb $t4, 0 ($a1)		#atualiza $t4 com o caractere da posicao atual em hexa_values 
			beq $t4, 'A', invalid 		#quando chega em A, entao caractere atual, inserido como um numero decimal pelo usuario. nao eh um nuremo, entao o numero como um todo eh  invalido
			beq $s2, $t4, valid		#se o caractere atual inserido eh igual ao caractere atual em hexa_value, apos checar que ele eh um numero na linha de cima, entao valida o caractere
			addi $t1, $t1, 1		#incrementa o numero que o caractere reprenta, assim ao final teremos o valor correspondente
			addi $a1, $a1,1		#vai para a proxim posicao de hexa_value
	
			j loop_check

		invalid:					#caractere invalido, numero invalido
			#imprime pedindo que o valor seja colocado novamente, pois o atual eh invalido
			li $v0, 4				
			la $a0, again
			syscall
			j num_dec	

		valid:	#quando um dos caracteres da string inserida eh valido

			add $t2, $t2, -1	#decrementa uma posicao na string (se estiver na ultima letra da string, volta para a penultima e assim por diante)
			add $t0, $t0, -1	#decrementa o numero de digitos (que aqui define o fim do loop_three e que ja estamos na primeira letra da string)
			move $s7, $t3		#recebe o numero de vezes que o loop_shift sera executado
			li $t4, 0
			li $s5, 0
			li $s6, 4294967295 #valor maximo para decimal (int unsigned)
	
			#o loop_shift existe por um motivo:  nao ha como realizar um shift left que multiplique um binario por 10
			#tambem que pretende ir criando o numero inteiro somando o valor que caractere da string representa de acordo com sua posicao
			# o 1 na primeira posicao vale apenas 1, mas um 4 na segunda vale 40. O mesmo 4 na setima casa vale um 4 milhoes
			#entao a cada loop ele pega o numero atual e vai multiplicando 10 baseado na posicao que ele ocupa na string
			loop_shift:	
	
				beq $s7, 0, end_loop_shift   #quando $s7 conter 0, acaba o loop 
				sll $t5, $t1, 3		#o valor correspondente ao caractere atual eh deslocado 3 bits, multiplicado por 8 e valor eh salvo em $t5
				sll $t6, $t1, 1		#o valor correspondente ao caractere atual eh deslocado 1 bit, multiplicado por 2 e valor eh salvo em $t6
				add $t1, $t5, $t6	#soma os dois valores e retorna para $t1
				addi $s7, $s7, -1	#como $s7 recebeu o numero de vezes que o loop vai funcionar, entao seu valor vai ser decrementado toda vez par ser usado para parar o loop
				j loop_shift

			end_loop_shift: 

				subu $s5, $s6, $t1		#subtrai o valor final em $t1 do valor máximo que o inteiro sem sinal pode ter
				bleu  $t7, $s5, isvalid	#se o valor em $s7 (que o valor atual em inteiro)  for maior que essa diferenca, entao nao podemos somar $t1 em $t7.
				j invalid				# Logo o valor inserido pelo usuario eh superior ao maximo permitido (4294967295) e o numero eh invalido
		
	
			isvalid:			
				addi $t3, $t3, 1	#incrementa o numero de vezes que o loop_shift sera realizado (o proximo caractere esta uma casa decima a frente)
				add $t7, $t7, $t1	#o valor atual do inteiro eh incrementado com o valor que o caractere da string representa na base decimal
				j loop_three


	end_loop_three:
		 move $t2, $t7
		jr $ra
	
