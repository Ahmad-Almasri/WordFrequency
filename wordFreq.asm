/*
        Ahmad Almasri
        
//---------------------------------------------

        This program:
        Generates 2D array (with random int numbers)
        Generates array of struct ( int index & int frequency )
        Displays ... The 2D array , Then index, occurrences and frequency
        for the most frequent word in each row.

//---------------------------------------------

*/


.text

//----------------------------String-----------------------------

output0:	.string "  Row = %d && Col = %d \n"

wrongARG:	.string " Please make sure you enter the value of the row and col\n"

output1:	.string " %2d "

output2:	.string " Index = %d , Occurrences = %d , Frequency = %d \n"

newLine:	.string "\n"

//----------------------------Macros-----------------------------

	define(fp, x29)				// frame pointer
	define(lr, x30)				// link register
	
	define(temp1, w21)			// temp1 w reg.
	define(temp2, w22)			// temp2 w reg.

//----------------------Local Variables--------------------------

i = 16						// i counter
j = i + 4					// j counter

row = j + 4					// row #
col = row + 4					// col #

maxVal = col+ 4					// maximum value
sum = maxVal + 4				// sum
index = sum + 4					// index

struct = index + 8				// struct offset
size = struct + 8				// dynamic allocated size

//---------------------Alloc----Dealloc--------------------------

alloc = - (16 + 7*4 + 3*8) & -16
dealloc = - alloc

//---------------------------------------------------------------

	.balign	4
	.global	main

//--------------------------MAIN---------------------------------

main:
	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	//      ===================================================

	mov	x19, x0				// argc
	mov	x20, x1				// argv

	//	check value of argc == 3 ??
	b	argc				// To argc

	//      ===================================================
argv:
	//	argc == 3 ... Then :
	mov	w19, 1				// set x19 = 1

	//	Row #
	ldr	x0, [x20, w19, sxtw 3]		// read first arg.
	bl	atoi				// call atoi
	str	w0, [fp, row]			// store row #

	add	w19, w19, 1			// w19+= 1

	//	Col #
	ldr	x0, [x20, w19, sxtw 3]		// read second arg.
	bl	atoi				// call atoi
	str	w0, [fp, col]			// store col #

	//      ===================================================

	//	check # of row
	ldr	w19, [fp, row]			// get row
	cmp	w19, 4				// compare row with 4
	b.lt	wrong				// row < 4 ?? To wrong
	cmp	w19, 16				// compare row with 16
	b.gt	wrong				// row > 16 ?? To wrong

	//	check # of col
	ldr	w19, [fp, col]			// get col
	cmp	w19, 4				// compare col with 4
	b.lt	wrong				// col < 4 ?? To wrong
	cmp	w19, 16				// compare col with 16
	b.gt	wrong				// col > 16 ?? To col

	//      ===================================================

	//	if correct
	ldr	x0, =output0			// load output0 addr.
	ldr	w1, [fp, row]			// get row
	ldr	w2, [fp, col]			// get col
	bl	printf				// call printf
		
	b	allocation			// To allocation
//---------------------------------------------------------------
argc:
	cmp	x19, 3				// compare x19 with 3
	b.eq	argv				// == 3 ? back to argv

//ELSE						
wrong:
	ldr	x0, =wrongARG			// load wrongARG 
	bl	printf				// call printf
	b	stop				// stop the prog.
//---------------------------------------------------------------
allocation:

	//      ===================================================

	//	*** 2D Int Array

	//	allocate 2D array ... row * col * sizeOfInt(4)
	ldr	w19, [fp, row]			// get row
	ldr	w20, [fp, col]			// get col

	mul	w19, w19, w20			// row * col
	lsl	w19, w19, 2			// row * col * 4

	//      store the size of 2D array
        str     x19, [fp, size]			// store size (temporarily)

	//	===================================================

	//	*** Array Of Structures 

	//	last elment of 2d array + 4
	//	- ( size (x19) + 4 )

	add	x20, x19, 4			// x19-->sizeof2darray + 4
	sub	x20, xzr, x20			// -(x20)
	str	x20, [fp, struct]		// store the offset

	//	allocate array of struct ... row * col(2) * sizeOfInt(4)
	ldr	w19, [fp, row]			// load # of row
	lsl	w19, w19, 1			// row * 2
	lsl	w19, w19, 2			// row * 2 * 4

	//      ===================================================
	
	//	calc. the whole required size
	ldr	x20, [fp, size]			// load size of 2D array
	add	x19, x19, x20			// size of 2D-array & array of struct
	sub	x19, xzr, x19			// the whole Size *= -1	
	and	x19, x19, -16			// the whole size & -16

	str	x19, [fp, size]			// update size at the stack

	add	sp, sp, x19			// update sp
	
//---------------------------------------------------------------
	//	start filling the array randomly
	bl	clock				// call clock
	bl	srand				// call srand

	mov	w19, 0
	str	w19, [fp, i]			// update i
	str	w19, [fp, j]			// update j

	//      ===================================================

fill:
	ldr	w19, [fp, i]			// get i
	ldr	w20, [fp, col]			// get col
	mul	w19, w19, w20			// i * col
	ldr	w20, [fp, j]			// get j
	add	w19, w19, w20			// (i*col) + j
	lsl	w19, w19, 2			// [i*col+j]*4
	add	w19, w19, 4			// offset + 4
	sub	x19, xzr, x19			// x19 *= -1

	//      ===================================================

	bl	rand
	and	w20, w0, 15			// and rand with 15
	add	w20, w20, 1			// rand from 1 to 16

	str	w20, [fp, x19]	         	// store w20 at fp+x19-4

	//      ===================================================

	ldr	w19, [fp, j]			// get j
	add	w19, w19, 1			// j += 1
	str	w19, [fp, j]			// update j
	ldr	w20, [fp, col]			// get col

	cmp	w19, w20			// compare j with col
	b.lt	fill				// j < col ?? To fill

	//      ===================================================

//ELSE
stopFill:
	mov	w19, 0				// set w19 = 0
	str	w19, [fp, j]			// update j = 0

	ldr	w19, [fp, i]			// get i
	add	w19, w19, 1			// i += 1
	str	w19, [fp, i]			// update i

	ldr	w20, [fp, row]			// get row

	cmp	w19, w20			// compare i with row
	b.lt	fill				// i < row ?? To fill
//---------------------------------------------------------------
	// Display Table
        mov     w19, 0				// set w19 = 0
        str     w19, [fp, i]                    // update i
        str     w19, [fp, j]                    // update j

	//      ===================================================

display:
        ldr     w19, [fp, i]                    // get i
        ldr     w20, [fp, col]                  // get col
        mul     w19, w19, w20                   // i * col
        ldr     w20, [fp, j]                    // get j
        add     w19, w19, w20                   // (i*col) + j
        lsl     w19, w19, 2                     // [i*col+j]*4
	add	w19, w19, 4			// offset + 4
        sub     x19, xzr, x19                   // x19 *= -1

	//      ===================================================

	ldr	x0, =output1			// load output1 addr.
        ldr     w1, [fp, x19]                   // get array[i][j]
	bl	printf				// call printf

	//      ===================================================

        ldr     w19, [fp, j]                    // get j
        add     w19, w19, 1                     // j += 1
        str     w19, [fp, j]                    // update j

        ldr     w20, [fp, col]                  // get col

        cmp     w19, w20                        // compare j with col
        b.lt    display				// j < col ?? To display

	//      ===================================================
//ELSE
stopDisplay:

	ldr	x0, =newLine			// load newLine addr.
	bl	printf				// call printf

        mov     w19, 0
        str     w19, [fp, j]                    // update j = 0

        ldr     w19, [fp, i]                    // get i
	add	w19, w19, 1			// i += 1
	str	w19, [fp, i]			// update i

        ldr     w20, [fp, row]                  // get row

        cmp     w19, w20			// compare i with row
        b.lt    display				// i < row ?? To display
//---------------------------------------------------------------
        // Find MAX value in each row && calc. frequency
        mov     w19, 0
        str     w19, [fp, i]                    // update i
        str     w19, [fp, j]                    // update j
	str	w19, [fp, sum]			// update sum

	//      ===================================================
max:
        ldr     w19, [fp, i]                    // get i
        ldr     w20, [fp, col]                  // get col
        mul     w19, w19, w20                   // i * col
        ldr     w20, [fp, j]                    // get j
        add     w19, w19, w20                   // (i*col) + j
        lsl     w19, w19, 2                     // [i*col+j]*4
        add     w19, w19, 4                     // offset + 4
        sub     x19, xzr, x19                   // x19 *= -1
	
	ldr	w19, [fp, x19]			// get array[i][j]

	//      ===================================================
	//	Calc. The size of the document

	ldr	w20, [fp, sum]			// get sum
	add	w20, w19, w20			// sum+=array[i][j]
	str	w20, [fp,sum]			// update sum

	//      ===================================================

	ldr     w20, [fp, j]                    // get j
        cmp     w20, 0                          // compare j with 0
        b.eq    strValue                        // == 0 ? To strValue	

	//      ===================================================

	ldr	w20, [fp, maxVal]		// get maxVal
	cmp	w19, w20			// compare array[i][j] with maxVal
	b.le	maxJ				// array[i][j] <= maxVal ?? To maxJ

	//      ===================================================	

strValue:
	//	The value is store IFF j == 0 || array[i][j] > maxVal

	//	store value at maxVal.
	str	w19, [fp, maxVal]		// maxVal = array[i][j]
	
	//	store the Index [j] at index
	ldr	w19, [fp, j]
	str	w19, [fp, index]		// index = j

	//      ===================================================

maxJ:
        ldr     w19, [fp, j]                    // get j
        add     w19, w19, 1                     // j += 1
        str     w19, [fp, j]                    // update j

        ldr     w20, [fp, col]                  // get col

        cmp     w19, w20                        // compare j with col
        b.lt    max

	//      ===================================================
//ELSE
stopMax:

	//      ===================================================

	ldr	w19, [fp, i]			// get i
	lsl	w19, w19, 3			// i * 8
	sub	x19, xzr, x19			// x19 *= -1
	ldr	x20, [fp, struct]		// get struct offset
	add	x19, x19, x20			// struct[i] offset

	//	store the Index in the struct[i].index
	ldr	w20, [fp, index]		// get index
	str	w20, [fp, x19]			// struct[i].index = index

	//	store the Frequency in the struct[i].freq
	ldr	w20, [fp, sum]			// get sum
	ldr	temp1, [fp, maxVal]		// get maxVal
	mov	temp2, 100			// temp2 = 100
	mul	temp1, temp1, temp2		// temp1 = maxValue * 100
	udiv	w20, temp1, w20			// freq = maxVal/sum

	add	x19, x19, -4			// update offset of struct by -4
	str	w20,[fp, x19]			// struct[i].freq = freq

	//      ===================================================

        mov     w19, 0
        str     w19, [fp, j]                    // update j = 0
	str	w19, [fp, sum]			// updata sum = 0

	//      ===================================================

        ldr     w19, [fp, i]                    // get i
        add     w19, w19, 1                     // i += 1
        str     w19, [fp, i]                    // update i

        ldr     w20, [fp, row]                  // get row

        cmp     w19, w20			// compare i with row
        b.lt    max				// i < row ?? To max
//---------------------------------------------------------------
        // Display Result
        mov     w19, 0
        str     w19, [fp, i]                    // update i
        str     w19, [fp, j]                    // update j
	//      ===================================================
displayResult:

	ldr	w19, [fp, i]			// get i
	lsl	w19, w19, 3			// i * 8
	sub	x19, xzr, x19			// x19 *= -1
	ldr	x20, [fp, struct]	        // get struct
	add	x19, x19, x20			// struct[i] offset

	//      ===================================================

	//	Get The index & Frequency
	ldr	temp1, [fp, x19]		// get Index
	add	x19, x19, -4			// update offset by -4 
	ldr	temp2, [fp, x19]		// get freq.

	//      ===================================================

	//	Get The Occurrences ... using the stored index in the struct
        ldr     w19, [fp, i]                    // get i
        ldr     w20, [fp, col]                  // get col
        mul     w19, w19, w20                   // i * col
        add     w19, w19, temp1                 // (i*col) + j
        lsl     w19, w19, 2                     // [i*col+j]*4
        add     w19, w19, 4                     // offset + 4
        sub     x19, xzr, x19                   // x19 *= -1

	ldr	w19, [fp, x19]			// get Occurrences

	//      ===================================================

	//	Print the result
	ldr	x0, =output2			// load output2
	mov	w1, temp1			// Index
	mov	w2, w19				// Occurrences
	mov	w3, temp2			// Frequency
	bl	printf				// call printf

	//      ===================================================
//ELSE
stopDisplayResult:

        ldr     x0, =newLine			// load newLine addr.
        bl      printf				// call printf

        mov     w19, 0				// set w19 = 0
        str     w19, [fp, j]                    // update j = 0

        ldr     w19, [fp, i]                    // get i
        add     w19, w19, 1                     // i += 1
        str     w19, [fp, i]                    // update i

        ldr     w20, [fp, row]                  // get row

        cmp     w19, w20			// compare i with row
        b.lt    displayResult			// i < row ?? To displayResult
//---------------------------------------------------------------

stopDy:
	ldr	x19, [fp, size]			// load the size
	sub	x19, xzr, x19			// -(size)
	add	sp, sp, x19			// update sp
stop:
	ldp	fp, lr, [sp], dealloc		// restore fp, lr
	ret					// stop the prog.
