org 0x7c00
bits 16

mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

mov si, welcome 
call print_string 

mov si, about
call print_string

mov si, newline
call print_string

mainloop:
 mov si, prompt
 call print_string

 mov di, buffer
 call get_string

 mov si, buffer
 cmp byte [si], 0
 je mainloop

 mov si, buffer
 mov di, cmd_reboot
 call strcmp
 jc .reboot
 
 mov si, buffer
 mov di, cmd_about
 call strcmp
 jc .about
 
 mov si, buffer
 mov di, cmd_help
 call strcmp
 jc .help

 mov si, buffer
 mov di, cmd_shutdown
 call strcmp
 jc .shutdown
 



 mov si, badcommand
 call print_string
 jmp mainloop

 .reboot:
  int 0x19
  jmp mainloop
 
 .help:
 mov si, msg_help
 call print_string
 jmp mainloop

 .about:
 mov si, msg_about
 call print_string
 jmp mainloop

 .shutdown:
 mov si, msg_about
 call print_string


 
 
welcome db  'Welcome to mackWK', 0x0d, 0x0a, 0
about db  'by www.mackk.xyz', 0x0d, 0x0a, 0
buffer times 64 db 0
prompt db '# ', 0
newline db ' ', 0x0d, 0x0a, 0
badcommand db 'invalid command', 0x0d, 0x0a, 0
cmd_reboot db 'reboot',0
cmd_about db 'about', 0
msg_about db 'by www.mackk.xyz', 0x0d, 0x0a, 0
cmd_help db 'help', 0
msg_help db 'about,help,reboot,shutdown', 0x0d, 0x0a, 0
cmd_shutdown db 'shutdown', 0
msg_shutdown db '                 YOUR SYSTEM IS NOW SAFE TO SHUTDOWN                       ', 0x0d, 0x0a, 0




print_string:
 lodsb
 or al, al
 jz .done 
 
 mov ah, 0x0e
 int 0x10

  jmp print_string


 .done:
   ret

get_string:
 xor cl, cl
 .loop:
   mov ah, 0
   int 0x16

   cmp al, 0x08
   je .backspace
   
   cmp al, 0x0D
   je .done
   
   cmp cl, 0x3F
   je .loop
   
   mov ah, 0x0e
   int 0x10

   stosb
   inc cl
   jmp .loop

   .backspace:
    cmp cl, 0
    je .loop

    dec di
    mov byte [di], 0
    dec cl
    
    mov ah, 0x0e
    mov al, 0x08
    int 0x10

    mov al, ' '
    int 0x10

    mov al, 0x08
    int 0x10

    jmp .loop

    .done:
      mov al,0
      stosb
      
      mov ah, 0x0e
      mov al, 0x0d
      int 0x10
      mov al, 0x0a
      int 0x10

      ret

strcmp:
 .loop:
  mov al, [si]
  mov bl, [di]
  cmp al, bl
  jne .notequal

  cmp al, 0
  je .done

  inc di
  inc si

  jmp .loop

  .notequal:
   clc
   ret
  .done:
    stc
    ret

times 510-($-$$) db 0
dw 0xaa55

