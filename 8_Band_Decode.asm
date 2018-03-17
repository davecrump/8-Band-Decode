
    #include p16f883.inc
    __config H'2007', 0x23F4
    __config H'2008', 0X3FFF

   ERRORLEVEL -302

; CONFIG1

; 15 0 not used
; 14 0 not used
; 13 1 Debug not  implemented
; 12 0 LVP not implemented            2

; 11 0 Fail safe monitor disabled
; 10 0 IESO Disabled
;  9 1 Brown-out reset enabled
;  8 1 Brown-out reset enabled        3

; 7 1 Data code protection disabled 
; 6 1 Program code protection disabled 
; 5 1 MCLR enabled
; 4 1 Power-up timer disabled         F

; 3 0 Watchdog timer disabled
; 210 100 INTOSCIO Oscillator         4

; CONFIG2

; 15-12 not used                      3

; 11 not used
; 10 1 Flash write protection off
; 9  1 Flash write protection off
; 8  1 Brown-out Reset set to 4.0V    F

; 7 - 4 not used                      F

; 3 - 0 not used                      F
 
; Portsdown 8 Band switching uses 16F883 and internal oscillator
;
; Reads RPi input
; If not a transverter, sets VCO filter as input
; If a transverter, sets VCO filter as switches on Port B.
; Then, if PTT input is active, sets one of 8 band outputs high
; and does it again continually.
; Current drain less than 2 mA

; Hardware Config:

; Sig Pin  Mode                        Portsdown Usage
; === ===  ==========================  ===================
; RA0 (2)  Output                      Transverter 4 Select
; RA1 (3)  Output                      1255 MHz Select
; RA2 (4)  Output                      Transverter 3 Select
; RA3 (5)  Output                      437 MHz Select
; RA4 (6)  Output                      Transverter 2 Select
; RA5 (7)  Output                      146 MHz Select
; RA6 (10) Output                      Transverter 1 Select
; RA7 (9)  Output                      71 MHz Select

; RB0 (21) Input with pull-up          T1 MSB Select
; RB1 (22) Input with pull-up          T1 LSB Select
; RB2 (23) Input with pull-up          T2 MSB Select
; RB3 (24) Input with pull-up          T2 LSB Select
; RB4 (25) Input with pull-up          T3 MSB Select
; RB5 (26) Input with pull-up          T3 LSB Select
; RB6 (27) Input with pull-up          T4 MSB Select
; RB7 (28) Input with pull-up          T5 LSB Select

; RC0 (11) Input                       Band LSB input
; RC1 (12) Input                       Band MSB input
; RC2 (13) Input                       Transverter Select input (active high)
; RC3 (14) Input                       PTT (active high)
; RC4 (15) Output                      Not used, NC
; RC5 (16) Output                      Not used, NC
; RC6 (17) Output                      Band LSB to LO filter
; RC7 (18) Output                      Band MSB to LO filter

; Definitions

;-------PIC Registers-------------------------

INDR		EQU	0x00	; the indirect data register
PCL	        EQU	0x02	; program counter low bits
STATUS		EQU	0x03	; Used for Zero bit
FSR	        EQU	0x04	; the indirect address register
PORTA		EQU	0x05	; 
PORTB		EQU	0x06	; 
PORTC		EQU	0x07	; 
PORTD		EQU	0x08	; 
PORTE		EQU	0x09	; 
PCLATH		EQU	0x0A	; Program Counter High Bits
INTCON		EQU	0x0B	; Interrupt Control
T1CON		EQU	0x10	; Counter Control
SSPBUF		EQU	0x13	; Sync Serial Port Buffer register
SSPCON		EQU	0x14	; Sync Serial Port Control register
ADRESH		EQU	0x1E	; A/D data register
ADCON0		EQU	0x1F	; A/D control register

OPTION_REG	EQU	0x81	; Option Register	
TRISA   	EQU     0x85
TRISB   	EQU     0x86
TRISC   	EQU     0x87
TRISD   	EQU     0x88
TRISE   	EQU     0x89
PINTCON		EQU	0x8B	; INTCON in Page 1
OSCCON		EQU	0x8F	; Internal oscillator control word
SSPCON2		EQU	0x91	; Sync Serial Port Control 2 register
SSPSTAT		EQU	0x94	; Sync Serial Port Status register
WPUB		EQU	0x95	; Weak pull up selects
IOCB		EQU	0x96	; Interupt on change Port B
ADCON1  	EQU     0x9F

EEDATA  	EQU     0x010C
EEADR   	EQU     0x010D
EEDATH  	EQU     0x010E
EEADRH  	EQU     0x010F

ANSEL		EQU	0x0188
ANSELH		EQU	0x0189
EECON1  	EQU 	0x018C
EECON2  	EQU	0x018D

;-------PIC Bits--------------------------------

W	EQU	0	; indicates result goes to working register
F	EQU	1	; indicates result goes to file (named register)
CARRY   EQU	0
ZERO	EQU	2

RP1     EQU     0x06
RP0     EQU     0x05
EEPGD   EQU     0x07
WREN    EQU     0x02
WR      EQU     0x01
RD      EQU     0x00
RBIF	EQU	0x00	; Interrupt Flag
RBIE	EQU	0x03	; Interrupt Enable Flag
GIE	EQU	0x07	; Global Interrupt Enable

;-------Project Registers------------------

RPIN	EQU	0x20   	; RC0 to RC3 as read from RPi input
LOBITS	EQU	0x21	; LO Bits to be output on RC6 and RC7
TTEST	EQU	0x22	; Disposable variable for decision making

;-------Project Bits-------------------------

LSB	EQU	0x00	; RC0 is input Band LSB
MSB	EQU	0x01	; RC1 is input Band MSB
TVTR	EQU	0x02	; RC2 is input transverter select
PTT	EQU	0x03	; RC3 is PTT input
FLSB	EQU	0x06	; RC6 is VCO Filter LSB Output
FMSB	EQU	0x07	; RC7 is VCO Filter MSB Output

T1LSB	EQU	0x01	; RB1 is VCO filter select LSB for T1
T1MSB	EQU	0x00	; RB0 is VCO filter select MSB for T1
T2LSB	EQU	0x03	; RB3 is VCO filter select LSB for T2
T2MSB	EQU	0x02	; RB2 is VCO filter select MSB for T2
T3LSB	EQU	0x05	; RB5 is VCO filter select LSB for T3
T3MSB	EQU	0x04	; RB4 is VCO filter select MSB for T3
T4LSB	EQU	0x07	; RB7 is VCO filter select LSB for T4
T4MSB	EQU	0x06	; RB6 is VCO filter select MSB for T4

;-------START of Program--------------------

    	ORG	0x00		; Load from Program Memory 00 onwards
	GOTO	INIT

;-------Interrupt Vector--------------------

; Not used
	
;------ Set up Internal Oscillator -----------------

	ORG	0x10		; Load from Program Memory 10 onwards
INIT	NOP
	BSF 3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1)

	MOVLW	0x61		; 4 MHz, 
	MOVWF	OSCCON		; and set it

	BCF	3, 5		; Go back to Register Bank x0

;------ Set up IO Ports -----------------
	
	CLRF	PORTA		; Clear output latches
	CLRF	PORTB		; Clear output latches
	CLRF	PORTC		; Clear output latches

	BSF 	3, 5		; Bank x1
	BCF 	3, 6		; Bank 01 (1).  Now set Port directions

	MOVLW 	0x00 		; Initialize data direction
	MOVWF 	TRISA     	; Set RA0-7 as outputs

	MOVLW	0xFF 		; Initialize data direction
	MOVWF	TRISB   	; Set RB0-7 as inputs

	MOVLW	0x0F	   	; Initialize data direction
	MOVWF	TRISC		; Set RC0-3 as inputs
                        	; Set RC4-7 as outputs

	MOVLW	0x7F		; Initialize weak pull up enable
	MOVWF	OPTION_REG	; in the Option Register

	MOVLW	0xFF		; Enable Weak Pull ups
	MOVWF	WPUB		; on Port B DIP Switch
	
	BSF	3, 6		; Bank 11 (3)

	MOVLW	0x00
	MOVWF	ANSEL		; Disable analog inputs on PORT A
	MOVLW	0x00
	MOVWF	ANSELH		; Disable analog inputs on PORT B
	
	BCF	3, 5		; Go back to Register Bank x0
	BCF	3, 6		; Bank 00 (0).

;------ Set Initial Values ----------------------------

	CLRF	PCLATH
	
;------ Start Here -----------------------------------------------

STLOOP	NOP

;------ Read data from port C --------------------

	MOVF	PORTC, W	; Read Input from RPi
	ANDLW	0x0F		; Mask input bits
	MOVWF	RPIN		; Read into RPIN

; ********* First, set the LO Filter *********

; Test if transverter bit not set

	BTFSC	RPIN, TVTR	; Skip next if transverter bit not set
	GOTO	TVTRSEL
	
; Not a transverter, so mirror LSB and MSB from RPi

; Set VCO Filter MSB
	
	BTFSC	RPIN, LSB	; Skip next if RPIN LSB clear
	GOTO	DLSBHI		; LSB is set, so jump
	BCF	PORTC, FLSB	; Set Filter LSB low
	GOTO	DMSB		; Now test MSB
DLSBHI
	BSF	PORTC, FLSB	; Set Filter LSB High
	
DMSB	NOP

; Set VCO Filter MSB

	BTFSC	RPIN, MSB	; Skip next if MSB clear
	GOTO	DMSBHI		; T3MSB is set, so jump
	BCF	PORTC, FMSB	; Set Filter MSB low
	GOTO	SETBAND		; LO Filter Set
DMSBHI	NOP
	BSF	PORTC, FMSB	; Set Filter LSB High
	GOTO	SETBAND		; LO Filter Set
	
TVTRSEL	NOP

; Transverter Selected, so check which transverter

	MOVF	RPIN, W		; Put input state in W
	ANDLW	0x03		; Mask in bottom 2 bits
	MOVWF	TTEST		; and into TTEST
	
; Test if T1

	SUBLW	0x00		; set zero bit if T1
	BTFSS	STATUS, ZERO	; skip next if zero bit not set
	GOTO	TESTT2
	
; Set VCO Filter for T1	LSB

	BTFSC	PORTB, T1LSB	; Skip next if T1LSB clear
	GOTO	T1LSBHI		; T1LSB is set, so jump
	BCF	PORTC, FLSB	; Set Filter LSB low
	GOTO	TT1MSB		; Now test T1 MSB
T1LSBHI	NOP
	BSF	PORTC, FLSB	; Set Filter LSB High
	
TT1MSB	NOP
; Set VCO Filter for T1	MSB

	BTFSC	PORTB, T1MSB	; Skip next if T1MSB clear
	GOTO	T1MSBHI		; T1MSB is set, so jump
	BCF	PORTC, FMSB	; Set Filter MSB low
	GOTO	SETBAND		; LO Filter Set

T1MSBHI	NOP
	BSF	PORTC, FMSB	; Set Filter LSB High
	GOTO	SETBAND		; Lo Filter set
	
TESTT2	NOP
; Test if T2

	MOVF	TTEST, W	; Move selection into W
	SUBLW	0x01		; set zero bit if T2
	BTFSS	STATUS, ZERO	; skip next if zero bit not set
	GOTO	TESTT3
	
; Set VCO Filter for T2	LSB

	BTFSC	PORTB, T2LSB	; Skip next if T1LSB clear
	GOTO	T2LSBHI		; T2LSB is set, so jump
	BCF	PORTC, FLSB	; Set Filter LSB low
	GOTO	TT2MSB		; Now test T2 MSB
T2LSBHI	NOP
	BSF	PORTC, FLSB	; Set Filter LSB High
	
TT2MSB	NOP

; Set VCO Filter for T2	MSB

	BTFSC	PORTB, T2MSB	; Skip next if T1MSB clear
	GOTO	T2MSBHI		; T2MSB is set, so jump
	BCF	PORTC, FMSB	; Set Filter MSB low
	GOTO	SETBAND		; LO Filter Set

T2MSBHI	NOP
	BSF	PORTC, FMSB	; Set Filter LSB High
	GOTO	SETBAND		; Lo Filter set

TESTT3	NOP

; Test if T3

	MOVF	TTEST, W	; Move selection into W
	SUBLW	0x02		; set zero bit if T3
	BTFSS	STATUS, ZERO	; skip next if zero bit not set
	GOTO	TESTT4
	
; Set VCO Filter for T3	LSB

	BTFSC	PORTB, T3LSB	; Skip next if T3LSB clear
	GOTO	T3LSBHI		; T3LSB is set, so jump
	BCF	PORTC, FLSB	; Set Filter LSB low
	GOTO	TT3MSB		; Now test T3 MSB
T3LSBHI
	BSF	PORTC, FLSB	; Set Filter LSB High
	
TT3MSB	NOP

; Set VCO Filter for T1	MSB

	BTFSC	PORTB, T3MSB	; Skip next if T3MSB clear
	GOTO	T3MSBHI		; T3MSB is set, so jump
	BCF	PORTC, FMSB	; Set Filter MSB low
	GOTO	SETBAND		; LO Filter Set
T3MSBHI	NOP
	BSF	PORTC, FMSB	; Set Filter LSB High
	GOTO	SETBAND		; Lo Filter set

TESTT4	NOP
; If flow gets here, must be T4
; Set VCO Filter for T4	LSB

	BTFSC	PORTB, T4LSB	; Skip next if T4LSB clear
	GOTO	T4LSBHI		; T4LSB is set, so jump
	BCF	PORTC, FLSB	; Set Filter LSB low
	GOTO	TT4MSB		; Now test T4 MSB
T4LSBHI
	BSF	PORTC, FLSB	; Set Filter LSB High
	
TT4MSB	NOP
; Set VCO Filter for T4	MSB

	BTFSC	PORTB, T4MSB	; Skip next if T4MSB clear
	GOTO	T4MSBHI		; T4MSB is set, so jump
	BCF	PORTC, FMSB	; Set Filter MSB low
	GOTO	SETBAND		; LO Filter Set
T4MSBHI	NOP
	BSF	PORTC, FMSB	; Set Filter LSB High

SETBAND	NOP

; ****** Set one of the 8 band outputs if required ******

	BTFSC	RPIN, PTT	; Skip next if PTT bit set (active)
	GOTO	SETBOUT
	
; PTT input low, so disable band select

	MOVLW	0x00		; All low
	MOVWF	PORTA		; set Port A
	
	GOTO 	ENDLOOP		; Finished, so start again
	
SETBOUT	NOP

; Look up which band and set PORT A

	MOVF	RPIN, W		; Move input into W
	ANDLW	0x07		; Mask RC0, 1 and 2
	CALL	LUBAND		; Look up the settings for Port A
	MOVWF	PORTA		; set port A

ENDLOOP	GOTO	STLOOP

; ********* End of code flow  **************

; ********* Look-up table for band selection ************

LUBAND	ADDWF	PCL, F		; calculate Program Counter jump based on W (0-7)

        RETLW   0x80    	; 000 sets RA7 71 MHz
        RETLW   0x20    	; 001 sets RA5 146 MHz
        RETLW   0x08    	; 010 sets RA3 437 MHz
        RETLW   0x02    	; 011 sets RA1 1255 MHz
        RETLW   0x40    	; 100 sets RA6 T1
        RETLW   0x10    	; 101 sets RA4 T2
        RETLW   0x04    	; 110 sets RA2 T3
        RETLW   0x01    	; 111 sets RA0 T4
	
        END
