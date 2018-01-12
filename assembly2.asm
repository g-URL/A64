
//============================================================ INFORMATION ====================================================

// Author: R. Apperley
// Class: CPSC 355
// Assignment 06
// Tutorial: T02
// Date: April 12th, 2017
// Language: A64
// Program Scope: Sine and cosine calculation for degree inputs.

//=========================================================== /INFORMATION ====================================================


//============================================================== EQUATES ======================================================

exponent =8										// exponent allocation in stack
numerator = 8										// numerator allocation in stack
denominator = 8										// denominator allocation in stack
term = 8										// term allocation in stack
value = 8										// value allocation in stack
opcode = 8										// opcode allocation in stack
buffer = 8										// buffer allocation in stack
sin = 8											// sine value allocation in stack
cos = 8											// cosine value allocation in stack

exponent_offset = 16									// offest of the exponent in stack
numerator_offset = 24									// offset of the numerator in stack
denominator_offset = 32									// offset of the denominator in stack
term_offset = 40									// offset of the term in stack
value_offset = 48									// offset of the value in stack
opcode_offset = 56									// offset of the opcode in stack
buffer_offset = 16									// offset of the buffer in stack
sin_offset = 24										// offset of sine value in stack
cos_offset = 32										// offset of the cosine value in stack
bf_size = 8										// size of the buffer

CWD = -100										// current working directory

alloc = -(16 + buffer + sin + cos) & -16						// allocation for main
dealloc	= -alloc									// deallocation for main

alloc1 = -(16 + exponent + numerator + denominator + term + value + opcode) & -16	// allocation for sine and cosine
dealloc1 = -alloc1									// deallocation for sine and cosine

//============================================================= /EQUATES ======================================================


//========================================================= REGISTER EQUATES ==================================================

rad_base	.req	x9								// register used to store the base address of radian							
rad_value	.req	d9								// register used to store the radian value
lim_base	.req	x10								// register used to store the base of limit
limt		.req	d10								// resigter used to store the value of limit
opcd		.req	d11								// register used to store the opcode
expt		.req	x11								// register used to store the exponent
cntr		.req	d16								// register used to store the counter
vlue		.req	d12								// register used to store the value
term		.req	d13								// register used to store the term
numr		.req	d14								// register used to store the numerator
denr		.req	d15								// register used to store the denominator
argc		.req	w26								// register used to store the argument counter
argv		.req	x27								// register used to store the argument vector

rfd		.req	w19								// register equate for the file descriptor
bf_base		.req	x20								// register equate for the buffer base address
by_read		.req	x21								// register equate for the number of bytes read
dg_base		.req	x22								// register used to store the base address of degree
fp 		.req 	x29								// register equate for the FP(x29)
lr 		.req 	x30								// register equate for the LR(x30)

//======================================================== /REGISTER EQUATES ==================================================


//============================================================= STRINGS =======================================================

	.text										// declaring .text
	
fmt0:	.string	"usage: ./a6 filename\n"						// string to be printed if arguments input are not valid
fmt1:	.string	"Exception: Error opening file '%s'. Aborting\n"			// string to be printed if the file cannot be opened

// Series of strings for the table printout

fmt2:	.string " _______________________________________________________________________\n"
fmt3:	.string	"| Input (Degrees)	| Sine			| Cosine		|\n"
fmt4:	.string "|______________________|_______________________|_______________________|\n"
fmt5:	.string "|			|			|			|\n"
fmt6:	.string "| %.10f		| %.10f	         	| %.10f	         	|\n"
fmt7:	.string "|______________________|_______________________|_______________________|\n"


//============================================================ /STRINGS =======================================================


//============================================================ DATA SECTION ===================================================

	.data										// declaring .data

degree:	.double	0r0									// initializing degree to 0
radian:	.double 0r0									// initializing radian to 0
halfpi:	.double 0r1.57079632679489661923						// initializing halfpi to decimal value of pi/2
ninety:	.double 0r90									// initializing ninety to 90
limit:	.double 0r1.0e-10								// initializing lmit to 1.0e^-10

//=========================================================== /DATA SECTION ===================================================

//============================================================== PROGRAM ======================================================

	.text										// declaring .text

	.balign 4									// padding by 4 bytes
	.global main									// making main visible to the linker


main:	stp	fp, lr, [sp, alloc]!							// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp									// setting the FP to the SP

	mov	argc, w0								// moving the argument counter (number of pointers) into argc_r
	mov	argv, x1								// moving the argument vector (base address of the argument array) into argv_r
	cmp	argc, 2									// checking to insure the correct number of arguments were input
	b.ne	throw1									// if the number of arguments does not equal 2, branch to throw1
	 
	ldr	x1, [argv, 8]								// load x1 with the string of the second argument

	mov	w0, CWD									// moving CWD (current working directory) into w0
	mov	w2, 0									// moving 0 into w2
	mov	w3, 0									// moving 0 into w3
	mov	x8, 56									// moving 56 (openat I/O request) into x8
	svc	0									// calling system function
	mov	rfd, w0									// moving record file descriptor into rfd

	cmp	rfd, 0									// comparing rfd with 0
	b.lt	throw2									// if rfd is less than zero, branch to throw


table:	adrp	x0, fmt2								// pointing the address of fmt2 to x0
	add	x0, x0, :lo12:fmt2							// adding the low 12 bits of fmt2's address to x0
	bl	printf									// branch and link to printf

	adrp	x0, fmt3								// pointing the address of fmt3 to x0
	add	x0, x0, :lo12:fmt3							// adding the low 12 bits of fmt3's address to x0
	bl	printf									// branch and link to printf

	adrp	x0, fmt4								// pointing the address of fmt4 to x0
	add	x0, x0, :lo12:fmt4							// adding the low 12 bits of fmt4's address to x0
	bl	printf									// branch and link to printf

	adrp	x0, fmt5								// pointing the address of fmt5 to x0
	add	x0, x0, :lo12:fmt5							// adding the low 12 bits of fmt5's address to x0
	bl	printf									// branch and link to printf

	add	bf_base, fp, buffer_offset						// calculating base address of the buffer


loop1:	mov	w0, rfd									// moving rfd into w0
	mov	x1, bf_base								// moving buffer base into x1
	mov	w2, bf_size								// moving buffer size into w2
	mov	x8, 63									// moving 63 (read I/O request) into x8
	svc	0									// calling system function
	mov	by_read, x0								// moving number of bytes read into by_read

	cmp	by_read, bf_size							// compare bytes read with buffer size
	b.ne	end1									// if the number of bytes read does not equal the buffer size, branch to end

	adrp	dg_base, degree								// pointing the address of degree to dg_base
	add	dg_base, dg_base, :lo12:degree						// adding the low 12 bits of degree's address to dg_base

	ldr	d24, [bf_base]								// loading d24 with the value in the buffer (the degree input)

	str	d24, [dg_base]								// storing the value of the degree in stack under dg_base

	adrp	x24, halfpi								// pointing the address of halfpi to x24
	add	x24, x24, :lo12:halfpi							// adding the low 12 bits of halfpi's address to x24
	ldr	d20, [x24]								// loading d20 with the double float pi/2

	ldr	d19, [dg_base]								// loading d19 with the value of the input degree
	fmul	d19, d19, d20								// float multiplying (degree * pi/2)

	adrp	x24, ninety								// pointing the address of ninety to x24
	add	x24, x24, :lo12:ninety							// adding the low 12 bits of ninety's address to x24
	ldr	d20, [x24]								// loading d20 with the integer 90

	fdiv	d19, d19, d20								// float dividing the value in d19 by 90 (the degree input has now been converted to radians)

	adrp	x24, radian								// pointing the address of radian to x24
	add	x24, x24, :lo12:radian							// adding the low 12 bits of radian's address to x24
	str	d19, [x24]								// updating the global variable radian

	bl	sine									// branch and linking to sine
	str	d0, [fp, sin_offset]							// storing the returned sine value to stack

	bl	cosine									// branch and linking to cosine
	str	d0, [fp, cos_offset]							// storing the returnec cosine value to stack

	ldr	d0, [dg_base]								// loading d0 with the degree value
	ldr	d1, [fp, sin_offset]							// loading d1 with the sine value
	ldr	d2, [fp, cos_offset]							// loading d2 with the cosine value

	adrp	x0, fmt6								// pointing the address of fmt3 to x0
	add	x0, x0, :lo12:fmt6							// adding the low 12 bits of fmt3's address to x0
	bl	printf									// branch and link to printf

	b	loop1									// branching to loop 1


// ----------------------------------------------------------- SINE/COSINE ----------------------------------------------------

sine:	stp	fp, lr, [sp, alloc1]!							// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp									// setting the FP to the SP

	adrp	rad_base, radian							// pointing the address of radian into rad_base
	add	rad_base, rad_base, :lo12:radian					// adding the low 12 bits of radian to rad_base
	ldr	rad_value, [rad_base]							// loading the value of radian into rad_value
	str	rad_value, [fp, value_offset]						// storing rad_value into the stack allocated for value

	mov	expt, 3									// initializing the exponent to 3
	str	expt, [fp, exponent_offset]						// storing the exponent in stack

	fmov	opcd, -1.0								// initialzing the opcode to -1
	str	opcd, [fp, opcode_offset]						// storing the opcode to stack

	b	loop2									// branching to loop2


cosine:	stp	fp, lr, [sp, alloc1]!							// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp									// setting the FP to the SP

	fmov	vlue, 1.0								// initializing value to 1
	str	vlue, [fp, value_offset]						// storing value to stack

	mov	expt, 2									// initializing the exponent to 2
	str	expt, [fp, exponent_offset]						// storing the exponent in stack

	fmov	opcd, -1.0								// initialzing the opcode to -1
	str	opcd, [fp, opcode_offset]						// storing the opcode to stack


loop2:	ldr	expt, [fp, exponent_offset]						// loading the exponent from stack
	mov	x0, expt								// moving the exponent into the argument for getnum
	bl	getnum									// branch and link to getnum
	str	d0, [fp, numerator_offset]						// storing the returned numerator to stack

	ldr	expt, [fp, exponent_offset]						// loading the exponent from stack
	mov	x0, expt								// moving the exponent into the argument for getdom
	bl	getdom									// branch and link to getdom
	str	d0, [fp, denominator_offset]						// storing the returned denominator to stack

	ldr	numr, [fp, numerator_offset]						// loading the numerator from stack
	ldr	denr, [fp, denominator_offset]						// loading the denominator from stack

	fdiv	term, numr, denr							// float dividing the numerator by the denominator and storing the result in term
	
	fmul	term, term, opcd							// float mulfiplying the term by the opcode
	str	term, [fp, term_offset]							// storing the term to stack

	ldr	vlue, [fp, value_offset]						// loading the value from stack
	fadd	vlue, vlue, term							// float adding the term to the value
	str	vlue, [fp, value_offset]						// storing the updated value to stack

	adrp	lim_base, limit								// pointing the address of limit to lim_base
	add	lim_base, lim_base, :lo12:limit						// adding the low 12 bits of limit to lim_base
	ldr	limt, [lim_base]							// loading limt with the value of the limit

	fabs	term, term								// absolute valuing the term

	fcmp	term, limt								// comparing the term with the limit
	b.lt	end2									// if the term is less than the limit, branch to end2

	ldr	expt, [fp, exponent_offset]						// loading the exponent from stack
	add	expt, expt, 2								// incrementing the exponent by 2
	str	expt, [fp, exponent_offset]						// storing the new exponent into stack

	ldr	opcd, [fp, opcode_offset]						// loading the opcode from stack
	fneg	opcd, opcd								// negating the opcode
	str	opcd, [fp, opcode_offset]						// storing the new opcode in stack

	b	loop2									// branching to loop2


end2:	ldr	vlue, [fp, value_offset]						// loading value from stack
	fmov	d0, vlue								// float moving value into d0

	ldp	fp, lr, [sp], dealloc1							// restoring the FP, LR and SP
	ret										// returning

// ---------------------------------------------------------- /SINE/COSINE ----------------------------------------------------


// --------------------------------------------------------- GET NUMERATOR ----------------------------------------------------

getnum:	stp	fp, lr, [sp, -16]!							// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp									// setting the FP to the SP

	mov	expt, x0								// moving the exponent parameter into expt

	adrp	rad_base, radian							// moving the address of radian into rad_base
	add	rad_base, rad_base, :lo12:radian					// adding the low 12 bits of radian to rad_base
	ldr	rad_value, [rad_base]							// loading the value of radian into rad_value
	fmov	numr, rad_value								// float moving rad_value into numr

	b	test3									// branching to test 3


loop3:	fmul	numr, numr, rad_value							// float multiplying the numerator by rad_value
	add	expt, expt, -1								// decrementing the exponent (acting as a counter)
	

test3:	cmp	expt, 1									// comparing the exponent to the integer 1
	b.gt	loop3									// if the exponent is greater than 1, branch to loop 3


end3:	fmov	d0, numr								// float moving the numerator into d0

	ldp	fp, lr, [sp], 16							// restoring the FP, LR and SP
	ret										// returning

// -------------------------------------------------------- /GET NUMERATOR ----------------------------------------------------


// ------------------------------------------------------- GET DENOMINATOR ----------------------------------------------------

getdom:	stp	fp, lr, [sp, -16]!							// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp									// setting the FP to the SP


	scvtf	cntr, x0								// moving the exponenent parameter into cnter
	fmov	denr, cntr								// float moving the cntr into dner

	b	test4									// branching to test 4


loop4:	fmov	d9, -1.0								// float moving -1 into d9
	fadd	cntr, cntr, d9								// decrement the counter by 1
	fmul	denr, denr, cntr							// float multiplying the denominator by the decremented counter


test4:	fmov	d9, 2.0									// float moving 2 into d9
	fcmp	cntr, d9								// comparing the counter to the integer 2
	b.gt	loop4									// if the counter is greater than 2, branch to loop 4


end4:	fmov	d0, denr								// float moving the denominator into d0

	ldp	fp, lr, [sp], 16							// restoring the FP, LR and SP
	ret										// returning

// ------------------------------------------------------ /GET DENOMINATOR ----------------------------------------------------


throw1:	adrp	x0, fmt0								// pointing address of fmt1 to x0
	add	x0, x0, :lo12:fmt0							// adds low 12 bits of fmt1 address to x0
	bl	printf									// branch and link to printf

	b	end5									// branching to end1


throw2:	adrp	x0, fmt1								// pointing address of fmt1 to x0
	add	x0, x0, :lo12:fmt1							// adding the low 12 bits of fmt1's address to x0
	
	bl	printf									// branch and linking to printf
	mov	w0, -1									// moving -1 into w0

	b	end5


end1:	adrp	x0, fmt7								// pointing address of fmt7 to x0
	add	x0, x0, :lo12:fmt7							// adding the low 12 bits of fmt7's address to x0
	bl	printf									// branch and linking to printf

end5:	mov	w0, rfd									// moving the rfd into the first argument						
	mov	x8, 57									// moving 57 (close I/O request) into x8
	svc	0									// calling system function
	mov	w0, 0									// returning 0					

	ldp	fp, lr, [sp], dealloc							// restoring the FP, LR and SP
	ret										// return

//============================================================= /PROGRAM ======================================================
