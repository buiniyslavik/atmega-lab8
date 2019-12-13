.include "m328Pdef.inc"  
.equ CLK=16000000  
.equ BAUD=9600 
.equ UBRR0_value = (CLK/(BAUD*16)) - 1 
.org 0  
	jmp Reset 
.org 0x0024
	jmp request
.org 0x002e
	jmp badvolt
  Reset:
  ; stack
  ldi r16,low(RAMEND) 
  out spl,r16 
  ldi r16,high(RAMEND)  
  out sph,r16 

  ;comp init
  ldi ACSR, (1<<ACD)|(1<<ACBG)|(1<<ACIS1)|(1<<ACIE)

    ; set portB OUT
  ldi r16,0xFF 
  out DDRB,r16 

    ; EEPROM init
  ldi r25, 0x00
  ldi r24, 0x02
  ldi r23, 0x00
  call EEPROM_read

  ; uart init
  ldi r16, (1<<TXEN0)|(1<<RXEN0)|(1<<RXCIE0)           
  sts UCSR0B,R16 
  ldi r16,(1<< UCSZ00)|(1<< UCSZ01) 
  sts UCSR0C,R16



  main: jmp main

  EEPROM_write:
; sbic EECR,EEPE
; rjmp EEPROM_write
 out EEARH, r25
 out EEARL, r24
 out EEDR,r23
 sbi EECR,EEMPE
 sbi EECR,EEPE
 ret

 EEPROM_read:
;  sbic EECR,EEPE
;  rjmp EEPROM_read
  out EEARH, r25
  out EEARL, r24
  sbi EECR,EERE
  in r23,EEDR
  ret

badvolt:
	inc r23
	call EEPROM_write
	reti

request:
	reti