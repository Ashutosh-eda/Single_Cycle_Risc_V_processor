	lw x1,128(x0)	#Reads word at 0x80 (word index 32) from dmem → x1 <= 1.
	lw x2,132(x0)	#Reads word at 0x84 (word index 33) → x2 <= 2.
	add x3,x1,x2	#x3 <= 3 (1 + 2).
	sw x3,136(x0)	#Writes 3 to 0x88 (word index 34).
	beq x0,x0,0     #EXIT
