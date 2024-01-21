/*
Name: Alex Tanasescu
Course:	CPSC 355
Lecture 01 Tutorial 3
Project Part 2

Comment with a ^ at the very start are referring to the line above it
*/

.data		            //Used for initializing data and constants
arrayCount = 20 		//Number of max elements we can have
arraySize =-(20*20*4)		//Max size our table can be is 10 by 10 times 2 bytes each

alloc = -(16) & -16 //^Allocating memory for the 1 2d arrays and the 2 1d arrays plus the usual
dealloc = -alloc




newLine: .string "\n"   //Strings for a new line
inputSpace: .string "%d " //Format specifer with a space
input: .string "%d" //Format specifier without space
xSpace: .string "X " //x with a space
xyPrompt: .string "Enter your move (x, y): " //Prompt for coordinates
bombString: .string "Bang! You lost %d points\n" //Lost points string
rewardString: .string "You gained %d points\n" //Gained points string
scoreString: .string "Score: %d\n"  //Score string
timeString:  .string "Time Remaining: %d\n" //Time remainging string
exitString: .string "Thanks for playing! Have a good day!\n" //Thanks user for playing
invalidString: .string "Please run the program again and enter a valid length from 5 to 20\n"//Invalid string
timeUpString: .string "Time's up!\n" //Lets user know theyre time is up
loseString: .string "You lose!\n" //Lets user know they lost
bonusTimeString: .string "10 second have been added to your time!\n"



num:	.word 0			    //A variable to hold the user input
        .text			    //Used for keeping the actual code
	
    .balign 4		        //advances the location counter until it is a multiple of 4
	.global main		    //must be declared for the linker (gcc)


define(userInput, x19)
define(xCoord, w20)
define(yCoord, w21)
define(timer, x22)
define(score, x25)

main:
	//Start of function
	stp fp, lr, [sp, alloc]! //Stores the content of the pairs of registers to the given stack and allocates 16 bytes of  					stack memory plus whatever else we need
	mov fp, sp 		        //Updates frame pointer to stack pointer
    add sp, sp, arraySize   //Allocates the max arraySize
    mov w9, 2               //Increases offset by 2
    ldr x0, [x1, w9, SXTW 3]  //Takes in command line argument       
    
    //Converts user input to a string
    bl  atoi
    mov userInput, x0
    str userInput, [fp, 16] //Stores in x19

    cmp userInput, 4
    b.le invalid
    cmp userInput, 21
    b.ge invalid


    //Multiplies timer by 12 based on length
    mov x1, 12      
    mul timer, userInput, x1 

    mov x0, 0               //Initializes x0 to 0
    bl  time                //Import time library to seed
    bl  srand               //Uses srand for seeding random num
    
    mov x0, userInput             //Initializes user input length as first argument for subroutine
    add x8, x29, 16         //Adds 16 bytes plus fp to base address
   // mov x15, 0
    bl initialize
    mov score, 0
loop:
    mov x0, userInput             //Initializes user input length as first argument for subroutine
    add x8, x29, 16         //Adds 16 bytes plus fp to base address 
	
    bl  display             //Calls display subroutine

    adrp x0, xyPrompt //Writes inputSpace to x0
    add  x0, x0, :lo12:xyPrompt//Uses lower 12 bits of the expressions
    bl   printf         //Prints the statement


    //Logs start time before asking for user input
    mov x0, 0
    bl  time
    mov x27, x0

    adrp x0, input		//Writes the input string  to register x0
	add  x0, x0, :lo12:input//Use the lower 12 bits of the expression      					value
	adr  x1, num		//Stores the variable num in register x1
	bl   scanf 		//Scans for user input
	adr  x1, num		//Stores the variable num in register x1 after 					scanning
	ldr  xCoord, [x1]		//Loads a doubleword from memory to register

    adrp x0, input		//Writes the input string  to register x0
	add  x0, x0, :lo12:input//Use the lower 12 bits of the expression      					value
	adr  x1, num		//Stores the variable num in register x1
	bl   scanf 		//Scans for user input
	adr  x1, num		//Stores the variable num in register x1 after 					scanning
	ldr  yCoord, [x1]		//Loads a doubleword from memory to register

    //Logs time after asking for user input
    mov x0, 0
    bl  time
    mov x28, x0

    //Calculates time remaining
    sub x27, x28, x27
    sub timer, timer, x27

    //Prints how much time reamins
    mov x1, timer
    adrp x0, timeString
    add  x0, x0, :lo12:timeString
    bl printf
    
    //Initializes base address before calculating the socre
    add x8, x29, 16
    bl  calcScore


    //Checks to see if current score less than or equal to 0 to initiate game ove
    cmp score, 0
    b.le youLose

    

    //Checks to see if timer is 0 if it is exit game
    cmp  timer, 0
    b.gt loop
    b.le timesUp
    

    //Close the pgroam
    b  done

youLose:
    adrp x0, loseString
    add x0, x0, :lo12:loseString
    bl printf
    b  done

timesUp:
    adrp x0, timeUpString
    add x0, x0, :lo12:timeUpString
    bl printf
    b  done

//Prints a string to let the user know they type in an invalid amount
invalid:
    adrp x0, invalidString
    add x0, x0, :lo12:invalidString
    bl printf
    b  done


randomNum:              //Branch label for randomNum
	stp x29, x30, [sp, -16]!  //Stores the content of the pairs of registers to the given stack and allocates 16 bytes of  					stack memory plus whatever else we need
 	mov x29, sp	         //Updates frame pointer to stack pointer
	mov x9, 5

    randNum:            //Branch label for randomNum
        bl  rand        //Generates random Number
        and x0, x0, 0xF //Between 0 and 15
        cmp x0, 14       //Check to see if its greater than 14
        b.gt randNum    //If it loop back around to generate another random number
        add x0, x0, 1   //Adds 1 to the random number so its now between 1-15

    mul x23, userInput, userInput
    udiv x23, x23, x9
    mov  x1, x23
    mov x2, 0

	ldp x29, x30, [sp], 16 //Loads the pair of registers from the RAM and restores their states and deallocates what we allocated
	ret                 //Returns control to calling code

randomBonus:              //Branch label for randomNum
	stp x29, x30, [sp, -16]!  //Stores the content of the pairs of registers to the given stack and allocates 16 bytes of  					stack memory plus whatever else we need
 	mov x29, sp	         //Updates frame pointer to stack pointer
	mov x9, 5

    randBonus:            //Branch label for randomNum
        //mov x0, 0
        bl  rand        //Generates random Number
        and x0, x0, 0xF //Between 0 and 15
        cmp x0, 2      //Check to see if its greater than 14
        b.gt randBonus    //If it loop back around to generate another random number
        add x0, x0, 16   //Adds 1 to the random number so its now between 1-15

    mul x23, userInput, userInput
    udiv x23, x23, x9
    mov  x1, x23
    mov x2, 0

	ldp x29, x30, [sp], 16 //Loads the pair of registers from the RAM and restores their states and deallocates what we allocated
	ret                 //Returns control to calling code



initialize:             //Branch label for initialize
	stp x29, x30, [sp, -48]! //Stores the content of the pairs of registers to the given stack and allocates 48 bytes of  stack memory plus whatever else we need
	mov x29, sp         //Updates frame pointer to stack pointer
	
    mov x12, x0         //Stores length into x12
    mov x9, 0           //initialize I count to 0
    mov x10, 0          //initialize J Count to 0
    mov x24, 1
    initLoop1:          //Start of first loop for initialize
        cmp x9, x12     //Compares first loop count to length
        b.ge init1Done  //If its greater or equal branches to init1Done
        
        initLoop2:      //Start of second loop for initalize
            cmp x10, x12//Compares second loop count to length
            b.ge init2Done //If its greater branches to init2Done

            mov x11, 16 //Initializes offset to 16
            str x12, [x29, x11] //Stores x12 to stack
            add x11, x11, 4 //Adds 4 to offset
            str x9, [x29, x11] //Stores x9 to stack
            add x11, x11, 4 //Adds 4 to offset
            str x10, [x29, x11] //Stores 10 to stack
            add x11, x11, 4 //Adds 4 to offset
            str x8, [x29, x11] //Stores x8 to stack
            

            bl  randomNum   //Calls randomNum subroutine
            
            
            cmp x24, x1
            b.gt next
            sub x0, xzr, x0
            add x24, x24, 1
            


        next:
            mov x11, 16     //Initializes offset to 16 again
            ldrh w12, [x29, x11] //Loads x12 from stack
            add x11, x11, 4 //Adds 4 to offset
            ldrh w9, [x29, x11] //Loads x9 from stack
            add x11, x11, 4//Adds 4 to offset
            ldrh w10, [x29, x11] //Loads x10 from stack
            add x11, x11, 4//Adds 4 to offset
            ldr x8, [x29, x11]  //Loads x9 from stack

            //Calculates offset
            mul x11, x9, x12 //Multiples i count by length and stores in x11
            add x11, x11, x10 //Adds j count to to x11
            lsl x11, x11, 2   //Shifts offset by 2
            str x0, [x8, x11] //Storez x0 to stack

            
            add x10, x10, 1 //Increments j count by 1
            b   initLoop2   //branches initLoop2

        init2Done:          //branch label for init2Done
            add x9, x9, 1   //Increments i count by 1
            mov x10, 0      //Initializes j count to 0
            b   initLoop1   //Branch label for initLoop1
        
    init1Done:          //branch label for init1Done
    ldp x29, x30, [sp], 48 //Loads pair of registers from stack and deallocates 48 bytes
    ret                 //Returns control to calling code

display:                //Branch label for dipslay
	stp x29, x30, [sp, -48]! //Stores the content of pair of register to the stack and allocates 48 bytes of memory
	mov x29, sp             //Updates frame pointer to stack pointer
	
    mov x12, x0 //Stores length into x12
    mov x9, 0   //initialize I count to 0
    mov x10, 0  //initialize J Count to 0
    
    displayLoop1:       //Branch label for displayLoop1
        cmp x9, x12     //Checks to see if i count is greate or equal to length
        b.ge display1Done//If it it branch to display1Done
        
        displayLoop2:
            cmp x10, x12//Checks to see if j count is greate or equal to length
            b.ge display2Done//If it it branch to display2Done

            mov x11, 16 //Initializes x11 to 16
            str x12, [x29, x11] //Stores x12 to stack
            add x11, x11, 4 //Adds 4 to the offset
            str x9, [x29, x11]//Stores x9 to stack
            add x11, x11, 4//Adds 4 to the offset
            str x10, [x29, x11]//Stores x10 to stack
            add x11, x11, 4//Adds 4 to the offset
            str x8, [x29, x11]//Stores x8 to stack

            //Caluclates offset
            mul x11, x9, x12    //Multiples i count by length and stores in x11 - offset
            add x11, x11, x10   //Adds j count to offset
            lsl x11, x11, 2     //Shift offset left by 2
            ldr x1, [x8, x11]   //Loads x1 from stack
/* 
             adrp x0, inputSpace //Writes inputSpace to x0
            add  x0, x0, :lo12:inputSpace //Uses lower 12 bits of the expressions
            bl   printf          //Prints the statemetn
 */
            adrp x0, xSpace //Writes inputSpace to x0
            add  x0, x0, :lo12:xSpace //Uses lower 12 bits of the expressions
            bl   printf         //Prints the statemetn

            mov x11, 16 //Initializes x11 to 16
            ldrh w12, [x29, x11]    //Loads x12 from stakc
            add x11, x11, 4//Adds 4 to the offset
            ldrh w9, [x29, x11]     //Loads x9 from stakc
            add x11, x11, 4//Adds 4 to the offset
            ldrh w10, [x29, x11]    //Loads x10 from stack
            add x11, x11, 4//Adds 4 to the offset
            ldr x8, [x29, x11]      //Loads x8 from stack

            add x10, x10, 1         //Increments j count by 1
            b   displayLoop2        //Branch to displayLoop2

    
        display2Done:           //branch label for display2Done
            mov x11, 16         //Initializes x11 to 16
            str x12, [x29, x11]//Stores x12 to stack
            add x11, x11, 4 //Adds 4 to x11 - offset    
            str x9, [x29, x11]//Stores x9 to stack
            add x11, x11, 4//Adds 4 to x11 - offset
            str x10, [x29, x11]//Stores x10 to stack
            add x11, x11, 4//Adds 4 to x11 - offset
            str x8, [x29, x11]//Stores x8 to stack


            adrp x0, newLine //Writes newLine to x0
            add x0, x0, :lo12:newLine   //Uses lower 12 bits of the expression
            bl  printf      //Prints the statement

            mov x11, 16     //Initializes x11 to 16
            ldrh w12, [x29, x11] //Loads x12 from stack
            add x11, x11, 4//Adds 4 to x11 - offset
            ldrh w9, [x29, x11]  //Loads x9 from stack
            add x11, x11, 4//Adds 4 to x11 - offset
            ldrh w10, [x29, x11] //Loads from x10
            add x11, x11, 4//Adds 4 to x11 - offset
            ldr x8, [x29, x11]  //Loads x8 from stack

            add x9, x9, 1   //Increments i count by 1
            mov x10, 0      //Initializes j count to 0
            b   displayLoop1 //branch to displayLoop1
            
    display1Done:   //Branch label for display1Done
    ldp x29, x30, [sp], 48  //Loads contents of pair of register and deallocates 48 bytes
    ret             //Return to calling code

calcScore:
    stp x29, x30, [sp, -48]!
    mov x29, sp
   

    mul x11, x20, userInput    //Multiples i count by length and stores in x11 - offset
    add x11, x11, x21   //Adds j count to offset
    lsl x11, x11, 2     //Shift offset left by 2
    ldr x0, [x8, x11]   //Loads x1 from stack
    mov x26, x0

    //Increments the socre
    add  score, score, x0

    //Moves the score to argument so it can be printed out
    mov x1, score
    
    //Prints the score string along with the score
    adrp x0, scoreString
    add x0, x0, :lo12:scoreString
    bl printf

    //Checks to see if the points are positive or negative
    //And branch to the respective label
    mov x1, x26
    cmp  x26, 0
    b.ge addScore
    b.lt subScore

    //If score is positive print out the reward string along with how many points were gained
    //And then branch to end of function
    addScore:
        adrp x0, rewardString
        add x0, x0, :lo12:rewardString
        bl printf
        cmp x26, 11
        b.eq bonusTime
        cmp x26, 12
        b.eq bonusTime
        cmp x26, 13
        b.eq bonusTime
        cmp x26, 14
        b.eq bonusTime
        cmp x26, 15
        b.eq bonusTime
        b  calcDone
    
    //If score is positive print out the bomb string along with how many points were lost
    //And then branch to end of function
    subScore:
        adrp x0, bombString
        add x0, x0, :lo12:bombString
        bl printf
        b  calcDone

    //Adds 10 seconds and prints bonusTimeString
    bonusTime:
        adrp x0, bonusTimeString
        add x0, x0, :lo12:bonusTimeString
        bl printf
        add timer, timer, 10
        b calcDone
    
    //End of the calc score function
    calcDone:

        ldp x29, x30, [sp], 48  //Loads contents of pair of register and deallocates 48 bytes
        ret             //Return to calling code

//Exit game function
exitGame:

    //Start of exit game function
    stp x29, x30, [sp, -16]!
    mov x29, sp
    //Prints the exit string thanking the user for playing
    adrp x0, exitString
    add  x0, x0, :lo12:exitString
    bl   printf 

    //End of the exitGame function
    ldp x29, x30, [sp], 16  //Loads contents of pair of register and deallocates 48 bytes
    ret             //Return to calling code




//End of the program
done:
    bl  exitGame
    sub sp, sp, arraySize
    ldp x29, x30, [sp], dealloc //Loads the pair of registers from the RAM 					and restores their states and deallocates what 					we allocates
	ret 			    //Returns control to calling code