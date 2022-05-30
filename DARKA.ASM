extrn _hscplayer:far

.286
.model small
.stack 200h

picseg   segment
part1   label byte
include darka.001

part2   label byte
include darka.002
ends

.data

part3   label byte
include darka.003

line    label byte
include darka.lin

end_txt db 'Made by Earwax/Myst in 100% ASM in ''95',10,13
        db 'Player by Chicken/ECR',10,13,'$'

plane   db 0001b,0010b,0100b,1000b

no_vga  db 'Sorry this Loader requires VGA!',10,13,'$'
no_386  db 'Sorry dude you need a 386 or better to see this demo!',10,13,'$'

delay   dw 5
x_out   dw 6
y_out   dw 10

scroll_limit    dw 160

;Font stuff   0123456789 ?-+=() :.' *! (sphere)
;             ]^_`abcdef opqruw klm gi    j

           ;123456789012345678
string1 db 'THIS FILE HAS BEEN',254
        db '   LEECHED FROM   ',255

string2 db '   THE SYSGODS   ',254
        db '       ARE       ',254
        db ' j WHITE TIGER j ',254    
        db '   j SNIPER j    ',255

string3 db ' `lb GIGS ONLINE ',254
        db '     b CDROMS    ',255

string4 db ' j ONLINE DOOM j ',254
        db ' COMPETITVE REGO ',254
        db '  GREAT  PRICES  ',254
        db '   ON HARDWARE   ',255

string5 db ' FOR THE LATEST  ',254
        db '  AND GREATEST   ',254
        db ' SHAREWARE FILES ',255

string6 db '   RING NOW ON   ',254
        db '  qc^f `ab f`]d  ',255

;text    db '  CHARACTER TEST  ',254
;        db 'pppppppppppppppppp',254
;        db 'ABCDEFGHIJKLMNOPQR',254
;        db 'STUVWXYZ]^_`abcdef',254
;        db 'ghijklmnopqrstuvwx',254
;        db 'pppppppppppppppppp',255

higher  dw 79
lower   dw 81

crystal_music   label byte
include darka.mus
adlib   db 0

palette label byte
include darka.pal

font    label byte
include darka.fnt

stars   db 0,0,0
   i = 3
   REPT 16
        db i,i,i
   i = i+3
   ENDM

include darka.dw

x               dw ?
y               dw ?
z               dw ?

star_number     dw 0
star_plane      dw 0
star_color      db 0
star_factor     dw 1

wave_val label byte
include darka.val

wave    dw 200

include modex.inc

proc    main    
        mov     ax,@data
        mov     ds,ax

        mov     ax,4a00h
        mov     bx,2000h
        int     21h

        push    sp
        pop     dx
        cmp     dx,sp
        jz      has_386
        lea     dx,no_386
        mov     ah,9
        int     21h
        mov     ax,4c00h
        int     21h
has_386:
.386

        modex   1,0,752         ;752x480x256 screen
        cmp     x_error,0
        jz      vga_ok
        mov     ax,0003h
        int     10h
        mov     ah,9
        lea     dx,no_vga
        int     21h
        mov     ax,4c00h
        int     21h
vga_ok:

        out8    3c0h,10h
        out8    3c0h,61h
        mov     dx,3d4h
        mov     ax,0a018h
        out     dx,ax

        xor     bx,bx
        mov     al,09h
        out     dx,al
        inc     dx
        in      al,dx
        mov     ah,bh
        and     ah,00000010b
        shl     ah,5
        and     al,10111111b
        or      al,ah
        out     dx,al

        dec     dx
        mov     al,07h
        out     dx,al
        inc     dx
        in      al,dx
        and     al,11101111b
        mov     ah,bh
        and     ah,00000001b
        shl     ah,4
        or      al,ah
        out     dx,al
        
        mov     dx,3d4h
        mov     ax,0109h        ;480->240
        out     dx,ax

        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768
clear_pal:
        xor     al,al
        out     dx,al
        loop    clear_pal

        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        xor     si,si
        mov     cx,3*8
load_palette:
        mov     al,palette[si]
        out     dx,al
        inc     si
        loop    load_palette
        mov     cx,17*3
        xor     si,si
load_star_colors:
        mov     al,stars[si]
        out     dx,al
        inc     si
        loop    load_star_colors

        setxy   0,240

        call    load_picture

        call    start_music
        call    load_line

        mov     cx,70
        call    wait_loop

        lea     si,string1
        mov     y_out,50
        call    write_string
        mov     cx,30
        call    wait_loop
        call    fade_in_top_scroller

        mov     cx,140
        call    wait_loop

        call    clear_text

demo_loop:
        lea     si,string2
        mov     y_out,30
        mov     x_out,15
        call    write_string
        mov     cx,350
        call    wait_loop
        call    clear_text

        mov     cx,30
        call    wait_loop

        lea     si,string3
        mov     y_out,50
        mov     x_out,15
        call    write_string
        mov     cx,350
        call    wait_loop
        call    clear_text

        mov     cx,30
        call    wait_loop

        lea     si,string4
        mov     y_out,30
        mov     x_out,15
        call    write_string
        mov     cx,350
        call    wait_loop
        call    clear_text

        mov     cx,30
        call    wait_loop

        lea     si,string5
        mov     y_out,30
        mov     x_out,15
        call    write_string
        mov     cx,350
        call    wait_loop
        call    clear_text

        mov     cx,30
        call    wait_loop

        lea     si,string6
        mov     y_out,50
        mov     x_out,15
        call    write_string
        mov     cx,350
        call    wait_loop
        call    clear_text

        mov     cx,30
        call    wait_loop


        mov     ah,1
        int     16h
        jz      demo_loop

end_of_loader:
        mov     cx,64
fade_out_of_demo:
        push    cx
        cmp     scroll_limit,240
        ja      no_scroll_off
        inc     scroll_limit
no_scroll_off:
        call    fade_out
        call    scroll_top
        call    star_planes
        call    fade_music
        call    poll_music
        call    vertical
        pop     cx
        loop    fade_out_of_demo

        call    stop_music

        mov     ax,0003h
        int     10h
        mov     ah,9
        lea     dx,end_txt
        int     21h
        mov     ax,4c00h
        int     21h
endp    main

proc    wait_loop
        pusha
wl:
        push    cx
        call    scroll_top
        call    star_planes
        call    poll_music
        call    vertical
        pop     cx
        mov     ah,1
        int     16h
        jnz     end_of_loader
        loop    wl
        popa
        ret
endp    wait_loop

proc    fade_in_top_scroller
        pusha
        mov     cx,64
fade_in_scroller:
        push    cx
        lea     si,part3
        lea     di,temp_palette
        add     di,96
        mov     dx,3c8h
        mov     al,32
        out     dx,al
        inc     dx
        mov     cx,672
fits:
        lodsb
        mov     ah,[di]
        cmp     al,ah
        jz      no_fade_scroller
        inc     ah
no_fade_scroller:
        mov     [di],ah
        inc     di
        mov     al,ah
        out     dx,al
        loop    fits
        call    scroll_top
        call    star_planes
        call    poll_music
        call    vertical
        pop     cx
        loop    fade_in_scroller
        popa
        ret
endp    fade_in_top_scroller

proc    scroll_top
        pusha
        lea     di,wave_val
        cmp     wave,1000
        jb      scroller_ok
        mov     wave,200
scroller_ok:
        add     di,wave
        add     wave,2
        mov     ax,word ptr ds:[di]
        setxy   ax,scroll_limit
        popa
        ret
endp    scroll_top


proc    clear_text
        pusha
        mov     cx,73
        mov     ax,5
        mov     dx,148
ctl:
        push    cx
        push    ax dx
        mov     dx,188
        imul    dx
        mov     di,ax
        call    clear_current_line
        pop     dx
        push    dx
        mov     ax,188
        imul    dx
        mov     di,ax
        call    clear_current_line
        call    scroll_top
        call    poll_music
        call    star_planes
        call    vertical
        mov     ah,1
        int     16h
        jnz     eol_
        pop     dx ax 
        add     ax,2
        sub     dx,2
        pop     cx
        loop    ctl
        popa
        ret
eol_:
        jmp     end_of_loader
clear_current_line:
        mov     cx,188
        out16   3c4h,2,1111b
ccl:
        xor     al,al
        mov     es:[di],al
        inc     di
        loop    ccl
        ret
endp    clear_text

proc    load_line               ;The "tv" bit at the start
        pusha
        mov     cx,80
        mov     ax,159
        mov     dx,2
draw_television_on:
        push    dx ax
        mov     ax,80
        mov     bx,188
        imul    bx
        mov     di,ax
        pop     ax
        push    ax
        xor     dx,dx
        mov     bx,4
        idiv    bx
        add     di,ax
        mov     bx,dx
        pop     ax dx
        push    cx dx ax
        mov     cx,dx
draw_tv:
        out16   3c4h,2,plane[bx]
        mov     al,24
        mov     es:[di],al
        inc     bx
        cmp     bx,4
        jz      change_tv_planes
        loop    draw_tv
        jmp     tv_half_on
change_tv_planes:
        xor     bx,bx
        inc     di
        loop    draw_tv
tv_half_on:
        pop     ax dx cx
        add     dx,4
        sub     ax,2
        call    poll_music
        call    vertical
        loop    draw_television_on

        mov     cx,39
        mov     dx,2
tv_fully_on:
        push    cx dx
        mov     ax,80
        sub     ax,dx
        mov     bx,188
        imul    bx
        mov     di,ax
        push    di
        xor     bx,bx
        lea     si,line
        mov     cx,320
dl1:
        out16   3c4h,2,plane[bx]
        lodsb
        neg     al
        add     al,39
        mov     es:[di],al
        inc     bx
        cmp     bx,4
        jz      cbx1
        loop    dl1
        jmp     fdl1
cbx1:
        xor     bx,bx
        inc     di
        loop    dl1
fdl1:
        pop     di
        add     di,188*2

        mov     cx,80
        out16   3c4h,2,1111b
cl1:
        xor     al,al
        mov     es:[di],al
        inc     di
        loop    cl1

        pop     dx cx
        push    cx dx

        mov     ax,80
        add     ax,dx
        mov     bx,188
        imul    bx
        mov     di,ax
        push    di
        xor     bx,bx
        lea     si,line
        add     si,320
        mov     cx,320
dl2:
        out16   3c4h,2,plane[bx]
        mov     al,[si]
        dec     si
        neg     al
        add     al,39
        mov     es:[di],al
        inc     bx
        cmp     bx,4
        jz      cbx2
        loop    dl2
        jmp     fdl2
cbx2:
        xor     bx,bx
        inc     di
        loop    dl2
fdl2:
        pop     di
        sub     di,188*2

        mov     cx,80
        out16   3c4h,2,1111b
cl2:
        xor     al,al
        mov     es:[di],al
        inc     di
        loop    cl2

        pop     dx cx
        add     dx,2

        add     higher,2
        sub     lower,2
        call    poll_music
        call    star_planes
        call    vertical
        dec     cx
        jz      tv_is_on
        jmp     tv_fully_on
tv_is_on:
        popa
        ret
endp    load_line

proc    load_picture            ;only thing that uses a 386 "gs"
        pusha
        push    gs
        mov     ax,picseg
        mov     gs,ax
        mov     di,30080
        add     di,188*3
        lea     si,part1
        mov     cx,60
lp1:
        push    cx
        mov     cx,320
        xor     bx,bx
        add     di,14
load_pic:
        out16   3c4h,2,plane[bx]
        mov     al,gs:[si]
        inc     si
        add     al,32
        mov     es:[di],al
        inc     bx
        cmp     bx,4
        jz      change_bx_
        loop    load_pic
        jmp     pic_loaded
change_bx_:
        xor     bx,bx
        inc     di
        loop    load_pic
pic_loaded:
        pop     cx
        add     di,94
        loop    lp1

        mov     di,30080
        add     di,188*3
        add     di,94
        lea     si,part2
        mov     cx,63
lp2:
        push    cx
        mov     cx,320
        xor     bx,bx
load_pic2:
        out16   3c4h,2,plane[bx]
        mov     al,gs:[si]
        inc     si
        add     al,32
        mov     es:[di],al
        inc     bx
        cmp     bx,4
        jz      change_bx_2
        loop    load_pic2
        jmp     pic_loaded2
change_bx_2:
        xor     bx,bx
        inc     di
        loop    load_pic2
pic_loaded2:
        pop     cx
        add     di,14
        add     di,94
        loop    lp2
        pop     gs
        popa
        ret
endp    load_picture

proc    star_planes             ;3 Star Planes, Parallax Scrolling!
        pusha
        mov     star_number,90  ;Plane 3        Distant
        mov     star_plane,90*3*2
        mov     star_factor,1
        call    draw_stars
        mov     star_number,60  ;Plane 2        Middle
        mov     star_plane,30*3*2
        mov     star_factor,2
        call    draw_stars
        mov     star_number,30  ;Plane 1        Closest
        mov     star_plane,0
        mov     star_factor,3
        call    draw_stars
        popa
        ret
endp    star_planes

proc    draw_stars
        pusha
        lea     bp,starfield
        add     bp,star_plane
        mov     cx,star_number
star_draw_loop:
        mov     ax,[ds:bp]
        add     bp,2
        mov     x,ax
        mov     ax,[ds:bp]
        add     bp,2
        mov     y,ax
        mov     ax,[ds:bp]
        mov     z,ax
        mov     star_color,0
        call    draw_star
        sub     bp,4
        mov     ax,[ds:bp]
        cmp     ax,321
        jb      move_star_plane
        mov     ax,star_factor
        neg     ax
move_star_plane:
        add     ax,star_factor
        mov     [ds:bp],ax
        mov     x,ax
        add     bp,6

        xor     dx,dx
        mov     ax,z
        mov     bx,10
        idiv    bx
        neg     ax
        add     ax,16+8
        mov     star_color,al

        call    draw_star
        loop    star_draw_loop
        popa
        ret
        
draw_star:
        mov     ax,lower
        cmp     y,ax
        jb      no_draw
        mov     ax,higher
        cmp     y,ax
        ja      no_draw

        mov     bx,y
        mov     ax,188
        imul    bx
        mov     di,ax
        xor     dx,dx
        mov     ax,x
        mov     bx,4
        idiv    bx
        add     di,ax
        mov     bx,dx

        out16   3ceh,4,bl
        mov     al,es:[di]
        cmp     al,0
        jz      draw
        cmp     al,8
        jb      no_draw
draw:
        out16   3c4h,2,plane[bx]
        mov     al,star_color
        mov     es:[di],al
no_draw:
        ret
endp    draw_stars

proc    write_string
        pusha
        push    y_out
        push    x_out
get_character:
        lodsb
        cmp     al,255
        jnz     not_quit
        pop     x_out
        pop     y_out
        popa
        ret
not_quit:
        cmp     al,32
        jnz     not_space
        jmp     finished_character
not_space:
        cmp     al,254
        jnz     not_new_line
        pop     x_out
        push    x_out
        add     y_out,20
        jmp     get_character
not_new_line:
        sub     al,65
        lea     bp,font
check_bp:
        cmp     al,19
        jb      add_offset
        sub     al,19
        add     bp,320*19
        jmp     check_bp
add_offset:
        xor     ah,ah
        mov     cx,16
        imul    cx
        add     bp,ax

        mov     cx,y_out
        mov     ax,188
        imul    cx
        mov     di,ax
        xor     dx,dx
        mov     ax,x_out
        mov     cx,4
        idiv    cx
        mov     bx,dx
        add     di,ax

        inc     bp
        mov     cx,20
draw_character:
        push    di bx cx
        mov     cx,16
draw_line:
        out16   3c4h,2,plane[bx]
        mov     al,ds:[bp]
        mov     es:[di],al
        inc     bp
        inc     bx
        cmp     bx,4
        jz      change_plane
        loop    draw_line
        jmp     finished_line
change_plane:
        xor     bx,bx
        inc     di
        loop    draw_line
finished_line:
        pop     cx bx di
        add     bp,320-16
        add     di,188
        loop    draw_character
finished_character:
        mov     cx,delay
character_delay:
        call    star_planes
        call    scroll_top
        call    vertical
        call    poll_music
        loop    character_delay
        add     x_out,17
        mov     ah,1
        int     16h
        jnz     eod
        jmp     get_character
eod:
        jmp     end_of_loader
endp    write_string

proc    detect_adlib
        pusha
        stc
        mov     dx,388h
        in      al,dx
        cmp     al,0
        jz      has_adlib
        cmp     al,6
        jnz     doesnt_have_adlib
has_adlib:
        clc
doesnt_have_adlib:
        popa
        ret
endp    detect_adlib

proc    start_music
        pusha
        push    es
        call    detect_adlib
        jc      no_music
no_music:
        mov     adlib,1
        mov     ax,ds
        mov     es,ax
        lea     si,crystal_music
        xor     ah,ah
        mov     bl,1
        call    _hscplayer
        pop     es
        popa
        ret
endp    start_music

proc    poll_music near
        pusha
        cmp     adlib,1
        jnz     no_poll
        mov     ah,1
        call    _hscplayer
no_poll:
        popa
        ret
endp    poll_music

proc    fade_music near
        pusha
        cmp     adlib,1
        jnz     no_fade
        mov     ah,3
        call    _hscplayer
no_fade:
        popa
        ret
endp    fade_music

proc    stop_music
        pusha
        cmp     adlib,1
        jnz     no_stop
        mov     ah,2
        call    _hscplayer
no_stop:
        popa
        ret
endp    stop_music

end     main
