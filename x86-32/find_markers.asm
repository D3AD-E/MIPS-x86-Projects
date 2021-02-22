;section .bss
;_tocomparewith_x: RESD 1; -44				
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
;_bitmap:  = 8					
;_x_pos:  = 12					
;_y_pos:  = 16					
section  .text

global find_markers
find_markers:
        
;--------------------------------------------
	push	ebp
	mov	ebp, esp
	sub	esp, 44				

	push	ebx
	push	esi
	push	edi
;--------------------------------------------
        ;Check is file correct


        mov	edx, DWORD [ebp+8]              ;check for bitmap signature     
        movzx   eax, WORD [edx]
        
        cmp     eax, 0x4D42
        jne     return_bad
        
        movzx   eax, BYTE [edx+28]              ;confirm that the bitmap is actually 24 bits
        cmp     eax, 24
        jne     return_bad
        
        ;int markerAmount = 0

	mov	DWORD [ebp-4], 0

        ;load maxWidth offset 18
	mov	ecx, 18
	mov	edx, DWORD [ebp+8]
	mov	eax, DWORD [edx+ecx]
	mov	DWORD [ebp-8], eax

        ;load maxHeight offset 22


	mov	ecx, 22
	mov	edx, DWORD  [ebp+8]
	mov	eax, DWORD  [edx+ecx]
	mov	DWORD  [ebp-12], eax

        ;for (int y = maxHeight-1; y >= 0; y--)

	mov	eax, DWORD  [ebp-12]
	mov	DWORD  [ebp-16], eax
loop_y_outer:
	mov	eax, DWORD  [ebp-16]
	dec	eax
	mov	DWORD  [ebp-16], eax

	cmp	eax, -1
	jle	loop_y_outer_exit


        ;for (int x = 0; x < maxWidth; x++)

	mov	DWORD  [ebp-20], 0
loop_x_outer:

	mov	eax, DWORD  [ebp-20]
	cmp	eax, DWORD  [ebp-8]
	jge	loop_x_outer_exit

        ;black pixel is 0 in hex, if its not black we skip

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-16]
	push	edx
	mov	eax, DWORD  [ebp-20]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		
	add	esp, 20			;clear stack
	test	eax, eax                ;if != 0
	jne	skip


        ;int width = 0
	mov	DWORD  [ebp-24], 0

        ;int thickness = 0
	mov	DWORD  [ebp-28], 0

        ;int height = 0
	mov	DWORD  [ebp-32], 0

        ;int tempx = x

	mov	eax, DWORD  [ebp-20]
	mov	DWORD  [ebp-36], eax

        ;int tempy = y

	mov	eax, DWORD  [ebp-16]
	mov	DWORD  [ebp-40], eax
increase_width:

        ;do while (get_pixel == 0)
        ;width++

	mov	eax, DWORD  [ebp-24]
	inc	eax
	mov	DWORD  [ebp-24], eax

        ;tempx++

	mov	eax, DWORD  [ebp-36]
	inc	eax
	mov	DWORD  [ebp-36], eax

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		;get_pixel
	add	esp, 20			;clear stack
	test	eax, eax                ;==0 then go back
	je	 increase_width



        ;tempx--, tempx contains pixel to the right of last black pixel so we move back once

	mov	eax, DWORD  [ebp-36]
	dec	eax
	mov	DWORD  [ebp-36], eax
increase_thickness:

        ;do while (get_pixel == 0)
        ;thickness++

	mov	eax, DWORD  [ebp-28]
	inc	eax
	mov	DWORD  [ebp-28], eax

        ;tempy--

	mov	eax, DWORD  [ebp-40]
	dec     eax
	mov	DWORD  [ebp-40], eax
        
	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		;get_pixel
	add	esp, 20			;clear stack
	test	eax, eax                ;==0 then go back

	je	 increase_thickness


        ;tempx = x

	mov	eax, DWORD  [ebp-20]
	mov	DWORD  [ebp-36], eax

        ;tempy = y

	mov	eax, DWORD  [ebp-16]
	mov	DWORD  [ebp-40], eax
increase_height:

        ;do while (get_pixel == 0)
        ;height++

	mov	eax, DWORD  [ebp-32]
	inc     eax
	mov	DWORD  [ebp-32], eax

        ;tempy--

	mov	eax, DWORD  [ebp-40]
	dec	eax
	mov	DWORD  [ebp-40], eax

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		; get_pixel
	add	esp, 20			;clear stack
	test	eax, eax                ;==0 then go back
	je	 increase_height

        ;if (height == 1)its just a dot
        ;skip
	cmp	DWORD  [ebp-32], 1
	je	skip

        ;if (thickness == height)its just a line
        ;skip
	mov	eax, DWORD  [ebp-28]
	cmp	eax, DWORD  [ebp-32]
	je	skip

        ;if (width != height * 2)H/W mismatch W=2*H
        ;skip
	mov	eax, DWORD  [ebp-32]
	shl	eax, 1
	cmp	DWORD  [ebp-24], eax
	jne	skip

        ;if (thickness > height)marker was rotated
        ;skip
	mov	eax, DWORD  [ebp-28]
	cmp	eax, DWORD  [ebp-32]
	jge	skip

        ;int tocomparewith_x = width;

	mov	eax, DWORD  [ebp-24]
	mov	DWORD  [ebp-44], eax

        ; we do not have a map we will also check top line
        
        ;for (tempx = x; tempx - x < tocomparewith_x; x++) check last top line of marker, it should not contain black pixels
        ;tempy = y+1
        
        mov	eax, DWORD  [ebp-20]
	mov	DWORD  [ebp-36], eax
	mov	eax, DWORD  [ebp-16]
        inc     eax
	mov	DWORD  [ebp-40], eax
loop_x_inner_top_line:
	mov	eax, DWORD  [ebp-36]
	sub	eax, DWORD  [ebp-20]
	cmp	eax, DWORD  [ebp-44]
	jge	 loop_x_inner_top_line_exit

        ;if (get_pixel) == 0) its invalid

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		; get_pixel
	add	esp, 20			;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [ebp-36]
	inc     eax
	mov	DWORD  [ebp-36], eax
        
	jmp	 loop_x_inner_top_line
loop_x_inner_top_line_exit:

        ;for (tempy = y-1; y - tempy < height; y--)

	mov	eax, DWORD  [ebp-16]
        dec     eax
	mov	DWORD  [ebp-40], eax

loop_y_inner:
	mov	eax, DWORD  [ebp-16]
	sub	eax, DWORD  [ebp-40]
	cmp	eax, DWORD  [ebp-32]
	jge	loop_y_inner_exit

        ;if (get_pixel for pixel on the left == 0)
	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-20]
	dec     eax                        ;x--
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		;get_pixel
	add	esp, 20			;clear stack
	test	eax, eax
	je	skip                    ;we got invalid marker

        ;if (y - tempy == thickness) if we reached thickness
	mov	eax, DWORD  [ebp-16]
	sub	eax, DWORD  [ebp-40]
	cmp	eax, DWORD  [ebp-28]
	jne	thickness_not_reached

        ;for (tempx = x+thickness; tempx - x < tocomparewith_x; tempx++)
        ;check the line below right arm of marker it should not contain black pixels
	mov	eax, DWORD  [ebp-20]
	add	eax, DWORD  [ebp-28]
	mov	DWORD  [ebp-36], eax

loop_x_inner_thickness:
	mov	eax, DWORD  [ebp-36]
	sub	eax, DWORD  [ebp-20]
	cmp	eax, DWORD  [ebp-44]
	jge	 loop_x_inner_thickness_exit

        ;if (get_pixel== 0) then its invalid

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		;get_pixel
	add	esp, 20			;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [ebp-36]
	inc     eax
	mov	DWORD  [ebp-36], eax
        
	jmp	 loop_x_inner_thickness
loop_x_inner_thickness_exit:

        ;tocomparewith_x = thickness, now we check for thickness not for width

	mov	eax, DWORD  [ebp-28]
	mov	DWORD  [ebp-44], eax
thickness_not_reached:

        ;for (tempx = x+1; tempx-x < tocomparewith_x; tempx++)

	mov	eax, DWORD  [ebp-20]
        inc     eax
	mov	DWORD  [ebp-36], eax

loop_x_inner:
	mov	eax, DWORD  [ebp-36]
	sub	eax, DWORD  [ebp-20]
	cmp	eax, DWORD  [ebp-44]
	jge	 loop_x_inner_exit

        ;if (get_pixel != 0) than its invalid, marker shoud be properly filled

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		;get_pixel
	add	esp, 20			;clear stack
	test	eax, eax
	jne	skip

        mov	eax, DWORD  [ebp-36]
	inc     eax
	mov	DWORD  [ebp-36], eax

	jmp	 loop_x_inner
loop_x_inner_exit:

        ;if (get_pixel == 0), check pixel on the right, if its black marker is invalid
	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		; get_pixel
	add	esp, 20			 ;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [ebp-40]
	dec     eax
	mov	DWORD  [ebp-40], eax
        
	jmp	loop_y_inner
loop_y_inner_exit:

        ;for (tempx = x; tempx - x < tocomparewith_x; x++) check last bottom line of marker, it should not contain black pixels

	mov	eax, DWORD  [ebp-20]
	mov	DWORD  [ebp-36], eax
loop_x_inner_last_line:
	mov	eax, DWORD  [ebp-36]
	sub	eax, DWORD  [ebp-20]
	cmp	eax, DWORD  [ebp-44]
	jge	 loop_x_inner_last_line_exit

        ;if (get_pixel) == 0) its invalid

	mov	eax, DWORD  [ebp-12]
	push	eax
	mov	ecx, DWORD  [ebp-8]
	push	ecx
	mov	edx, DWORD  [ebp-40]
	push	edx
	mov	eax, DWORD  [ebp-36]
	push	eax
	mov	ecx, DWORD  [ebp+8]
	push	ecx
	call	get_pixel		; get_pixel
	add	esp, 20			;clear stack
	test	eax, eax
	je	skip
        
        mov	eax, DWORD  [ebp-36]
	inc     eax
	mov	DWORD  [ebp-36], eax
        
	jmp	 loop_x_inner_last_line
loop_x_inner_last_line_exit:
        ;all checks passed, now see if
        ;if (markerAmount >= 50)

	cmp	DWORD  [ebp-4], 50
	jl	 ok_marker_amount
return_bad:
        ;return -1
	or	eax, -1
	jmp	main_exit
ok_marker_amount:
        ;x_pos[markerAmount] = x

	mov	eax, DWORD  [ebp-4]
	mov	ecx, DWORD  [ebp+12]
	mov	edx, DWORD  [ebp-20]
	mov	DWORD  [ecx+eax*4], edx

        ;y_pos[markerAmount] = maxHeight-1 - y
        mov     edx, DWORD  [ebp-12]
        dec     edx
	mov	eax, DWORD  [ebp-16]
        sub     edx, eax

	mov	eax, DWORD  [ebp-4]
	mov	ecx, DWORD  [ebp+16]
        
	mov	DWORD  [ecx+eax*4], edx

        ;markerAmount++
	mov	eax, DWORD  [ebp-4]
	inc     eax
	mov	DWORD  [ebp-4], eax
skip:
        mov	eax, DWORD  [ebp-20]
	inc     eax
	mov	DWORD  [ebp-20], eax
	jmp	loop_x_outer
loop_x_outer_exit:
	jmp	loop_y_outer
loop_y_outer_exit:
        ;whole image processed
        ;return markerAmount
	mov	eax, DWORD  [ebp-4]
main_exit:
;-----------------------------------------
        ;epilogue
	pop	edi
	pop	esi
	pop	ebx
	add	esp, 44				

	mov	esp, ebp
	pop	ebp
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
;	eax - 0RGB - pixel color

;offset             = -12
;bytesPerRow        = -8
;pixelOffset        = -4
;_bitmap:           = 8						       
;_x:                = 12						
;_y:                = 16						
;_width:            = 20						
;_height:           = 24						
        push    ebp  
        mov     ebp,esp  
        sub     esp,12
        
        push    ebx  
        push    esi  
        push    edi  

        ;if (x < 0 || x >= width || y < 0 || y >= height)
        cmp         DWORD [ebp+12],0  
        jl          get_pixel_return_err  
        mov         eax, [ebp+12]  
        cmp         eax, [ebp+20]  
        jge         get_pixel_return_err  
        cmp         DWORD [ebp+12],0  
        jl          get_pixel_return_err  
        mov         eax, [ebp+16]  
        cmp         eax, [ebp+24]  
        jl          get_pixel_count  
        ;return -1
get_pixel_return_err:
        or          eax,0FFFFFFFFh  
        jmp         get_pixel_exit  
get_pixel_count:

       ; mov         ecx,10  
        mov         edx,DWORD  [ebp+8]  
        movzx       eax,WORD [edx+10]      ;bitmap[10]
        mov         [ebp-4],eax             ;WORD pixelOffset = bitmap[10]
        ;int bytesPerRow = (width * 3 + 3) & (~3)
        imul        eax,[ebp+20],3          ;width * 3
        add         eax,3                   ;width * 3 + 3
        and         eax,0FFFFFFFCh          ;(width * 3 + 3) & (~3)
        mov         DWORD [ebp-8],eax       ;int bytesPerRow = (width * 3 + 3) & (~3);
        ;int offset = WORD [ebp-4]+ 3 * x + y * bytesPerRow
        imul        eax,DWORD [ebp+12],3    ;3 * x
        add         eax,DWORD [ebp-4]       ;3 * x+pixelOffset
        mov         ecx,DWORD [ebp+16]      ;
        imul        ecx,DWORD [ebp-8]       ;y * bytesPerRow
        add         eax, ecx                ;WORD [ebp-4] + 3 * x + y * bytesPerRow
        mov         DWORD [ebp-12],eax      ;int offset = WORD [ebp-4] + 3 * x + y * bytesPerRow
        
        
        mov         edx,DWORD [ebp+8]  
        add         edx,DWORD [ebp-12]  
        movzx       eax,BYTE  [edx] ;load B
        movzx       ecx,BYTE  [edx+1] ;load G
        
        shl         ecx, 8
        or          eax, ecx
        
        movzx       ecx,BYTE[edx+2] ;load R
        
        shl         ecx, 16
        or          eax, ecx

get_pixel_exit:
        ;epilogue
        pop     edi
        pop     esi
        pop     ebx
        
        add     esp, 12
        mov     esp, ebp
        pop     ebp
        ret