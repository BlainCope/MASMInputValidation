TITLE Project6     (Proj6_copeb.asm)

; Author: Blain Cope
; Last Modified: 3/16/2023
; OSU email address: copeb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: 3/19/2023
; Description: This program will allow a user to enter 10 different numbers and then display the average, and sum of the numbers entered.

INCLUDE Irvine32.inc

; (insert macro definitions here)
;------------------------------------------------------------------------------
; mGetString
; Prompts the user for input and reads a string.
; Receives: prompt (reference), input (reference), inputBuffer (length)
; Returns: none
; Preconditions: all parameters must be passed in the specified registers
; Postconditions: input string is stored at the memory location specified by input
; Registers changed: edx, ecx
;------------------------------------------------------------------------------
mGetString MACRO prompt, input, inputBuffer
    push    edx
    push    ecx
    mov     edx, prompt
    call    WriteString
    mov     edx, input
    mov     ecx, inputBuffer
    call    ReadString
    pop     ecx
    pop     edx
ENDM
	
;------------------------------------------------------------------------------
; mDisplayString
; Displays a string to the user.
; Receives: addStr (reference)
; Returns: none
; Preconditions: addStr must be passed in the specified register
; Postconditions: displays the string at the memory location specified by addStr
; Registers changed: edx
;------------------------------------------------------------------------------
mDisplayString	MACRO addStr
		pushad
		mov		edx, addStr
		call	WriteString
		popad
ENDM

; (insert constant definitions here)
MAX_INPUT		EQU		10
BUFFER_SIZE		EQU		32

.data

; (insert variable definitions here)
	greeting			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0
	greeting2			BYTE	"Written by Blain Cope:",0
	greeting3			BYTE	"Please provide 10 signed decimal integers.",0
	greeting4			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value. ",0
	promptStr 			BYTE	"Please enter a signed number: ",0
	errorStr			BYTE	"You did not enter a signed number or the number was too big",0
	sumStr				BYTE	"Sum: ", 0
	avgStr				BYTE	"Truncated Average: ", 0
    listResult          BYTE    "You entered the following numbers: ",0
    goodbye             BYTE    "Hope everything worked well!",0
	userInput			BYTE	BUFFER_SIZE DUP(0)
	userInputLength		DWORD	?
	inputArray			SDWORD	MAX_INPUT DUP(0)
    stringArray         BYTE    200 DUP(0)
    numToAsciiBuffer     BYTE BUFFER_SIZE DUP(0)
	number				SDWORD	?
	sum					SDWORD	?
    validNumber         SDWORD  ?
	truncatedAverage	SDWORD	0
    comma_space         BYTE    ", ",0

.code
main PROC

; (insert executable instructions here)
    push    OFFSET greeting
    push    OFFSET greeting2
    push    OFFSET greeting3
    push    OFFSET greeting4
    call    Introduction

    mov     ecx, MAX_INPUT
    lea     edi, inputArray
    get_numbers_loop:
    lea     edx, promptStr
    lea     eax, userInput
    lea     esi, userInput
    push    OFFSET errorStr
    call    ReadVal
    mov     [edi], eax
    add     edi, 4
    loop    get_numbers_loop

    lea     esi, inputArray
    lea     edi, stringArray
    push    OFFSET comma_space
    push    OFFSET listResult
    call    WriteVal
    call    CrlF

    lea     esi, inputArray
    lea     edi, numToAsciiBuffer
    push    OFFSET sumStr
    push    OFFSET avgStr
    call    calcSumAndAvg


    push    OFFSET goodbye
    call    farewell





	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)
;------------------------------------------------------------------------------
; Introduction
; Displays the program introduction to the user.
; Receives: programTitle (reference), instructions (reference)
; Returns: none
; Preconditions: all parameters must be passed as offset, and are pushed
;	to the stack in the order specified in the Receives field
; Postconditions: prints program name, programmer name, and instructions to
;	console
; Registers changed: ebp (saved by stack frame setup), edx
;------------------------------------------------------------------------------
Introduction    PROC    USES edx

    push    ebp
    mov     ebp, esp
    mov     edx, [ebp + 24]
    mdisplayString   edx
    call    CrlF

    mov     edx, [ebp + 20]
    mdisplayString   edx
    call    CrlF

    mov     edx, [ebp + 16]
    mdisplayString   edx
    call    CrlF

    mov     edx, [ebp + 12]
    mdisplayString   edx
    call    CrlF
    pop     ebp
    ret     16


Introduction    ENDP

;------------------------------------------------------------------------------
; StrToNum
; Converts string to number.
; Input: ESI - Points to the string
; Output: EAX - Converted number
;         CF - 1 if conversion failed, 0 otherwise
; Preconditions: None
; Postconditions: If successful, EAX contains the converted number
; Registers changed: eax, ecx, edx
;------------------------------------------------------------------------------
StrToNum PROC
    xor eax, eax
    xor ecx, ecx
    cmp BYTE PTR [esi], 0
    je StrToNum_exit

StrToNum_loop:
    lodsb
    cmp al, 0
    je StrToNum_exit
    sub al, '0'
    jb StrToNum_error
    cmp al, 9
    ja StrToNum_error

    ; Check for overflow before multiplying by 10
    mov edx, ecx
    imul edx, edx, 10
    jo StrToNum_error

    ; Check for overflow before adding the digit
    add edx, eax
    jo StrToNum_error

    mov ecx, edx
    jmp StrToNum_loop

StrToNum_error:
    stc
    jmp StrToNum_exit

StrToNum_exit:
    mov eax, ecx
    ret
StrToNum ENDP

;------------------------------------------------------------------------------
; calcSumAndAvg
; Calculates the sum and truncated average of an array of integers.
; Receives: inputArray (reference), numToAsciiBuffer (reference), avgStr (reference)
; Returns: none
; Preconditions: inputArray contains MAX_INPUT integers
; Postconditions: sum and truncated average are printed to the console
; Registers changed: ecx, eax, edx, esi, edi
;------------------------------------------------------------------------------
calcSumAndAvg PROC
    ; Save registers
    pushad

    ; Get the parameters from the stack
    mov     ebp, esp

    ; Calculate the sum
    mov     ecx, MAX_INPUT
    xor     eax, eax
sum_loop:
    add     eax, [esi]
    add     esi, 4
    loop    sum_loop

    ; Display sum
    mov     edx, [ebp + 40]
    mDisplayString edx
    call    NumToStr
    mDisplayString edi
    call    Crlf

    ; Calculate and display the truncated average
    cdq
    mov ecx, MAX_INPUT
    idiv ecx

    ; Display truncated average
    mov     edx, [ebp + 36]
    mDisplayString edx
    call    NumToStr
    mDisplayString edi
    call    Crlf

    ; Restore registers
    popad
    ret     8
calcSumAndAvg ENDP



;------------------------------------------------------------------------------
; ReadVal
; Reads a signed integer value from user input.
; Receives: promptStr (reference), userInput (reference), errorStr (reference)
; Returns: EAX - Read signed integer
; Preconditions: None
; Postconditions: EAX contains a signed integer read from the user
; Registers changed: eax, ecx, edx, edi, esi, ebx
;------------------------------------------------------------------------------
ReadVal PROC USES edi esi ebx ecx edx
    push    ebp
    mov     ebp, esp

    ; Display prompt and read user input
    mGetString edx, eax, BUFFER_SIZE

    ; Check if the input is empty
    cmp     BYTE PTR [esi], 0
    je      error

    ; Initialize registers for conversion and validation
    xor     edi, edi
    xor     ebx, ebx
    cmp     BYTE PTR [esi], '-'
    jne     check_positive
    inc     esi
    mov     ebx, 1
    jmp     convert_validate

check_positive:
    cmp     BYTE PTR [esi], '+'
    jne     convert_validate
    inc     esi

convert_validate:
    ; Convert and validate input
    call    StrToNum
    jc      error

    ; Check if the input is negative and adjust the value accordingly
    test    ebx, 1
    jz      check_range
    neg     ecx

check_range:
    ; Check if the value is within the range of a 32-bit signed integer
    cmp     ecx, -2147483648 ; lower bound
    jl      error
    cmp     ecx, 2147483647 ; upper bound
    jg      error

    mov     eax, ecx        ; Move the value from ECX to EAX before storing it

store_value:
    ; Store the value in the output parameter
    pop     ebp
    ret     4

error:
    ; Display error message and retry reading a valid value
    push    edx
    mov     edx, [ebp + 24]
    mDisplayString edx
    pop     edx
    jmp     ReadVal

ReadVal ENDP



;------------------------------------------------------------------------------
; NumToStr
; Converts a number to its string representation.
; Recieves: EAX - Number to be converted
; Returns: EDI - Points to the converted string (null-terminated)
; Preconditions: None
; Postconditions: EDI points to the null-terminated string representation of the number
; Registers changed: eax, ecx, edx, edi
;------------------------------------------------------------------------------
NumToStr PROC
    pushad
    pushfd

    ; Check if the number is negative
    test eax, eax
    jns NumToStr_positive
    neg eax
    mov BYTE PTR [edi], '-'
    inc edi

NumToStr_positive:
    ; Reverse the number and count the digits
    xor ecx, ecx
    mov ebx, 10

NumToStr_reverse_loop:
    xor edx, edx
    idiv ebx
    push dx
    inc ecx
    test eax, eax
    jnz NumToStr_reverse_loop

    ; Pop and store the digits
NumToStr_store_loop:
    pop dx
    add dl, '0'
    mov al, dl
    stosb ; Store digit in AL and increment EDI
    loop NumToStr_store_loop

    ; Null-terminate the string
    mov BYTE PTR [edi], 0

    popfd
    popad
    ret
NumToStr ENDP


;------------------------------------------------------------------------------
; WriteVal
; Displays a list of numbers stored in an array.
; Receives: esi (register) - Points to the input array
;           ebp+28 (stack) - Offset of the string for the result list introduction
;           ebp+32 (stack) - Offset of the string for the comma and space separator
; Returns: none
; Preconditions: esi must point to a valid array of MAX_INPUT signed 32-bit integers
; Postconditions: Outputs the list of numbers with comma and space separators
; Registers changed: ecx, eax, edx, esi, edi
;------------------------------------------------------------------------------
WriteVal PROC USES edi esi ebx ecx edx
    push ebp
    mov ebp, esp
    mov ecx, MAX_INPUT
    push    edx
    mov     edx, [ebp + 28]
    mDisplayString edx
    pop     edx

WriteVal_loop:
    mov eax, [esi]
    call NumToStr

    ; Print the converted number
    mDisplayString edi

    ; Add a comma and space if there are more numbers
    dec ecx
    jz WriteVal_exit
    push edx
    mov edx, [ebp + 32]
    mDisplayString edx
    pop edx
    add esi, 4
    jmp WriteVal_loop

WriteVal_exit:
    pop ebp
    ret 8

WriteVal ENDP



;------------------------------------------------------------------------------
; farewell
; Says goodbye to user.
; Receives: ebp+8 (stack) - Offset of the string for the goodbye string
; Returns: none
; Preconditions: None
; Postconditions: None
; Registers changed: edx
;------------------------------------------------------------------------------
farewell PROC

    push    ebp
    mov     ebp, esp
	mov     edx, [ebp + 8]
	mDisplayString edx
	call    Crlf

farewell ENDP
 
END     MAIN
