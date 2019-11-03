.model small
.stack 100h

;//////////////////////////////////// PRINT ANY NUMBER
print_number macro number
  xor ax, ax
  mov ax, number
  call PrintNumber
endm

;//////////////////////////////////// READ A NUMBER FROM USER
read_number macro var, sig
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx

  mov ah, 01h
	int 21h

  .if al == 2dh     ;if the first char readed from console input is a '-'
    mov sig, 2dh    ;move to the var a '-' and
    mov ah, 01h     ;continue reading
    int 21h
  .elseif al == 2bh ;else if the first char readed from console input is a '+'
    mov sig, 2bh    ;move to the var a '+' and
    mov ah, 01h     ;continue reading
    int 21h
  .elseif al >= '0' && al <= '9' ;else if the first char readed from console input is a digit
    mov sig, 2bh    ;move to the var a '+' and
  .else
    mov novalid, 1 ;else is a no valid char, so put a 1 on the flag
  .endif

  xor ah, ah
  .while al != 0dh
    xor ah, ah
    sub al, 30h ; le resto para obtener el numero en decimal.
    mov bx, var
    add bx, ax ; le sumo el numero ingresado a lo que tiene mi variable num1.
    mov var, bx
    mov ah, 01h	; leo caracter.
    int 21h
    .if al != 0dh
      .if al >= '0' && al <= '9'
        xor ah, ah
        mov tmp, al
        mov ax, var
        mov bl, 10d
        mul bl ; ax = al * bl
        mov var, ax; guardo en mi variable el nuevo valor.
        mov al, tmp
      .else
        mov novalid, 1
        .break
      .endif
    .endif
	.endw
endm

;//////////////////////////////////// CALCULATE THE DERIVATE OF A FUNCTION FACTOR
der macro sig, num, x, dsig, dnum
  xor dx, dx    ;clears the register
  mov dx, sig   ;moves the sig of the function
  mov dsig, dx  ;to the derivate sig of the new function
  xor bx, bx    ;clears the register
  mov bx, x     ;moves the exponent digit to bx
  xor ax, ax    ;clears the register
  mov ax, num   ;moves the coefficient to ax
  mul bx        ;mul the coeficient by the exponent
  mov dnum, ax  ;moves the result to the derivate num of the new function
endm

;//////////////////////////////////// PRINT A FACTOR OF THE FUNCTION
print_factor macro sig, num, x
  .if num != 0  ;if the num is 0 just ignore the factor
    print sig   ;prints the sign
    print space ;prints a space
    print_number num ; prints the coefficient value
    print x     ;prints the exponent
  .endif
endm

;//////////////////////////////////// PRINT A FACTOR OF THE FUNCTION (INTEGRAL)
print_ifactor macro sig, num, x, dvs
  .if num != 0  ;if the num is 0 just ignore the factor
    print sig   ;prints the sign
    print space ;prints a space
    print_number num ;prints the num
    .if dvs != 1 ;if the value of the dvs is not 1
      print dv
      print_number dvs ;prints the value
    .endif
    print x
  .endif
endm

;//////////////////////////////////// DRAW A PIXEL ON VIDEO MODE (13H)
pixel macro x0, y0, color
  push cx
  mov ah, 0ch
  mov al, color
  mov bh, 0h
  mov dx, y0
  mov cx, x0
  int 10h
  pop cx
endm

;//////////////////////////////////// PRINT ANY "STRING"
print macro _str		;it make the sequence to print a string
	push ax
	push dx
	mov ah,9
	mov dx,offset _str	;display the string passed as messlab
	int 21h				;dos call
	pop dx
	pop ax
endm

;//////////////////////////////////// WRITE ON A FILE ANY VALUE
writef macro _str
	mov ah, 40h
	mov bx, handle
	lea dx, offset _str
	int 21h
	xor cx,cx
endm

;//////////////////////////////////// DRAW A COORDINATE (X, Y)
draw_point macro sx, x, sy, y
  xor eax, eax
  mov ax, 159
  .if sx == '-'
    sub ax, x
  .else
    add ax, x
  .endif
  mov x, ax

  xor eax, eax
  mov ax, 99
  .if sy == '-'
    add ax, y
  .else
    sub ax, y
  .endif
  mov y, ax
  .if y <= 200
    pixel x, y, 26h
  .endif
endm

;//////////////////////////////////// RETURN THE VALUE OF A POW IN THE VALUE VAR
pow macro base, exp, scale
  xor si, si
  xor eax, eax
  xor ebx, ebx
  mov ebx, 99
  mov si, exp
  mov ax, base
  .if si == 1
    mul ebx
  .elseif si == 2
    mul eax
    mul ebx
  .elseif si == 3
    mul eax
    mul ebx
    xor ebx, ebx
    mov bx, base
    mul ebx
  .elseif si == 4
    mul eax
    mul ebx
    xor ebx, ebx
    mov bx, base
    mul ebx
    mul ebx
  .endif
  xor ebx, ebx
  mov ebx, scale
  .while si != 0
    xor edx, edx
    div ebx
    dec si
  .endw
  mov base, ax
endm

;//////////////////////////////////// RETURN THE ADD OF TWO VALUES WITH SIGN ON THE FIRST VAR
sum macro z1, m1, z2, m2
  xor ax, ax
  xor bx, bx
  mov ax, m1    ;moves the fist value
  mov bx, m2    ;moves the second value
    .if z1 == '-' && z2 == '-'  ;if the two values are negative
      add ax, bx                ;just add
      mov z1, '-'               ;and the sign is '-'
    .elseif (z1 == '-' && z2 == '+') || (z1 == '+' && z2 == '-') ;else
      sub ax, bx                ;is a sub
      xor dx, dx
      mov dx, bx
      and dx, 1000000000000000b
      .if dx == 8000h           ;if is a negative ans
        neg ax                  ;get the real value
        mov z1, '-'             ;and the sign is '-'
      .else
        mov z1, '+'             ;else is a positive ans, and the sign is '+'
      .endif
    .else
      add ax, bx                ;else just add
      mov z1, '+'               ;and the sign is '+'
    .endif
  mov m1, ax
endm

;//////////////////////////////////// RETURN THE VALUE OF A POINT VALUATED IN ORIGINAL FUNCTION
valuate macro po, spo, sy, y, scale
  xor ax, ax
  mov ax, po
  mov t, ax
  pow t, 4, scale
  xor ax, ax
  mov ax, t
  mov sst, '+'
  xor bx, bx
  mov bx, n4
  mul bx
  mov y, ax
  .if s4 == '-'
    mov sy, '-'
  .else
    mov sy, '+'
  .endif


  xor ax, ax
  mov ax, po
  mov t, ax
  pow t, 3, scale
  xor ax, ax
  mov ax, t
  .if spo == '-'
    mov sst, '-'
  .else
    mov sst, '+'
  .endif
  xor bx, bx
  mov bx, n3
  mul bx
  mov t, ax
  .if (s3 == '-' && sst == '+') || (s3 == '+' && sst == '-')
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, po
  mov t, ax
  pow t, 2, scale
  xor ax, ax
  mov ax, t
  mov sst, '+'
  xor bx, bx
  mov bx, n2
  mul bx
  mov t, ax
  .if s2 == '-'
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, po
  xor bx, bx
  mov bx, spo
  mov sst, bx
  xor bx, bx
  mov bx, n1
  mul bx
  mov t, ax
  .if (s1 == '-' && sst == '+') || (s1 == '+' && sst == '-')
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, n0
  mov t, ax
  xor ax, ax
  mov ax, s0
  mov sst, ax

  sum sy, y, sst, t
endm

;//////////////////////////////////// RETURN THE VALUE OF A POINT VALUATED IN DERIVATE FUNCTION
valuated macro po, spo, sy, y, scale
  mov sy, '+'
  mov y, 0
  xor ax, ax
  mov ax, po
  mov t, ax
  pow t, 3, scale
  xor ax, ax
  mov ax, t
  .if spo == '-'
    mov sst, '-'
  .else
    mov sst, '+'
  .endif
  xor bx, bx
  mov bx, d3
  mul bx
  mov t, ax
  .if (ds3 == '-' && sst == '+') || (ds3 == '+' && sst == '-')
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, po
  mov t, ax
  pow t, 2, scale
  xor ax, ax
  mov ax, t
  mov sst, '+'
  xor bx, bx
  mov bx, d2
  mul bx
  mov t, ax
  .if ds2 == '-'
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, po
  xor bx, bx
  mov bx, spo
  mov sst, bx
  xor bx, bx
  mov bx, d1
  mul bx
  mov t, ax
  .if (ds1 == '-' && sst == '+') || (ds1 == '+' && sst == '-')
    mov sst, '-'
  .else
    mov sst, '+'
  .endif

  sum sy, y, sst, t

  xor ax, ax
  mov ax, d0
  mov t, ax
  xor ax, ax
  mov ax, ds0
  mov sst, ax

  sum sy, y, sst, t
endm


.386
.data
  scale dd 0
  dv db "/","$"
  fx db "f(x) = ","$"
  fxi db "F(x) = ","$"
  fxd db "f'(x) = ", "$"
  space db " $"
  tab   db "  $"
  break db 13,10,"$"
  dbreak db 13, 10, 13, 10, "$"

  c0 db "x0s coefficient: ",13,10,"$"
  c1 db "x1s coefficient: ",13,10,"$"
  c2 db "x2s coefficient: ",13,10,"$"
  c3 db "x3s coefficient: ",13,10,"$"
  c4 db "x4s coefficient: ",13,10,"$"
  cons db  "+ c","$"

  x0 db " ","$"
  x1 db "*x ","$"
  x2 db "*x2 ","$"
  x3 db "*x3 ","$"
  x4 db "*x4 ","$"
  x5 db "*x5 ","$"

  ;/////// Vars for coefficients values
  n0 dw 0,"$"
  n1 dw 0,"$"
  n2 dw 0,"$"
  n3 dw 0,"$"
  n4 dw 0,"$"

  d0 dw 0, "$"
  d1 dw 0, "$"
  d2 dw 0, "$"
  d3 dw 0, "$"

  ;////// Vars for coefficients signs
  s0 dw 0,"$"
  s1 dw 0,"$"
  s2 dw 0,"$"
  s3 dw 0,"$"
  s4 dw 0,"$"

  ds0 dw 0,"$"
  ds1 dw 0,"$"
  ds2 dw 0,"$"
  ds3 dw 0,"$"

  x dw 0
  y dw 0

  sx dw 0
  sy dw 0

  cpi db "Graph Range", 13, 10, 13, 10, "start point: ","$"
  cpf db "finish point: ", "$"
  pi dw 0
  pf dw 0

  spi dw 0
  spf dw 0

  x3c dw 0
  x4c dw 0

  tmp db 0

  t dw 0,"$"
  sst dw 0, "$"

  tt dw 0, "$"

  gr db 0

  novalid db 0

  header db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA",13,10
         db "FACULTAD DE INGENIERIA",13,10
         db "ESCUELA DE CIENCIAS Y SISTEMAS",13,10
         db "ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1 A",13,10
         db "SEGUNDO SEMESTRE 2017",13,10
         db "FERNANDO JOSUE FLORES VALDEZ",13,10
         db "201504385",13,10,13,10,'$'

  menu_header db "        ___         ___         ___         ___     ",13,10
         db "       /\__\       /\  \       /\__\       /\__\     ",13,10
         db "      /::|  |     /::\  \     /::|  |     /:/  /       1. Enter Function f(x)",13,10
         db "     /:|:|  |    /:/\:\  \   /:|:|  |    /:/  /        2. Memory Function",13,10
         db "    /:/|:|__|__ /::\~\:\  \ /:/|:|  |__ /:/  /  ___    3. Derivative f'(x)",13,10
         db "   /:/ |::::\__/:/\:\ \:\__/:/ |:| /\__/:/__/  /\__\   4. Integral F(x)",13,10
         db "   \/__/~~/:/  \:\~\:\ \/__\/__|:|/:/  \:\  \ /:/  /   5. Graph Functions",13,10
         db "         /:/  / \:\ \:\__\     |:/:/  / \:\  /:/  /    6. Report",13,10
         db "        /:/  /   \:\ \/__/     |::/  /   \:\/:/  /     7. Exit",13,10
         db "       /:/  /     \:\__\       /:/  /     \::/  /   ",13,10
         db "       \/__/       \/__/       \/__/       \/__/    ",13,10,13,10,13,10,'$'

  zoom db "1. 20%",13,10
       db "2. 40%",13,10
       db "3. 60%",13,10
       db "4. 80%",13,10
       db "5. 100%",13,10,"$"

  menu_graph db "1. Plot Original f(x)",13,10
             db "2. Graph Derivative f(x)",13,10
             db "3. Graph Integral F(x)",13,10
             db "4. Return",13,10,"$"



  novalid_text db "The polynomial that is entered is not valid.",13,10,"$"

  currentf db "Current Function in Memory: ",13,10,"$"
  currentfd db "Derivative of Current Function in Memory: ",13,10,"$"
  currentfi db "Integral of Current Function in Memory:",13,10,"$"

.code
  main proc
    mov     ax, @data
    mov     ds, ax

  MEN:
    .while al != 55
      call clear_screen
      call color
      print header
      print menu_header

      xor ax, ax
      call wait_for_key

      .if al == 49      ;if key pressed is 1
        call fun_input
      .elseif al == 50  ;else if key pressed is 2
        call clear_screen
        call color
        call fun_print
        call wait_for_key
      .elseif al == 51  ;else if key pressed is 3
        call fun_der
      .elseif al == 52  ;else if key pressed is 4
        call fun_intg
      .elseif al == 53  ;else if key pressed is 5
        call graph
      .elseif al == 54  ;else if key pressed is 6

      .else
        call wait_for_key
      .endif
    .endw

    call text_mode

    .exit
  main endp

  ;/////////////////////////////////////////////////////////////////////////// LOADS THE FUNCTION VALUES ON MEMORY
  fun_input proc
    mov novalid, 0;clear the var
    mov n0, 0     ;clear the var
    mov n1, 0     ;clear the var
    mov n2, 0     ;clear the var
    mov n3, 0     ;clear the var
    mov n4, 0     ;clear the var
    mov s0, 0     ;clear the var
    mov s1, 0     ;clear the var
    mov s2, 0     ;clear the var
    mov s3, 0     ;clear the var
    mov s4, 0     ;clear the var

    call clear_screen
    call color
    print c4      ;prints request
    read_number n4, s4 ;read number and sign
    print c3      ;prints request
    read_number n3, s3 ;read number and sign
    print c2      ;prints request
    read_number n2, s2 ;read number and sign
    print c1      ;prints request
    read_number n1, s1 ;read number and sign
    print c0      ;prints request
    read_number n0, s0 ;read number and sign

    .if novalid == 1  ;if reads a no valid char
      print novalid_text  ;prints an alert
    .endif

    call wait_for_key
    ret
  fun_input endp

  ;/////////////////////////////////////////////////////////////////////////// PRINTS THE CURRENT FUNCTION ON MEMORY
  fun_print proc
    print currentf
    print fx
    print_factor s4, n4, x4 ;prints the sign, number (only if the number is different form 0)
    print_factor s3, n3, x3 ;prints the sign, number (only if the number is different form 0)
    print_factor s2, n2, x2 ;prints the sign, number (only if the number is different form 0)
    print_factor s1, n1, x1 ;prints the sign, number (only if the number is different form 0)
    print_factor s0, n0, x0 ;prints the sign, number (only if the number is different form 0)
    mov si, 18
    .while si != 0
      print break
      dec si
    .endw
    ret
  fun_print endp

  ;/////////////////////////////////////////////////////////////////////////// PRINTS THE FIRST DERIVATIVE
  fun_der proc
    der s4, n4, 4, ds3, d3
    der s3, n3, 3, ds2, d2
    der s2, n2, 2, ds1, d1
    der s1, n1, 1, ds0, d0

    call clear_screen
    call color

    print currentfd
    print fxd
    print_factor ds3, d3, x3 ;prints the sign, number (only if the number is different form 0)
    print_factor ds2, d2, x2 ;prints the sign, number (only if the number is different form 0)
    print_factor ds1, d1, x1 ;prints the sign, number (only if the number is different form 0)
    print_factor ds0, d0, x0 ;prints the sign, number (only if the number is different form 0)
    print break
    call wait_for_key
    ret
  fun_der endp

  ;/////////////////////////////////////////////////////////////////////////// PRINTS THE FIRST DERIVATIVE
  fun_intg proc
    call clear_screen
    call color

    print currentfi
    print fxi
    mov t, 5
    print_ifactor s4, n4, x5, t ;prints the sign, number (only if the number is different form 0) of the integral
    dec t
    print_ifactor s3, n3, x4, t ;prints the sign, number (only if the number is different form 0) of the integral
    dec t
    print_ifactor s2, n2, x3, t ;prints the sign, number (only if the number is different form 0) of the integral
    dec t
    print_ifactor s1, n1, x2, t ;prints the sign, number (only if the number is different form 0) of the integral
    dec t
    print_ifactor s0, n0, x1, t ;prints the sign, number (only if the number is different form 0) of the integral
    print cons
    print break
    call wait_for_key
    ret
  fun_intg endp

  ;/////////////////////////////////////////////////////////////////////////// GRAPHS THE FUNCTION
  graph proc
    call clear_screen
    call color
    print menu_graph
    call wait_for_key
    .if al == '4'
      ret
    .elseif al == '1'
      mov gr, al
    .elseif al == '2'
      mov gr, al
    .elseif al == '3'
      mov gr, al
    .else
      mov gr, 0
    .endif


    call clear_screen
    call color

    mov pi, 0
    mov pf, 0
    mov spi, 0
    mov spf, 0
    print cpi
    read_number pi, spi
    print cpf
    read_number pf, spf

    xor ax, ax
    .while al != 13
      call clear_screen
      call video_mode
      call show_axes
      call fun_print
      print zoom
      call wait_for_key
      .if  al == '1'
        mov scale, 20
      .elseif al == '2'
        mov scale, 40
      .elseif al == '3'
        mov scale, 60
      .elseif al == '4'
        mov scale, 80
      .elseif al == '5'
        mov scale, 99
      .else
        .break
      .endif


      .if spi == '-' && spf == '+'
        xor cx, cx
        mov cx, pi
          .while cx != 0
            mov sx, '-'
            mov x, cx
            .if gr == '1'
              valuate cx, spi, sy, y, scale
            .elseif gr == '2'
              valuated cx, spi, sy, y, scale
            .elseif gr == '3'

            .endif
            draw_point sx, x, sy, y
            dec cx
          .endw
        mov sx, '-'
        mov x, cx

        .if gr == '1'
          valuate cx, spi, sy, y, scale
        .elseif gr == '2'
          valuated cx, spi, sy, y, scale
        .elseif gr == '3'

        .endif
        draw_point sx, x, sy, y
        xor cx, cx
        mov cx, pf
          .while cx != 0
            mov sx, '+'
            mov x, cx

            .if gr == '1'
              valuate cx, spf, sy, y, scale
            .elseif gr == '2'
              valuated cx, spf, sy, y, scale
            .elseif gr == '3'

            .endif
            draw_point sx, x, sy, y
            dec cx
          .endw
      .elseif spi == '-' && spf == '-'
        xor cx, cx
        mov cx, pi
          .while cx >= pf
            mov sx, '-'
            mov x, cx

            .if gr == '1'
              valuate cx, spi, sy, y, scale
            .elseif gr == '2'
              valuated cx, spi, sy, y, scale
            .elseif gr == '3'

            .endif
            draw_point sx, x, sy, y
            dec cx
          .endw
      .elseif spi == '+' && spf == '+'
        xor cx, cx
        mov cx, pf
          .while cx >= pi
            mov sx, '+'
            mov x, cx

            .if gr == '1'
              valuate cx, spf, sy, y, scale
            .elseif gr == '2'
              valuated cx, spf, sy, y, scale
            .elseif gr == '3'

            .endif
            draw_point sx, x, sy, y
            dec cx
          .endw
      .endif
      call wait_for_key
    .endw
    ret
  graph endp

  ;/////////////////////////////////////////////////////////////////////////// READ KEY
  wait_for_key proc
    mov  ah, 7	;command to read key
    int  21h		;call DOS
    ret
  wait_for_key endp

  ;/////////////////////////////////////////////////////////////////////////// SETS VIDEO MODE CONSOLE
  video_mode proc
    mov ax, 0013h
    int 10h
    ret
  video_mode endp

  ;/////////////////////////////////////////////////////////////////////////// SETS TEXT MODE CONSOLE
  text_mode proc
    mov ax, 0003h
    int 10h
    ret
  text_mode endp

  ;/////////////////////////////////////////////////////////////////////////// CLEAR THE CONSOLE
  clear_screen proc           			;clear the console
    mov  ah, 0
    mov  al, 3
    int  10h
    ret
  clear_screen endp

  ;/////////////////////////////////////////////////////////////////////////// SET CONSOLE COLORS
  color proc
  	mov ax, 0600h
  	mov bh, 0009h
  	mov cx, 0000h
  	mov dx, 184Fh
  	int 10h
    ret
  color endp

  ;/////////////////////////////////////////////////////////////////////////// DRAW THE GRAPH AXES
  show_axes proc
    mov cx, 318   ;sets the highest value on console (x axe)
    x_axs:
    pixel cx, 99, 32h
    loop x_axs     ;loops while cx != 0

    mov cx, 198   ;sets the highest value on console (y axe)
    y_axs:
    pixel 159, cx, 32h
    loop y_axs     ;loops while cx != 0
    ret
  show_axes endp

  PrintNumber proc
  		xor bx, bx
  		xor cx, cx
      mov cx, 0
      mov bx, 10
    @@loophere:
        xor edx, edx
        div bx					;divide by ten

        ; now ax <-- ax/10
        ;     dx <-- ax % 10

        ; print dx
        ; this is one digit, which we have to convert to ASCII
        ; the print routine uses dx and ax, so let's push ax
        ; onto the stack. we clear dx at the beginning of the
        ; loop anyway, so we don't care if we much around with it

        push ax
        add dl, '0'				;convert dl to ascii

        pop ax					;restore ax
        push dx					;digits are in reversed order, must use stack
        inc cx					;remember how many digits we pushed to stack
        cmp ax, 0				;if ax is zero, we can quit
    jnz @@loophere

        ;cx is already set
        mov ah, 2				;2 is the function number of output char in the DOS Services.
    @@loophere2:
        pop dx					;restore digits from last to first
        int 21h					;calls DOS Services
        loop @@loophere2

        ret
  PrintNumber endp

  end main
