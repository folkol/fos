org     0x7C00                  ; We will be loaded here by BIOS INT 0x19
bits    16                      ; Yup... 16bit real mode

start:  cli                     ; Clear (Disable) all interrupts
        hlt                     ; Halt the system

times   510 - ($-$$)  db  0     ; fill with zeroes up until 512 (2 bytes away from 512...)

dw      0xAA55                  ; Magic number for bootable sector