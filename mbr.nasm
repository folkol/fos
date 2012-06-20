org     7c00h                   ; We will be loaded here by BIOS INT 0x19. Offset in current segment.
bits    16                      ; Yup... 16bit real mode!
        
        jmp start               ; Unconditional jump to the start label, skipping data

        ;; Text strings
text_greeting       db 'Locating Kernel...', 0
text_kernel_failure db 'Failed to read kernel...', 0        
text_kernel_loaded  db 'Successfully loaded kernel, jumping there!', 0

        ;; Disk address packet structure
DAPACK:
        db  0x10                ; Sixe of packet (16 bytes)
        db  0                   ; Always null
blkcnt: dw  1                   ; int 13 resets this to # of blocks actually read/written
db_add: dw  0x00FF7C00          ; memory buffer destination address (0:7c00)
        dw  0                   ; in memory page zero
d_lba:  dd  1                   ; put the lba to read in this spot
        dd  0                   ; more storage bytes only for big lba's ( > 4 bytes )

        ;; Boot loader entry point
start:
        cli                     ; Disable hardware interrupts, the code is not thread safe!
        sti                     ; Enable hardware interrupts again
        
        mov   si, text_greeting ; Set SI (String index) to 0x7c00:[text_greeting]
        call  print             ; Print routine declared below

        mov   si, DAPACK        ; Point out the data structure decribing the ATA read
        mov   ah, 0x42          ; Function 42 = read from disk to mem
        mov   dl, 0x80          ; What drive (0x80 = first hard drive?)
        int   0x13              ; Call int 13h for disk read
        jc    error

success:        
        mov   si, text_kernel_loaded
        call  print
        jmp end

error:
        mov   si, text_kernel_failure
        call  print
        jmp   end

end:
        jmp $                  ; Jump here, infinite loop $ = current line

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