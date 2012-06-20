org     7c00h                   ; We will be loaded here by BIOS INT 0x19
bits    16                      ; Yup... 16bit real mode!
        
jmp     start                   ; Unconditional jump to the start label, skipping data

        ;; Text strings
text_greeting db 'Locating Kernel...', 0

        ;; Kernel location
        

start:
        cli                     ; Disable hardware interrupts, the code is not thread safe!
        sti                     ; Enable hardware interrupts again
        
        mov   si, text_greeting ; Set SI (String index) to 0x7c00:[text_greeting]
        call  print             ; Print routine declared below

        jmp   $                 ; Jump here, infinite loop

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

times   440 - ($-$$)  db  0     ; fill with zeroes up until 440, end of code area

db      6,6,6,0                 ; Our disk signature is 0! (Double word = 4byte)

dw      0                       ; These two bytes are usually null, according to wikipedia

        ;;  Partition table
db      0x80                    ; 0x80 = bootable partition
db      0, 0x81, 0x63           ; cylinder/head/sector
db      0x07                    ; Windows NTFS id
db      0xef, 0xff, 0xff        ; C/H/S of last sector in this partition
dd      0x008cf730              ; logical block address
dd      0x041b5bd0              ; size in sectors of this partition

times   16 db 0                 ; no second partition, first byte 0 for missing or unbootable
times   16 db 0                 ; no third partitinon
times   16 db 0                 ; no fourth partition either!

dw      0xaa55                  ; Magic number for bootable sector