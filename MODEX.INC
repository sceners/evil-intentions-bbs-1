comment %
ModeX Routines by Earwax

Current Modes Supported
        
        Mode 0 = 320x400x256            Res OK
        Mode 1 = 320x480x256            Res OK
        Mode 2 = 360x400x256            Res X
        Mode 3 = 360x480x256            Res X
        Mode 4 = 376x282x256            Res XX
        Mode 5 = 320x240x256            Res XX

THESE ARE S'POSED TO BE THE RESOLUTIONS BUT I DONT THINK SO!!

Requires : 286 Processor

%

.data

X_Error         db 0
vis_height      dw ?
vis_width       dw ?
regs            dw 0
temp_palette    db 768 dup (0)

x320x400        dw 05f00h
                dw 04f01h
                dw 05002h
                dw 08203h
                dw 05404h
                dw 08005h
                dw 0bf06h
                dw 01f07h
                dw 09c10h
                dw 08e11h
                dw 08f12h
                dw 09615h
                dw 0b916h

x320x480        dw 05f00h
                dw 04f01h
                dw 05002h
                dw 08203h
                dw 05404h
                dw 08005h
                dw 00d06h
                dw 03e07h
                dw 0ea10h
                dw 08c11h
                dw 0df12h
                dw 0e715h
                dw 00616h

x360x400        dw 06b00h
                dw 05901h
                dw 05a02h
                dw 08e03h
                dw 05e04h
                dw 08a05h
                dw 0bf06h
                dw 01f07h
                dw 09c10h
                dw 08e11h
                dw 08f12h
                dw 09615h
                dw 0b916h

x376x282        dw 06e00h
                dw 05d01h
                dw 05e02h
                dw 09103h
                dw 06204h
                dw 08f05h
                dw 06206h
                dw 00f07h
                dw 0310fh
                dw 03710h
                dw 08911h
                dw 03312h
                dw 03c15h
                dw 05c16h

x360x480        dw 06b00h
                dw 05901h
                dw 05a02h
                dw 08e03h
                dw 05e04h
                dw 08a05h
                dw 00d06h
                dw 03e07h
                dw 0ea10h
                dw 08c11h
                dw 0df12h
                dw 0e715h
                dw 00616h

x360x360        dw 06b00h
                dw 05901h
                dw 05a02h
                dw 08e03h
                dw 05e04h
                dw 08a05h
                dw 08810h
                dw 08511h
                dw 06712h
                dw 06d15h
                dw 0ba16h
.code

out8    macro   port, value
        pusha
        mov     dx,port
        mov     al,value
        out     dx,al
        popa
endm    

in16    macro   port, index
        mov     dx,port
        mov     al,index
        out     dx,al
        inc     dx
        in      al,dx
        mov     ah,al
endm

out16   macro   port, index, value
        pusha
        push    ax dx 
        mov     dx,port
        mov     al,index
        mov     ah,value
        out     dx,ax
        pop     dx ax
        popa
endm

and16   macro   port, index, value
        push    ax dx
        mov     dx,port
        mov     al,index
        out     dx,al
        inc     dx
        in      al,dx
        and     al,value
        out     dx,al
        pop     dx ax
endm

modex   macro   modeno, cellheight, virtwidth
        pusha
        mov     ax,modeno
        mov     bx,cellheight
        mov     cx,virtwidth
        call    set_modex
        popa
endm

setxy   macro   xval,yval
        pusha
        mov     bx,xval
        mov     ax,yval
        call    set_start_offset
        popa
endm

proc    set_modex near
        push    cx bx ax
        mov     ax,0013h
        int     10h
        mov     ah,0fh
        int     10
        cmp     al,13h
        jz      has_VGA
        pop     ax bx cx
        mov     x_error,1
        ret
has_vga:
        and16   3c4h,4,0f7h     
        out16   3c4h,2,1111b    ;Enable All Planes
        out16   3c4h,4,0110b
        
        mov     ax,0a000h       ;Clear Video Memory
        mov     es,ax
        xor     di,di
        xor     ax,ax
        mov     cx,8000h
        cld
        rep     stosw


        out16   3d4h,14h,0      ;Disable Dword Mode
        out16   3d4h,17h,0e3h   ;Disable Word Mode

        pop     ax
        cmp     ax,0
        jnz     mode_2
        mov     cl,63h
        lea     si,x320x400
        mov     regs,13
        mov     vis_height,400
        mov     vis_width,320
        jmp     mode_is_valid
mode_2:
        cmp     ax,1
        jnz     mode_3
        mov     cl,0e3h
        lea     si,x320x480
        mov     regs,13
        mov     vis_height,480
        mov     vis_width,320
        jmp     mode_is_valid
mode_3:
        cmp     ax,2
        jnz     mode_4
        mov     cl,067h
        lea     si,x360x400
        mov     regs,13
        mov     vis_height,400
        mov     vis_width,360
        jmp     mode_is_valid
mode_4:
        cmp     ax,3
        jnz     mode_5
        mov     cl,0e7h
        lea     si,x360x480
        mov     regs,13
        mov     vis_height,480
        mov     vis_width,360
        jmp     mode_is_valid
mode_5:
        cmp     ax,4
        jnz     mode_6
        mov     cl,0e7h
        lea     si,x376x282
        mov     regs,14
        mov     vis_height,564
        mov     vis_width,376
        jmp     mode_is_valid
mode_6:
        cmp     ax,5
        jnz     mode_7
        mov     cl,0e3h
        lea     si,x360x360
        mov     regs,12
        mov     vis_height,240
        mov     vis_width,320
        jmp     mode_is_valid
mode_7:
invalid_mode:                   ;Moron!
        mov     x_error,1 
        ret
mode_is_valid:
        out16   3c4h,0,1
        out8    3c2h,cl
        out16   3c4h,0,3
        out16   3d4h,11h,2ch

        mov     dx,3d4h
        mov     cx,regs
set_up_mode:
        outsw
        loop    set_up_mode
        
        pop     cx
        add     cx,40h
        out16   3d4h,9h,cl
        mov     ax,vis_height
        xor     dx,dx
        idiv    cx
        mov     vis_height,ax
        pop     cx
        or      cx,cx
        jz      std_width
        mov     vis_width,cx
        jmp     set_offset
std_width:
        mov     cx,vis_width
set_offset:
        shr     cx,3
        out16   3d4h,13h,cl

        mov     x_error,0
        ret        
endp    set_modex

proc    set_start_offset near
        cli
        push    bx
        mov     cx,ax
        mov     ax,vis_width
        shr     ax,2
        mul     cx
        mov     cx,ax
        shr     bx,2
        add     cx,bx
        out16   3d4h,0ch,ch
        out16   3d4h,0dh,cl
        pop     bx
        and     bx,3
        shl     bl,1
        out8    3c0h,33h
        out8    3c0h,bl
        sti
        ret
endp    set_start_offset


proc    reset_modex near
        and16   3c4h,4,0f7h
        out16   3d4h,14h,0      ;Disable Dword Mode
        out16   3d4h,17h,0e3h   ;Disable Word Mode
        ret
endp    reset_modex

proc    reset_linear near
        out16   3c4h,4,0eh      
        out16   3d4h,14h,4      ;Enable Dword Mode
        out16   3d4h,17h,0a3h   ;Enable Word Mode
        ret
endp    reset_linear

proc    vertical        near
        push    dx ax
        mov     dx,3dah
wait_not_vrt:
        in      al,dx
        test    al,8
        jnz     wait_not_vrt
wait_end_vrt:
        in      al,dx
        test    al,8
        jz      wait_end_vrt
        pop     ax dx
        ret
endp    vertical

proc    save_pal near
        pusha
        lea     si,temp_palette
        mov     dx,3c7h
        xor     al,al
        out     dx,al
        mov     dx,3c9h
        mov     cx,768
save_palette_loop:
        in      al,dx
        mov     [si],al
        inc     si
        loop    save_palette_loop
        popa
        ret
endp    save_pal

proc    fade_in near
        pusha
        call    save_pal

        lea     si,temp_palette
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,256*3
fade_in_all:
        mov     al,[si]
        mov     ah,[di]
        cmp     al,ah
        jae     no_fade_in
        inc     al
no_fade_in:
        out     dx,al
        inc     si
        inc     di
        loop    fade_in_all

        popa
        ret
endp    fade_in

proc    fade_out near
        pusha
        call    save_pal
        lea     si,temp_palette
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768
fade_all_out_:
        mov     al,[si]
        cmp     al,0
        jz      no_fade_out
        dec     al
        mov     [si],al
no_fade_out:
        out     dx,al
        inc     si
        loop    fade_all_out_
        popa
        ret
endp    fade_out

proc    black_pal near
        pusha
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768
black_palette_loop:
        xor     al,al
        out     dx,al
        loop    black_palette_loop
        popa
        ret
endp    black_pal

proc    wait_a_sec near
        pusha
        mov     ax,cx
        mov     cx,70
        imul    cx
        mov     cx,ax
wait_for_retrace:
        call    vertical
        loop    wait_for_retrace
        popa
        ret
endp    wait_a_sec

proc    wait_for_key near
        pusha
        xor     ah,ah
        int     16h
        popa 
        ret
endp    wait_for_key
