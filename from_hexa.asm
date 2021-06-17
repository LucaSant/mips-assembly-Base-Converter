	.data
	.align 0
	
next_line: .asciiz "\n"
again: 	.asciiz "\n Valor invalido, coloque outro...\n"

	.text
	.globl hexa_to_bin
	.globl hexa_to_dec
	
#Parâmetros para as funções de conversão a partir da base hexadecimal...

# --->  $t2  : endereço do inicio do espaço alocado (acum_c)
# ---> $t9  :   base de saida

hexa_to_dec:
	
	li $t6, 0 # somar os valores aqui
	li $t4, 0 #conta o numero de digitos

loop:
	lb $s2, 0 ($t2)		#atualiza $s2 como o valor da nova posição de $t2 ( novo caractere dentro da string inserida pelo usuário)

	beq $t4, 9, invalid		#se o contador $t4 chegar em 8, que é o tamanho máximo de digitos suportado em hexadecimal, a entrada é invalida 
	beq $s2, $zero,  end_loop 	#se o conteudo do elemento da string de bits for igual a '\0', acaba o loop 
	beq $s2, 10, end_loop	# se o conteudo do elemento da string de bits for igual a '\n', acaba o loop
	
	sll $t6, $t6, 4			#$t6 (que será a saida) é deslocado 4 bits para a esquerda. Isso é feito para depois somar $t1 (0 a 15) em seu primeiro byte
	li $t1, 0				#zera $t1 para recomeçar a contage
	la $a1, ($a3)			#salva em $a1 o endereço contido em $a3. $a1 que será incrementado para percorrer a string de valores hexadecimais 

loop_check:				#loop percorre a string hexadecimal para achar o caractere correspondente
	lb $t0, 0 ($a1)		#atualiza $t0 com o valor da nova posição de $a1 (novo caractere dentro da string de valores hexadecimais)
	beq $t0, 'G', invalid 		#G representa o fim dos valores hexadecimais, não sendo um deles. Indica aqui que já passou por todos os elementos e
						# (...) nenhum deles tem correspondencia com o caractere digitado pelo usuário, logo o número é inválido 
	beq $s2, $t0, valid 		#Se o caractere atual, dentro o input do usuário, for igual a um dos caracteres hexadecimais, então o caractere estão válido 
	addi $t1, $t1, 1		#incrementa o número correspondente ao caractere
	addi $a1, $a1, 1		#incrementa a posição dentro da string de valores hexadecimais 
		
	j loop_check

valid:					#quando o caractere é válido, temos seu número correspondente dentro da string hexadecimal, o valor estão em $t1.
	 add $t6, $t6, $t1		#somamos o valor contido em $t1 com o valor contido em $t6 (já deslocado)  e resultado fica em $t6
	 add $t2, $t2, 1		#vai para o próximo caractere dentro da string digitada pelo usuario
	 
	 add $t4, $t4, 1		#incrementa o contador de digitos
	 
	 j loop				#continua o loop
	 
	
invalid:					#caractere invalido, número invalido
	#imprime pedindo que o valor seja colocado novamente, pois o atual é inválido
	li $v0, 4				
	la $a0, again
	syscall
	
	j num_hexa			#volta para pedir que insira o valor novamente

end_loop:					#fim da conversão de hexa para decimal
	beq $t9, 10, print_output_dec	#se a base de saida form menos decimal, volta para o arquivo principal para imprimir o resultado
	jr $ra						#caso contrário, outra função a chamou para ser intermediaria ou para fazer a validação da entrada

hexa_to_bin: 				
	
	jal hexa_to_dec		#chama para converter de hexa para decimal 
	move $t2, $t6			#como a saida de hexa_to_dec é $t6 e a entrada de dec_to_bin é $t2, precisamos mover 
	j dec_to_bin			#chama para converte de decimal para binario. dec_to_bin mudará para print_output_bin_hexa
	
	
	

