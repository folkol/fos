org     0FF00h                  ; We will be loaded here by the FOS boot loader 0x8f00:0000
bits    16                      ; Yup... 16bit real mode!
        jmp start        

        ;; Text strings
text_greeting db 'Kernel loaded and executing!', 0

        ;; Kernel loader entry point
start:
        mov   si, text_greeting ; Set SI (String index) to 0x7c00:[text_greeting]
        call  print             ; Print routine declared below
        jmp   end

end:
        jmp $                   ; Jump here, infinite loop $ = current line

        ;; print - will print the null terminated string in DS:SI and return
print:                          ; Print string in 
        mov   ah, 0Eh           ; "Write Character in TTY Mode"
print_repeat:
        lodsb                   ; "Load byte at address DS:(E)SI into AL"
        cmp   al, 0             ; Check if byte is \0...
        je    print_done        ; ...and if so, jump to done
        int   10h               ; Call BIOS video interrupt routine (Write char in TTY mode) 
        jmp   print_repeat      ; And repeat
print_done:
        ret

times   512 - ($-$$)  db  0     ; fill with zeroes up until 512, end of code area
