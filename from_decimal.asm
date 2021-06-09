	.data
	.align 0
	
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"

	.text
	.globl dec_to_bin
	.globl dec_to_hexa
	
#Parâmetros para as funções de conversão a partir da base decimal...

# ---> $a3 : endereço da string com valores hexadecimais
# ---> $a2 : endereço do fim acumulador para construção da saida em binario ou hexadecimal
#  ---> $t2 :  número de entrada na base decimal

dec_to_bin:

	li $s1, 32 #config tamanho máximo de dígitos da saida na base binária
	li $t6, 1 
	li $t4, 1 #valor para criação da máscara para base binária
	
	j convert


dec_to_hexa:
	
	li $s1, 8 #config tamanho máximo de dígitos da saida na base hexadecimal
	li $t6, 4 
	li $t4, 4 #valor para criação da á para base hexadecimal
	
	j convert

convert:
	
	#criação da á para isolar a quantidade de bits desejado
	# - binario: temos o interesse de isolar um bit por vez e assim verificar se ele é 0 ou 1
	# - hexadecimal: isolamos 1 byte por vez e assim verificamos seu valor entre 0 e 15, depois procuramos o valor correspondente na string de hexa
	
	li $s0, 1 
	sllv $s0, $s0, $t4 #$t4 pode ser 1 (um bit por vez) ou pode ser 4 (1 byte por vez)
	sub $s0, $s0, 1 #mascara criada para 1 ou 4 bit 
	#forma das m�scaras:
	#para 1 bit:    0000 0000 0000 0000 0000 0000 0000 0001 
	#para 4 bits:  0000 0000 0000 0000 0000 0000 0000 1111
	

	li $s2, 0 #v�riavel que controla o número de bits do número contido $t2 que serão deslocados (...) 
	#(...) para assim isolarmos apenas os desejados usando a á
	li $t5, 0 #contador do número de dígitos do número de saida


	
loop:
	 
	beq $t5, $s1, endloop 			# se o número de digitos máximos for atingido, o loop acaba
	
	srlv $t3, $t2, $s2  				# $t3 recebe o numero de entrada descolado para a direita

	and $t1, $t3, $s0  				# realiza a operação lógica E entre o número de entrada deslocado ($t3) e a á ($s0)
	# $t1 tem os bits isolados
	
	add $t7, $a3, $t1				 #soma esse valor ( entre 0 e 15, ou entre 0 e 1) no endereço do início da string hexadecimal e (...)
								# (...)  coloca o resultado em $t7
	
	
	addi $a2, $a2, -1				 # $a2 é fim do espaço alocado, logo ao colocar -1 vamos aumentando o espaço onde (...)
								# (...) colocaremos os digitos do valor convertido
	
	
	
	lb $a0, 0 ($t7) 			#como a á já estão criada, podemos usar $t4 outra vez. Coloquemos o valor contido no endereço (...) 
							# (...) armazenado em $t7
	
	sb $a0, 0 ($a2)			# depois colocar valor no endereço armazenado em $a2, ou seja, colcoar no acumulador
							#addi $a2, $a2, -1
	
	add $s2, $s2, $t6 			#aumenta em 1 ou 4 o número de bits que serão deslocados para direita
	addi $t5, $t5,1 			# +1 digito do número de saida (o loop para quando for 8 (para o hexadecimal) ou 32 (para binario)
	
	j loop 
	
endloop:
	j print_output_bin_hexa 	#volta ao principal para imprimir resultado
