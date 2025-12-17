#define __SFR_OFFSET 0  // maps lower ports to I/O port numbers (instead of memory-mapped I/O addresses)
#include <avr/io.h>

.global main
.global INT0_vect
.global INT1_vect
.global TIMER1_COMPA_vect
            



;============================================================================
;============================================================================
.text         ;everything following goes to program memory (flash)
;============================================================================
;============================================================================




;============================================================================
main:               
; Main function (does not return) 
;============================================================================
              ;setup
              call  InitData  
              call  InitPorts              
              call  InitTimer
              call  InitInts        
1:            ;main loop
              sei
              cli
              ;see if alarm enabled
              sbis  PIND,5         ;skip next instruction if bit Set
              rjmp  2f 
              ;see if normal time display (we only blink that)
              sbic  PIND,4         ;skip next instruction if bit clear
              rjmp  2f               
              ;check
              lds   r16,Minute
              lds   r17,AlMinute
              cp    r16,r17
              brne  2f
              lds   r16,Hour
              lds   r17,AlHour
              cp    r16,r17
              brne  2f
              ;blink
              lds   r16,Ticks
              andi  r16,1
              breq  1b
2:            ;
              call  UpdateDisplay
              jmp   1b


;============================================================================   
TIMER1_COMPA_vect:
; Interrupt handler for Timer 1 (CTC Mode)
;============================================================================   
              ;save regs
              push  r16
              ;increment ticks
              lds   r16,Ticks
              inc   r16
              andi  r16,3             ;wrap around if at 4
              sts   Ticks,r16         ;does not change flags!
              brne  1f                ;update time only if wraparound
              ;update time
              call  NextSecond
1:            ;restore regs
              pop   r16
              ;return from interrupt
              reti      


;============================================================================   
INT0_vect:    
; Interrupt handler for the "Hour" Button
;============================================================================   
              ;save regs
              push  r16
              push  r17
              push  XL
              push  XH
              ;
              ldi   XL,lo8(Hour)
              ldi   XH,hi8(Hour)    ;same as hi8(AlHour) because of alignment
              sbic  PIND,4
              ldi   XL,lo8(AlHour)  ;XH still good
              ldi   r17,24
              call  IncVar
              ;restore regs
              pop   XH              
              pop   XL
              pop   r17
              pop   r16
              reti


;============================================================================   
INT1_vect:
; Interrupt handler for the "Minute" Button
;============================================================================   
              ;save regs
              push  r16
              push  r17
              push  XL
              push  XH
              ;
              ldi   XL,lo8(Minute)
              ldi   XH,hi8(Minute)    ;same as hi8(AlMinute) because of alignment
              sbic  PIND,4
              ldi   XL,lo8(AlMinute)  ;XH still good
              ldi   r17,60
              call  IncVar
              ;restore regs
              pop   XH              
              pop   XL
              pop   r17
              pop   r16
              reti


;============================================================================              
IncVar:
; Initialize variables in the data section
;----------------------------------------------------------------------------
; In:       X = variable to increment
;           r17 = wraparound value
; Out:      -
; Clobber:  r16
;============================================================================              
              ld    r16,X
              inc   r16
              cp    r16,r17
              brlo  1f
              clr   r16
1:            st    X,r16
              cpi   XL,lo8(Minute)
              breq  2f
              cpi   XL,lo8(Hour)
              brne  3f
2:            clr   r16
              sts   Second,r16
3:            ret


;============================================================================              
InitData:     
; Initialize variables in the data section. 
; This is only needed because the Arduino runtime doesnt do it on WOKWi
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r23
;============================================================================              
              ldi   r16,23
              sts   Hour,r16
              ldi   r16,59
              sts   Minute,r16
              clr   r16
              sts   Second,r16
              ldi   r16,15
              sts   AlHour,r16
              ldi   r16,26
              sts   AlMinute,r16
              ret


;============================================================================ 
InitPorts:    
; Init I/O pin direction and (some) initial line values
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r16
;============================================================================ 
              ;turn all digits off (avoid initial garbage)
              ldi   r16,0x0f          
              out   PORTB,r16       
              ;output mask for port B 
              ldi   r16,0x0f        
              out   DDRB,r16        
              ;output mask for port C   
              ldi   r16,0x3f        
              out   DDRC,r16    
              ;output mask for port D (INTs as input, TX as output) 
              ldi   r16,0b01000010  
              out   DDRD,r16
              ;enable pull-up for INT0/INT1
              ldi   r16,0b00001100  
              out   PORTD,r16
              ret 


;============================================================================ 
InitTimer:    
; Init timer 1 (16-Bit) to 4Hz (CTC with Prescaler /64 and TOP=62500)
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r16
;============================================================================ 
              ;set timer frequency to 16MHz/(62500*64)=4Hz 
              ldi   r16,hi8(62500)  
              sts   OCR1AH,r16
              ldi   r16,lo8(62500)  
              sts   OCR1AL,r16
              ldi   r16,0      
              sts   TCCR1A,r16
              ;set mode to CTC with prescaler /64
              ldi   r16,0b1011      ;WGM12(CTC1)|CS11|CS10
              sts   TCCR1B,r16
              ldi   r16,0
              ;reset timer value to zero
              sts   TCNT1H,r16      
              sts   TCNT1L,r16
              ;reset tick counter
              clr   r16
              sts   Ticks,r16       
              ret


;============================================================================ 
InitInts:     
; Init external interrupts (INT0/INT1) and Timer 1 interrupt
;----------------------------------------------------------------------------
; In:       -
; Out:      I = 1
; Clobber:  r16
;============================================================================ 
              ;init external interrupts (INT0,INT1)
              ldi   r16,0b00001010  ;fire interrupts on falling edge
              sts   EICRA,r16  
              ldi   r16,0
              out   EIFR,r16        ;clear pending external interrupts (just in case)
              ldi   r16,0b00000011 
              out   EIMSK,r16       ;enable external interrupts
              ;init timer 1 output compare interrupt
              ldi   r16,2
              sts   TIMSK1,R16      ;set OCIE1A (Timer1 Output Compare A Interrupt Enable) in Timer 1 Interrupt Mask Register
              ;globally enable interrupts
              sei  
              ;return 
              ret


;============================================================================
UpdateDisplay:
; Update display with alarm time or clock time (depending on switch)
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r16,r22,r23,Z(r30,31)
;============================================================================
              lds   r17,Hour
              lds   r18,Minute
              sbis  PIND,4
              jmp   DisplayTime 
              lds   r17,AlHour
              lds   r18,AlMinute
              jmp   DisplayTime              


;============================================================================
DisplayTime:  
; Show the current time on the display
;----------------------------------------------------------------------------
; In:       r17 = hour
;           r18 = minute
; Out:      -
; Clobber:  r16,r22,r23,Z(r30,31)
;============================================================================
              ;digit 1
              mov   r16,r17
              call  R16Div10
              call  ShowDigit
              ldi   r22,0
              call  EnableDigit
              call  DisableDigit
              ;digit 2
              mov   r16,r17
              call  R16Mod10
              call  ShowDigit
              ldi   r22,1
              call  EnableDigit
              call  DisableDigit
              ;digit 3
              mov   r16,r18
              call  R16Div10
              call  ShowDigit
              ldi   r22,2
              call  EnableDigit
              call  DisableDigit
              ;digit 4
              mov   r16,r18
              call  R16Mod10
              call  ShowDigit
              ldi   r22,3
              call  EnableDigit
              call  DisableDigit
              ;return
              ret


;============================================================================
NextSecond:   
; increment time by one second
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r16
;============================================================================
              ;increment second
              lds   r16,Second
              inc   r16
              cpi   r16,60
              brlo  1f
              clr   r16
              sts   Second,r16
              jmp   2f

1:            sts   Second,r16
              ret

2:            ;increment minute
              lds   r16,Minute
              inc   r16
              cpi   r16,60
              brlo  1f
              clr   r16
              sts   Minute,r16
              jmp   2f

1:            sts   Minute,r16
              ret

2:            ;increment hour
              lds   r16,Hour
              inc   r16
4:            cpi   r16,24
              brlo  1f
              clr   r16
1:            sts   Hour,r16
              ret


;============================================================================
DisableDigit: 
; turn all digits off
;----------------------------------------------------------------------------
; In:       -
; Out:      -
; Clobber:  r23
;============================================================================
              ldi   r23,0x0f
              out   PORTB,r23
              ret


;============================================================================
EnableDigit:  
; turns on exactly one of the digits on the display
;----------------------------------------------------------------------------
; In:       r22 = digit (0-3, l.t.r.)
; Out:      -
; Clobber:  r0, Z(r30,31)
;============================================================================ 
              ldi   ZL,lo8(Digits)
              ldi   ZH,hi8(Digits)
              add   ZL,r22            ;no risk of crossing a 256 byte boundary
              lpm                     ;read from table in program memory to r0
              out   PORTB,r0
              ret

              .p2align  2             ;align to 2^2=4 byte boundary (so table does not cross 256 byte boundary)
Digits:       .dc.b     0b11111110,0b11111101,0b11111011,0b11110111


;============================================================================
ShowDigit:    
; Updates the segment outputs to show the given digit value
;----------------------------------------------------------------------------
; In:       r16 = digit value (0-9)
; Out:      -
; Clobber:  r16, Z(r30,31)
;============================================================================ 
              ldi   ZL,lo8(Segments)
              ldi   ZH,hi8(Segments)
              add   ZL,r16            ;no risk of crossing a 256 byte boundary
              lpm                     ;read segments from program memory
              out   PORTC,r0          ;set segments A-F
              mov   r16,r0            ;andi instruction requires r16 or higher as operand
              ori   r16,0b00001100    ;pull-up for INT0/INT1
              out   PORTD,r16         ;set segment G
              ret

              .p2align  4             ;align to 2^4=16 byte boundary (so table does not cross 256 byte boundary)
Segments:     .dc.b     0b0111111,0b110,0b1011011,0b1001111,0b1100110,0b1101101,0b1111101,0b0111,0b1111111,0b1101111 


;============================================================================ 
R16Div10:
; Divide a value by 10
;----------------------------------------------------------------------------
; In:       r16 = dividend (0-59)
; Out:      r16 = quotient
; Clobber:  Z(r30,31)
;============================================================================ 
              ldi   ZL,lo8(div10)
              ldi   ZH,hi8(div10) 
              add   ZL,r16
              lpm   r16,Z
              ret

              .p2align  6
div10:        .dc.b    0/10,  1/10,  2/10,  3/10,  4/10,  5/10,  6/10,  7/10,  8/10,  9/10 
              .dc.b   10/10, 11/10, 12/10, 13/10, 14/10, 15/10, 16/10, 17/10, 18/10, 19/10
              .dc.b   20/10, 21/10, 22/10, 23/10, 24/10, 25/10, 26/10, 27/10, 28/10, 29/10
              .dc.b   30/10, 31/10, 32/10, 33/10, 34/10, 35/10, 36/10, 37/10, 38/10, 39/10
              .dc.b   40/10, 41/10, 42/10, 43/10, 44/10, 45/10, 46/10, 47/10, 48/10, 49/10
              .dc.b   50/10, 51/10, 52/10, 53/10, 54/10, 55/10, 56/10, 57/10, 58/10, 59/10


;============================================================================ 
R16Mod10:
; Get the remainder (modulo) of dividing a value by 10
;----------------------------------------------------------------------------
; In:       r16 = dividend (0-59)
; Out:      r16 = remainder (dividend%10)
; Clobber:  Z(r30,31)
;============================================================================ 
              ldi   ZL,lo8(mod10)
              ldi   ZH,hi8(mod10) 
              add   ZL,r16
              lpm   r16,Z
              ret

              .p2align  6
mod10:        .dc.b    0%10,  1%10,  2%10,  3%10,  4%10,  5%10,  6%10,  7%10,  8%10,  9%10 
              .dc.b   10%10, 11%10, 12%10, 13%10, 14%10, 15%10, 16%10, 17%10, 18%10, 19%10
              .dc.b   20%10, 21%10, 22%10, 23%10, 24%10, 25%10, 26%10, 27%10, 28%10, 29%10
              .dc.b   30%10, 31%10, 32%10, 33%10, 34%10, 35%10, 36%10, 37%10, 38%10, 39%10
              .dc.b   40%10, 41%10, 42%10, 43%10, 44%10, 45%10, 46%10, 47%10, 48%10, 49%10
              .dc.b   50%10, 51%10, 52%10, 53%10, 54%10, 55%10, 56%10, 57%10, 58%10, 59%10




;============================================================================
;============================================================================
.data         ;everything following goes to data memory (SRAM)
;============================================================================
;============================================================================

;Note:  There is an issue in Wokwi that prevents data defined here from being 
;       properly initialized by the Arduino runtime. Thus, we instead use 
;       InitTime() to initialize the values in the data section a at program 
;       start.

              .p2align  3   ;make sure these vars have the same hi8() addr
Second:       .dc.b 0
Minute:       .dc.b 0
Hour:         .dc.b 0
AlMinute:     .dc.b 0
AlHour:       .dc.b 0
Ticks:        .dc.b 0