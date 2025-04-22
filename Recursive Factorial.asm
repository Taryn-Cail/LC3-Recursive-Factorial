;************************************************
;* CS2253 Lab 8
;*
;* Purpose: To program n!
;************************************************
 .ORIG x3000          ; Program starts at memory address x3000

    AND R0, R0, #0       ; Clear R0
    ADD R0, R0, #4       ; Set R0 = 2 (we want to calculate 2!)

    LD R6, STACKBASE     ; Load the address of the stack base into R6 (initialize stack pointer)

    JSR FACTORIAL        ; Call the FACTORIAL subroutine

    ST R0, RESULT        ; Store the result of the factorial in memory location labeled RESULT

    HALT                 ; Stop execution

;********************************************
;* Factorial Subroutine
;* Calculates factorial of the value in R0 and returns it in R0
;* Uses stack for recursive calls
;*******************************************

FACTORIAL
    ST R1, SAVER1        ; Save R1
    ST R2, SAVER2        ; Save R2
    ST R3, SAVER3        ; Save R3

    ADD R1, R0, #0       ; Copy R0 to R1
    BRp RECURSE          ; If R1 > 0, branch to RECURSE
    
    ; Base case is if R0 <= 0
    AND R0, R0, #0       ; Set R0 = 0
    ADD R0, R0, #1       ; Set R0 = 1
    RET                  ; Return from subroutine

RECURSE 
    ADD R1, R0, #0       ; Copy input n to R1
    ADD R0, R7, #0       ; Save return address from R7 into R0
    JSR PUSH             ; Push return address onto stack

    ADD R0, R1, #0       ; Restore original input n into R0
    JSR PUSH             ; Push n onto stack

    ADD R0, R0, #-1      ; Compute n - 1
    JSR FACTORIAL        ; call Factorial(n-1)

    ADD R2, R0, #0       ; Store result of FACTORIAL(n-1) in R2

    JSR POP              ; Pop n from the stack
    ADD R1, R0, #0       ; Copy value into R1

    JSR POP              ; Pop return address
    ADD R7, R0, #0       ; Restore return address to R7
    
    ADD R3, R1, #0       ; Set R3 = n (to use as counter in multiplication)
    
    ; Perform R1 * R2
    AND R0, R0, #0
LOOP 
     ; add r1 copies of r2 to itself to get r1*r2
     ADD R0, R0, R2      ; Add R1 to R2
     ADD R3, R3, #-1     ; Decrement counter (R3)
     BRnp LOOP             ; Repeat loop

DONE                      ; Move result of multiplication into R0 (final result)
     RET                 ; Return from subroutine


;*************************************************************************
;* Push Subroutine
;*
;* Purpose: Pushes a value onto a stack
;* Input: A value from R0 onto the stack
;* Output: None
;* Uses R0 and R1 in the method, flags R5 as 1 if the push fails, and 0
;* if it is successful.
;**************************************************************************
PUSH    ST R1, SAVER1       ; Save R1
        LD  R1, NEGSL       ; Load STACKLIMIT into R1
        ADD R1, R6, R1      ; If R6 - STACKLIMIT 
        BRzp    YESPUSH     ; If there is space push the variable
        AND R5, R5, #0
        ADD R5, R5, #1      ; If not set R5 == 1 the flag
        LD R1, SAVER1       ; Restore variables
        RET                 ; Return to Program

YESPUSH ADD R6, R6, #-1     ; Move "top" (R6) - 1
        STR R0, R6, #0      ; Place number into address stored in R6 + 0
        AND R5, R5, #0      ; Set R5 == 0, flag for successful push
        LD  R1, SAVER1      ; Restore variables
        RET                 ; Return to Program


;*************************************************************************
;* Pop Subroutine
;*
;* Purpose: Pops a value from the stack and return it
;* Input: None
;* Output: Value from stack in R0
;* Uses R0 and R1 in the method, flags R5 as 1 if the pop fails, and 0
;* if it is successful.
;**************************************************************************
POP     ST R1, SAVER1       ; Save R1
        LD R1, NEGSB        ; Load STACKBASE into R1
        ADD R1, R6, R1      ; If R6 - STACKBASE
        BRn     YESPOP      ; If there are items in the stack then pop
        AND R5, R5, #0
        ADD R5, R5, #1      ; If not set R5 == 1 the flag
        LD R1, SAVER1       ; Restore variables
        RET                 ; Return to Program
        
YESPOP  LDR R0, R6, #0      ; Place the popped value into R0
        ADD R6, R6, #1      ; Move the pointer "down"
        AND R5, R5, #0      ; Set R5 == 0, flag for successful pop
        LD R1, SAVER1       ; Restore variables
        RET                 ; Return to the program


        
        
; Variables for Subroutines
SAVER1      .BLKW   #1
STACKLIMIT  .FILL   x4000
STACKBASE   .FILL   x5000
NEGSL       .FILL   x-4000
NEGSB       .FILL   x-5000
RESULT      .BLKW   #1
SAVER2      .BLKW   #1
SAVER3      .BLKW   #1

.END
