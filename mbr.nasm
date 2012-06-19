org     0x7C00                  ; We will be loaded here by BIOS INT 0x19
bits    16                      ; Yup... 16bit real mode!

start:  
        cli                     ; Clear (Disable) all interrupts
        hlt                     ; Halt the system


times   440 - ($-$$)  db  0     ; fill with zeroes up until 440, end of code area

db      6,6,6,0                 ; Our disk signature is 0! (Double word = 4byte)

dw      0                       ; These two bytes are usually null, according to wikipedia
        
times   16 db 1                 ; 16 byte partition description
times   16 db 1                 ; 16 byte partition description
times   16 db 1                 ; 16 byte partition description
times   16 db 1                 ; 16 byte partition description
        
dw      0xAA55                  ; Magic number for bootable sector