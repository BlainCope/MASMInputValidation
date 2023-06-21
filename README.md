Description
This assembly language program allows a user to enter 10 different numbers and then displays the average and sum of the numbers entered.

Author
Blain Cope

Key Procedures and Macros
mGetString

Prompts the user for input and reads a string.
It uses registers edx and ecx for its operation.
mDisplayString

Displays a string to the user.
Uses the edx register.
Introduction

Displays the program introduction to the user.
Prints program name, programmer name, and instructions to the console.
StrToNum

Converts string to number.
On successful conversion, EAX contains the converted number.
calcSumAndAvg

Calculates the sum and truncated average of an array of integers.
Prints sum and truncated average to the console.
ReadVal

Reads a signed integer value from user input.
If successful, EAX contains a signed integer read from the user.
NumToStr

Converts a number to its string representation.
Returns the string representation of the number.
WriteVal

Displays a list of numbers stored in an array.
Outputs the list of numbers with comma and space separators.
farewell

Says goodbye to the user.
Inputs and Outputs
The user is prompted to enter 10 different numbers. The program then calculates and displays the average and sum of these numbers. Each entered number needs to be small enough to fit inside a 32-bit register.

The program output includes a list of the entered integers, their sum, and their average value. The program ends with a farewell message to the user.

Dependencies
This program includes Irvine32.inc and relies on Irvine's library procedures for I/O operations.

Notes
If you enter a number that is too large or is not a signed number, an error message will be displayed and you will be prompted to enter a new value.
