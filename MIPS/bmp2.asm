.eqv BMP_FILE_SIZE 230522
.eqv BYTES_PER_ROW 960
.eqv MAX_X 320
.eqv MAX_Y 240

	.data
map:	.space 76799 #map of pixels which we have passed, 76799 = 320*240-1
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE


ycoordprep: .asciiz ", "
newline: .asciiz "\n"
filefailedout:	.asciiz "File not found or has incorrect format"
fname:	.asciiz "source.bmp"

	.text
main:
	jal	read_bmp

	beqz $v0, exit 		#if return is 0, means that an error occured, we must exit
	
	li $s0,	5
	
	lhu $t1, 0x200000($t1)
	
	addiu $t2, $t1, 0x20000
	
	bne $t1, 'Y', main
	
	li $s0, 0 	#x
	li $s1, 239 	#y
	#for(int y = 239; y>=0;y--)
	#for(int x = 0; x<MAX_X; x++)
	#{
	#Processing image
	#}

loop_y:
	bltz $s1, exit
	#body forloop y
loop_x:
	beq $s0, MAX_X, exit_x
	#body forloop x
	
	#if we have visited this pixel already, skip it
	la $t1, map
	mul $t2, $s1, MAX_X
	add $t2, $t2, $s0   	#t2 contains offset to pixel in our map
	add $t1, $t1, $t2	#t1 contains pixel in our map
	lb $t2, ($t1)
	bnez $t2, skip
	
	#check on which color are we now
	move	$a0, $s0		#x
	move	$a1, $s1		#y
	jal	get_pixel		#return to $v0
	
	bnez $v0, skip		#black pixel is 0 in hex, if its not black we skip
	#check if this black pixel belongs to valid marker
	#it should be top left one, so we can calculate width and height by going down
	
#==============================================================================================
	#Calculate width
	li $s2, 0 			#s2 = Width
	move $s4, $s0                   #s4 = temp x
	#while we see black pixels, we increase width, and move to the right
increase_width:
	addiu $s2, $s2, 1		#width++
	addiu $s4, $s4, 1		#temp_x++
	move	$a0, $s4		#x inc, going to the right
	move	$a1, $s1		#y stays the same
	jal	get_pixel		#return to $v0
	beqz  $v0, increase_width		
#==============================================================================================
	#Calculate thickness
	li $s5, 0 #s5 = Thickness
	subi $s4, $s4, 1		#s4 contains pixel to the right of last black pixel so we move back once
	move $s3, $s1       		#s3 is temp y
	#while we see black pixels, we increase thickness, and move down            
increase_thickness:
	addiu $s5, $s5, 1		#thickness++
	subi  $s3, $s3, 1		#temp_y--
	move	$a0, $s4		#x stays the same
	move	$a1, $s3		#y dec, going down
	jal	get_pixel		#return to $v0
	beqz  $v0, increase_thickness
#==============================================================================================
	#Calculate height
	li $s3, 0 #s3 = Height
	move $s4, $s1                   #s4 = temp y
	subi    $s6, $s0, 1  #needed to check if the marker is improper
	#while we see black pixels, we increase height, and move down ; also we checl pixels to the left, if there are any black pixels, marker is improper
increase_height:
	addiu $s3, $s3, 1		#height++
	subi  $s4, $s4, 1		#temp_y--
	move	$a0, $s0		#x stays the same
	move	$a1, $s4		#y dec, going down
	jal	get_pixel		#return to $v0
	
	bnez   $v0, exit_height_inc
	#we also can check if the marker is improper, if there are black pixel on the left side, its improper
	move	$a0, $s6		#x-1 stays the same
	move	$a1, $s4		#y inc, going down
	jal	get_pixel		#return to $v0
	beqz  $v0, improper_marker
	j increase_height
exit_height_inc:
#==============================================================================================
#	      +-----     WIDTH    ----+
#             |			     |
#             |			     |
#             
#   +------>  +-----------------------+  <---------+
#   |         |                       |          THICKNESS
#   +         |                       |            
#             |     +-----------------+  <---------+
#HEIGHT       |     |
#             |     |
#             |     |
#   +         |     |
#   |         |     |
#   +------>  +-----+
#   
#   	     |     |
#	     |     |
#	     THICKNESS
#==============================================================================================
# Now determine is this a valid marker

#VAR:
#$s0 	X, CANNOT CHANGE
#$s1 	Y, CANNOT CHANGE
#$s2	WIDTH, CANNOT CHANGE 	
#$s3 	HEIGHT, CANNOT CHANGE
#$s4    bottom of marker, can be changed 	
#$s5 	THICKNESS, CANNOT CHANGE
#$s6	x-1 of marker, can be changed
 	
# Simplest case H =1, its just a dot
	beq $s3, 1, improper_marker #dot check
# Simplest case thickness = height, its just a line
	beq $s5, $s3, improper_marker
# Simplest case H/W mismatch W=2*H
	sll $t0, $s3, 1
	bne $t0, $s2, improper_marker
#Thickness>height, marker was rotated
	sle $t0, $s3, $s5  #s3 < s5
	bnez $t0, improper_marker
	
	# Now we need to check if the marker is filled with black pixels
	subi $s4, $s1, 1 #we can skip the 1st line, it was already checked before
	addi $s6, $s0, 1 #we can skip the 1st line to left, it was already checked before
loop_y_marker_check:

	sub $t0, $s1, $s4  
	beq $t0, $s3 , loop_y_marker_check_exit #if we reached height than exit
	
	#loop ymarker body 
	#branch to width if we have tempy-y<thickness
	sub $t0, $s1, $s4  
	bne $t0, $s5, loop_x_marker_check #if we reached thickness, now we check not width but thickness
	add $s6, $s0, $s5	#load to s6, our first pixel after thickness
#--------------------LOOP X FOR HEIGHT-WIDTH TRANSITION--------------------
loop_x_marker_check_HW_transition:
	
	sub $t0, $s6, $s0  
	beq $t0, $s2 , loop_x_marker_check_HW_transition_exit #if we reached width than exit
	#loop xmarker body
	move 	$a0, $s6		#x 
	move	$a1, $s4		#y 
	jal	get_pixel		#return to $v0
	beqz    $v0, improper_marker	#black pixel is 0 in hex, if its black, marker is improper
	
	#loop xmarker end
	addi $s6, $s6, 1 #go right
	j loop_x_marker_check_HW_transition
loop_x_marker_check_HW_transition_exit:
#--------------------LOOP X FOR HEIGHT-WIDTH TRANSITION--------------------
	move $s2, $s5 #we now check thickness, not width
	addi $s6, $s0, 1 #restore x, skip 1st line to the left
#--------------------LOOP X--------------------
loop_x_marker_check:	
	sub $t0, $s6, $s0  
	beq $t0, $s2 , loop_x_marker_check_exit #if we reached width/thickness than exit
	#loop xmarker body
	move 	$a0, $s6		#x 
	move	$a1, $s4		#y 
	jal	get_pixel		#return to $v0
	bnez   $v0, improper_marker	#black pixel is 0 in hex, if its not black, marker is improper
	
	#loop xmarker end
	addi $s6, $s6, 1 #go right
	j loop_x_marker_check
loop_x_marker_check_exit:
#--------------------LOOP X--------------------
	

	#last check if there are pixels to right, which may cause marker to be improper
	move 	$a0, $s6		#x 
	move	$a1, $s4		#y 
	jal	get_pixel		#return to $v0
	beqz  $v0, improper_marker	#black pixel is 0 in hex, if its black, marker is improper
	
	addi  $s6, $s0, 1 #restore x, skip 1st line to the left
	#loop ymarker end
	subi $s4, $s4, 1 #go down
	j loop_y_marker_check
loop_y_marker_check_exit:
	
	#also check bottom line it must not contain black pixels
loop_x_marker_lower_check:	
	sub $t0, $s6, $s0  
	beq $t0, $s2 , loop_x_marker_lower_check_exit #if we reached thickness than exit
	#loop xmarker body
	move 	$a0, $s6		#x 
	move	$a1, $s4		#y 
	jal	get_pixel		#return to $v0
	beqz    $v0, improper_marker	#black pixel is 0 in hex, if it is black marker is improper
	
	#loop xmarker end
	addi $s6, $s6, 1 #go right
	j loop_x_marker_lower_check
	
loop_x_marker_lower_check_exit:
	#if all checks passed, we can write coordinates

	
	move	$a0, $s0		#x
	move	$a1, $s1		#y
	jal	print_coordinate
	

improper_marker:
skip:
	#endbody
	addi $s0, $s0, 1	#x++
	j loop_x
exit_x:
	li $s0, 0		#x=0
	subi $s1, $s1, 1	#y--
	j loop_y


exit:	li 	$v0,10		#Terminate the program
	syscall
# ============================================================================
print_coordinate:
#description: 
#	prints coordinate of marker
#arguments:
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner, but will print as if top left one
#return value: none
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,($sp)
	
	li $v0, 1		#print x
        syscall
        
        la $a0, ycoordprep	#print ", "
        li $v0, 4
        syscall
        
        li $t0, 239
	sub $a0, $t0, $a1	#a0 = 239 - current y coordinate
        li $v0, 1
        syscall
	
	la $a0, newline		#newline
	li $v0, 4
        syscall
	
	lw $ra, ($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: 	0 if failed to load a file, or incorrect file format
#		1 if accepted
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,($sp)
	sub $sp, $sp, 4		#push $s1
	sw $s1, ($sp)
	sub $sp, $sp, 4		#push $s2
	sw $s2, ($sp)

	#open file
	li $v0, 13
        la $a0, fname		#file name 
        li $a1, 0		#flags: 0-read file
        li $a2, 0		#mode: ignored
        syscall
        
        bltz $v0, file_failed  #file not found, return 0
        
	move $s1, $v0      # save the file descriptor
	
	#read file
	li $v0, 14
	move $a0, $s1
	la $a1, image
	li $a2, BMP_FILE_SIZE
	syscall

	#close file
	li $v0, 16
	move $a0, $s1
        syscall
	

	# check if it is a bitmap
	li	$t0, 0x4D42 				#check for bitmap signature
	lhu	$t1, image				#load the first 2 bytes into $t1
							
	bne	$t0, $t1, file_failed 			#if(t1!=0x4D42)

	# check if it is the right size
	li	$t0, MAX_X				#load the width (320) 
	lw 	$s1, 18($a1)				#read the file width (offset of 18) 
	bne	$t0, $s1, file_failed			#if(s1!=MAX_X)
	li	$t0, MAX_Y				#load the height (240)
	lw	$s2, 22($a1)				#read the file height  (offset of 22)
	bne	$t0, $s2, file_failed			#if(s1!=MAX_Y)

	# confirm that the bitmap is actually 24 bits
	li	$t0, 24					
	lb	$t1, 28($a1)				#offset of 28 points = of how many bits the bmp is
							
	bne	$t0, $t1, file_failed			#if(t1!=24)


	li $v0, 1  		#return 1
	j file_accepted
	
file_failed:
	la $a0, filefailedout
	li $v0, 4
        syscall
        li $v0, 0
file_accepted:
	lw $s2, ($sp)		#restore (pop) $s2
	add $sp, $sp, 4
	lw $s1, ($sp)		#restore (pop) $s1
	add $sp, $sp, 4
	lw $ra, ($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

# ============================================================================
get_pixel:
#description: 
#	returns color of specified pixel
#arguments:
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	$v0 - 0RGB - pixel color

	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,($sp)
	
	bltz $a0, incorrect_params 		# x<0
	bltz $a1, incorrect_params 		# y<0
	bge $a0, MAX_X, incorrect_params 	# x>=maximum X 
	bge $a1, MAX_Y, incorrect_params	# x>=maximum Y 
	
	#mark pixel as visited
	la $t1, map
	mul $t2, $a1, MAX_X
	add $t2, $t2, $a0   	#t2 contains offset to pixel in our map
	add $t1, $t1, $t2	#t1 contains pixel in our map
	li $t2, 1
	sb $t2, ($t1)		#store 1
	
	la $t1, image + 10	#adress of file offset to pixel array
	lw $t2, ($t1)		#file offset to pixel array in $t2
	la $t1, image		#adress of bitmap
	add $t2, $t1, $t2	#adress of pixel array in $t2
	
	#pixel address calculation
	mul $t1, $a1, BYTES_PER_ROW #t1= y*BYTES_PER_ROW
	move $t3, $a0		
	sll $a0, $a0, 1
	add $t3, $t3, $a0	#$t3= 3*x
	add $t1, $t1, $t3	#$t1 = 3x + y*BYTES_PER_ROW
	add $t2, $t2, $t1	#pixel address 

	#get color
	lbu $v0,($t2)		#load B
	lbu $t1,1($t2)		#load G
	sll $t1,$t1,8
	or $v0, $v0, $t1
	lbu $t1,2($t2)		#load R
        sll $t1,$t1,16
	or $v0, $v0, $t1
	j exit_get_pixel
	
	#return -1 if we are outside of image boundry
incorrect_params:
	li $v0, -1
	
exit_get_pixel:
	lw $ra, ($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

# ============================================================================
