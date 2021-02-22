;section .bss
;_bitmap:  = 8	in 64 -72				
;_x_pos:  = 12	in 64 -64				
;_y_pos:  = 16	in 64 -56
;_tocomparewith_x: RESD 1; -48			
;_tempy: RESD 1; 	-40				
;_tempx: RESD 1; 	-36			
;_height: RESD 1; 	-32			
;_thickness: RESD 1;	-28				
;_width: RESD 1; 	-24				
;_x: RESD 1; 		-20			
;_y: RESD 1; 		-16				
;_maxHeight: RESD 1;	-12				
;_maxWidth: RESD 1; 	-8				
;_markerAmount: RESD 1; -4									
section  .text

global find_markers
find_markers:
        
;--------------------------------------------
	push	rbp
	mov	rbp, rsp
	sub	rsp, 80				

	push	rbx
	push	rsi
	push	rdi
;--------------------------------------------
        ;Check is file correct

        mov     [rbp-56], rdx
        mov     [rbp-64], rsi
        mov     [rbp-72], rdi
        
                   ;check for bitmap signature     
        movzx   eax, WORD [rdi]
        
        cmp     eax, 0x4D42
        jne     return_bad
        
        movzx   eax, BYTE [rdi+28]              ;confirm that the bitmap is actually 24 bits
        cmp     eax, 24
        jne     return_bad
        
        ;int markerAmount = 0

	mov	DWORD [rbp-4], 0

        ;load maxWidth offset 18
	mov	ecx, 18
	mov	rdx, [rbp-72]
	mov	eax, DWORD [rdx+rcx]
	mov	DWORD [rbp-8], eax

        ;load maxHeight offset 22


	mov	ecx, 22
	mov	rdx, [rbp-72]
	mov	eax, DWORD  [rdx+rcx]
	mov	DWORD  [rbp-12], eax

        ;for (int y = maxHeight-1; y >= 0; y--)

	mov	eax, DWORD  [rbp-12]
	mov	DWORD  [rbp-16], eax
loop_y_outer:
	mov	eax, DWORD  [rbp-16]
	dec	eax
	mov	DWORD  [rbp-16], eax

	cmp	eax, -1
	jle	loop_y_outer_exit


        ;for (int x = 0; x < maxWidth; x++)

	mov	DWORD  [rbp-20], 0
loop_x_outer:

	mov	eax, DWORD  [rbp-20]
	cmp	eax, DWORD  [rbp-8]
	jge	loop_x_outer_exit

        ;black pixel is 0 in hex, if its not black we skip
        mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-16]
	mov	esi, DWORD  [rbp-20]
	mov	rdi, [rbp-72];1st
	call	get_pixel		
				;clear stack
	test	eax, eax                ;if != 0
	jne	skip


        ;int width = 0
	mov	DWORD  [rbp-24], 0

        ;int thickness = 0
	mov	DWORD  [rbp-28], 0

        ;int height = 0
	mov	DWORD  [rbp-32], 0

        ;int tempx = x

	mov	eax, DWORD  [rbp-20]
	mov	DWORD  [rbp-36], eax

        ;int tempy = y

	mov	eax, DWORD  [rbp-16]
	mov	DWORD  [rbp-40], eax
increase_width:

        ;do while (get_pixel == 0)
        ;width++

	mov	eax, DWORD  [rbp-24]
	inc	eax
	mov	DWORD  [rbp-24], eax

        ;tempx++

	mov	eax, DWORD  [rbp-36]
	inc	eax
	mov	DWORD  [rbp-36], eax

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		;get_pixel
				;clear stack
	test	eax, eax                ;==0 then go back
	je	increase_width



        ;tempx--, tempx contains pixel to the right of last black pixel so we move back once

	mov	eax, DWORD  [rbp-36]
	dec	eax
	mov	DWORD  [rbp-36], eax
increase_thickness:

        ;do while (get_pixel == 0)
        ;thickness++

	mov	eax, DWORD  [rbp-28]
	inc	eax
	mov	DWORD  [rbp-28], eax

        ;tempy--

	mov	eax, DWORD  [rbp-40]
	dec     eax
	mov	DWORD  [rbp-40], eax
        
	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		;get_pixel
				;clear stack
	test	eax, eax                ;==0 then go back

	je	 increase_thickness


        ;tempx = x

	mov	eax, DWORD  [rbp-20]
	mov	DWORD  [rbp-36], eax

        ;tempy = y

	mov	eax, DWORD  [rbp-16]
	mov	DWORD  [rbp-40], eax
increase_height:

        ;do while (get_pixel == 0)
        ;height++

	mov	eax, DWORD  [rbp-32]
	inc     eax
	mov	DWORD  [rbp-32], eax

        ;tempy--

	mov	eax, DWORD  [rbp-40]
	dec	eax
	mov	DWORD  [rbp-40], eax

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		; get_pixel
				;clear stack
	test	eax, eax                ;==0 then go back
	je	 increase_height

        ;if (height == 1)its just a dot
        ;skip
	cmp	DWORD  [rbp-32], 1
	je	skip

        ;if (thickness == height)its just a line
        ;skip
	mov	eax, DWORD  [rbp-28]
	cmp	eax, DWORD  [rbp-32]
	je	skip

        ;if (width != height * 2)H/W mismatch W=2*H
        ;skip
	mov	eax, DWORD  [rbp-32]
	shl	eax, 1
	cmp	DWORD  [rbp-24], eax
	jne	skip

        ;if (thickness > height)marker was rotated
        ;skip
	mov	eax, DWORD  [rbp-28]
	cmp	eax, DWORD  [rbp-32]
	jge	skip

        ;int tocomparewith_x = width;

	mov	eax, DWORD  [rbp-24]
	mov	DWORD  [rbp-44], eax

        ; we do not have a map we will also check top line
        
        ;for (tempx = x; tempx - x < tocomparewith_x; x++) check last top line of marker, it should not contain black pixels
        ;tempy = y+1
        
        mov	eax, DWORD  [rbp-20]
	mov	DWORD  [rbp-36], eax
	mov	eax, DWORD  [rbp-16]
        inc     eax
	mov	DWORD  [rbp-40], eax
loop_x_inner_top_line:
	mov	eax, DWORD  [rbp-36]
	sub	eax, DWORD  [rbp-20]
	cmp	eax, DWORD  [rbp-44]
	jge	 loop_x_inner_top_line_exit

        ;if (get_pixel) == 0) its invalid

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		; get_pixel
				;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [rbp-36]
	inc     eax
	mov	DWORD  [rbp-36], eax
        
	jmp	 loop_x_inner_top_line
loop_x_inner_top_line_exit:

        ;for (tempy = y-1; y - tempy < height; y--)

	mov	eax, DWORD  [rbp-16]
        dec     eax
	mov	DWORD  [rbp-40], eax

loop_y_inner:
	mov	eax, DWORD  [rbp-16]
	sub	eax, DWORD  [rbp-40]
	cmp	eax, DWORD  [rbp-32]
	jge	loop_y_inner_exit

        ;if (get_pixel for pixel on the left == 0)
	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-20]
        dec esi
	mov	rdi, [rbp-72];1st
	call	get_pixel		;get_pixel
				;clear stack
	test	eax, eax
	je	skip                    ;we got invalid marker

        ;if (y - tempy == thickness) if we reached thickness
	mov	eax, DWORD  [rbp-16]
	sub	eax, DWORD  [rbp-40]
	cmp	eax, DWORD  [rbp-28]
	jne	thickness_not_reached

        ;for (tempx = x+thickness; tempx - x < tocomparewith_x; tempx++)
        ;check the line below right arm of marker it should not contain black pixels
	mov	eax, DWORD  [rbp-20]
	add	eax, DWORD  [rbp-28]
	mov	DWORD  [rbp-36], eax

loop_x_inner_thickness:
	mov	eax, DWORD  [rbp-36]
	sub	eax, DWORD  [rbp-20]
	cmp	eax, DWORD  [rbp-44]
	jge	 loop_x_inner_thickness_exit

        ;if (get_pixel== 0) then its invalid

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		;get_pixel
				;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [rbp-36]
	inc     eax
	mov	DWORD  [rbp-36], eax
        
	jmp	 loop_x_inner_thickness
loop_x_inner_thickness_exit:

        ;tocomparewith_x = thickness, now we check for thickness not for width

	mov	eax, DWORD  [rbp-28]
	mov	DWORD  [rbp-44], eax
thickness_not_reached:

        ;for (tempx = x+1; tempx-x < tocomparewith_x; tempx++)

	mov	eax, DWORD  [rbp-20]
        inc     eax
	mov	DWORD  [rbp-36], eax

loop_x_inner:
	mov	eax, DWORD  [rbp-36]
	sub	eax, DWORD  [rbp-20]
	cmp	eax, DWORD  [rbp-44]
	jge	 loop_x_inner_exit

        ;if (get_pixel != 0) than its invalid, marker shoud be properly filled

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		;get_pixel
				;clear stack
	test	eax, eax
	jne	skip

        mov	eax, DWORD  [rbp-36]
	inc     eax
	mov	DWORD  [rbp-36], eax

	jmp	 loop_x_inner
loop_x_inner_exit:

        ;if (get_pixel == 0), check pixel on the right, if its black marker is invalid
	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		; get_pixel
				 ;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [rbp-40]
	dec     eax
	mov	DWORD  [rbp-40], eax
        
	jmp	loop_y_inner
loop_y_inner_exit:

        ;for (tempx = x; tempx - x < tocomparewith_x; x++) check last bottom line of marker, it should not contain black pixels

	mov	eax, DWORD  [rbp-20]
	mov	DWORD  [rbp-36], eax
loop_x_inner_last_line:
	mov	eax, DWORD  [rbp-36]
	sub	eax, DWORD  [rbp-20]
	cmp	eax, DWORD  [rbp-44]
	jge	 loop_x_inner_last_line_exit

        ;if (get_pixel) == 0) its invalid

	mov	r8d, DWORD  [rbp-12];5th
	mov	ecx, DWORD  [rbp-8]
	mov	edx, DWORD  [rbp-40]
	mov	esi, DWORD  [rbp-36]
	mov	rdi, [rbp-72];1st
	call	get_pixel		; get_pixel
				;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [rbp-36]
	inc     eax
	mov	DWORD  [rbp-36], eax
        
	jmp	 loop_x_inner_last_line
loop_x_inner_last_line_exit:
        ;all checks passed, now see if
        ;if (markerAmount >= 50)

	cmp	DWORD  [rbp-4], 50
	jl	 ok_marker_amount
return_bad:
        ;return -1
	or	eax, -1
	jmp	main_exit
ok_marker_amount:
        ;x_pos[markerAmount] = x

	mov	eax, DWORD  [rbp-4]
	mov	rcx, QWORD  [rbp-64]
	mov	edx, DWORD  [rbp-20]
	mov	DWORD  [rcx+rax*4], edx

        ;y_pos[markerAmount] = maxHeight-1 - y
        mov     edx, DWORD  [rbp-12]
        dec     edx
	mov	eax, DWORD  [rbp-16]
        sub     edx, eax

	mov	eax, DWORD  [rbp-4]
	mov	rcx, QWORD  [rbp-56]
        
	mov	DWORD  [rcx+rax*4], edx

        ;markerAmount++
	mov	eax, DWORD  [rbp-4]
	inc     eax
	mov	DWORD  [rbp-4], eax
skip:
        mov	eax, DWORD  [rbp-20]
	inc     eax
	mov	DWORD  [rbp-20], eax
	jmp	loop_x_outer
loop_x_outer_exit:
	jmp	loop_y_outer
loop_y_outer_exit:
        ;whole image processed
        ;return markerAmount
	mov	eax, DWORD  [rbp-4]
main_exit:
;-----------------------------------------
        ;epilogue
	pop	rdi
	pop	rsi
	pop	rbx
	add	rsp, 80				

	mov	rsp, rbp
	pop	rbp
	ret
;-----------------------------------------

get_pixel:
;description: 
;	returns color of specified pixel
;arguments:
;       _bitmap - bitmap
;	_x - x coordinate
;	_y - y coordinate - (0,0) - bottom left corner
;       _width maxWidth
;       _height maxHeight
;return value:
;	rax - 0RGB - pixel color


;_bitmap:           = 8	      rdi					       
;_x:                = 12    	rsi					
;_y:                = 16    	rdx					
;_width:            = 20   	rcx					
;_height:           = 24       r8
;offset             = -12
;bytrsperRow        = -8
;pixelOffset        = -4

				
        push    rbp  
        mov     rbp,rsp  
        
        push    rbx  
        push    rsi  
        push    rdi  

        ;if (x < 0 || x >= width || y < 0 || y >= height)
        cmp         rsi,0  
        jl          get_pixel_return_err  
        cmp         rsi, rcx  
        jge         get_pixel_return_err  
        cmp         rdx,0  
        jl          get_pixel_return_err    
        cmp         rdx, r8 
        jl          get_pixel_count  
        ;return -1
get_pixel_return_err:
        mov         rax, -1 
        jmp         get_pixel_exit  
get_pixel_count:
        movzx       eax,WORD [rdi+10]      ;bitmap[10]
        mov         [rbp-4],eax             ;WORD pixelOffset = bitmap[10]
        ;int bytrsperRow = (width * 3 + 3) & (~3)
        imul        rax,rcx,3          ;width * 3
        add         eax,3                   ;width * 3 + 3
        and         eax,0FFFFFFFCh          ;(width * 3 + 3) & (~3)
        mov         DWORD [rbp-8],eax       ;int bytrsperRow = (width * 3 + 3) & (~3);
        ;int offset = WORD [rbp-4]+ 3 * x + y * bytrsperRow
        imul        rax,rsi,3    ;3 * x
        add         eax,DWORD [rbp-4]       ;3 * x+pixelOffset

        imul        edx,DWORD [rbp-8]       ;y * bytrsperRow
        add         eax, edx                ;WORD [rbp-4] + 3 * x + y * bytrsperRow
             ;int offset = WORD [rbp-4] + 3 * x + y * bytrsperRow
        
        add         rdi,rax 
        
        movzx       rax,BYTE  [rdi] ;load B
        movzx       rcx,BYTE  [rdi+1] ;load G
        
        shl         rcx, 8
        or          rax, rcx
        
        movzx       rcx,BYTE[rdi+2] ;load R
        
        shl         rcx, 16
        or          rax, rcx

get_pixel_exit:
        ;epilogue
        pop     rdi
        pop     rsi
        pop     rbx
        

        mov     rsp, rbp
        pop     rbp
        ret