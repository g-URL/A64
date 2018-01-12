//============================================================ INFORMATION ====================================================

// Author: R. Apperley
// Class: CPSC 355
// Assignment 04
// Tutorial: T02
// Date: March 17th, 2017
// Version: 1
// Language: A64
// Program Scope: Box initialization and modification.

//=========================================================== /INFORMATION ====================================================


//============================================================== MACROS =======================================================
 
define(box1top, x19)								// defining box1top macro as x19
define(box2top, x20)								// defining box2top macro as x20

//============================================================= /MACROS =======================================================


//============================================================== EQUATES ======================================================

point = 0									// offset of point struct from box struct
x = 0										// offset of x from point struct
y = 4										// offset of y from point struct
dimension = 8									// offset of dimension struct from box struct
width = 0									// offset of width from dimension struct
height = 4									// offset of height from dimension struct
area = 16									// offset of area from box struct


false = 0									// setting false to 0
true = 1									// setting true to 1
 

box_size = 20									// the size required for the box struct


m_alloc = -(16 + box_size + box_size) & -16					// setting alloc for main
m_dealloc = -m_alloc								// setting dealloc for main


b_alloc = -(16 + box_size) & -16						// setting alloc for newbox
b_dealloc = -b_alloc								// setting dealloc for newbox

//============================================================= /EQUATES ======================================================


//========================================================= REGISTER EQUATES ==================================================

	fp .req x29								// register equate for the FP(x29)
	lr .req x30								// register equate for the LR(x30)

//======================================================== /REGISTER EQUATES ==================================================


//============================================================= PROGRAM =======================================================

fmt1:	.string "Initial box values:\n"						// first string to be printed
fmt2:	.string "first"								// string to be passed as an argument to prntbx
fmt3:	.string "second"							// string to be passed as an argument to prntbx
fmt4:	.string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"	// second string to be printed
fmt5:	.string "\nChanged box values:\n"					// third string to be printed


	.balign 4								// padding by 4 bytes
	.global main								// makes the label main visible to the linker


main:	stp	fp, lr, [sp, m_alloc]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP
	add	box1top, fp, 16							// calculating the offset of box 1 from the fp
	add	box2top, fp, 36							// calculating the offset of box 2 from the fp

	mov	x8, box1top							// passing the offset of box 1 to x8
	bl	newbox								// branch and linking to newbox
	mov	x8, box2top							// passing the offset of box 2 to x8
	bl	newbox								// branch and linking to newbox


print1:	adrp	x0, fmt1							// pointing address of fmt1 to x0
	add	x0, x0, :lo12:fmt1						// adds low 12 bits of fmt1 address to x0
	bl	printf								// branch and link to printf


print2:	adrp	x1, fmt2							// pointing address of fmt2 to x1
	add	x1, x1, :lo12:fmt2						// adds low 12 bits of fmt2 address to x1
	mov	x2, box1top							// moving the offset of box 1 into x2
	bl	prntbx								// branch and linking to prntbx

	adrp	x1, fmt3							// pointing address of fmt3 to x1
	add	x1, x1, :lo12:fmt3						// adds low 12 bits of fmt3 address to x1
	mov	x2, box2top							// moving the offset of box 2 into x2
	bl	prntbx								// branch and linking to prntbx

	mov	x0, box1top							// moving the address of box1top into x0
	mov	x1, box2top							// moving the address of box2top into x1
	mov	w2, false							// moving the value of false into w7
	bl	equal								// branch and linking to equal

	cmp	w2, true							// comparing the value of w7 to true
	b.ne	print3								// if not equal, branching to print3

	mov	x0, box1top							// moving the offset of box 1 into x0
	mov	w1, -5								// moving the immediate -5 into w1
	mov	w2, 7								// moving the immediate 7 into w2
	bl	move								// branch and link to move

	mov	x0, box2top							// moving the offset of box 2 into x0
	mov	w1, 3								// moving the immediate 3 into w1
	bl	expand								// branch and link to expand


print3:	adrp	x0, fmt5							// pointing address of fmt5 to x0
	add	x0, x0, :lo12:fmt5						// adds low 12 bits of fmt5 address to x0
	bl	printf								// branch and link to printf


print4:	adrp	x1, fmt2							// pointing address of fmt2 to x1
	add	x1, x1, :lo12:fmt2						// adds low 12 bits of fmt2 address to x1
	mov	x2, box1top							// moving the offest of box 1 into x2
	bl	prntbx								// branch and link to prntbx

	adrp	x1, fmt3							// pointing address of fmt3 to x1
	add	x1, x1, :lo12:fmt3						// addds low 12 bits of fmt3 address to x1
	mov	x2, box2top							// moving the offset of box 2 into x2
	bl	prntbx								// branch and link to prntbx

	ldp	fp, lr, [sp], m_dealloc						// restoring the FP, LR and SP
	ret									// return


newbox:	stp	fp, lr, [sp, b_alloc]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP

	add	x9, fp, 16							// calculating the offset of the newbox box struct from the fp

	str	wzr, [x9, point+x]						// storing 0 in point x of newbox		
	str	wzr, [x9, point+y]						// storing 0 in point y of newbox
	mov	w10, 1								// moving the immediate 1 into w10
	str	w10, [x9, dimension+width]					// storing 1 in dimension width of newbox
	mov	w11, 1								// moving the immediate 1 into w11
	str	w11, [x9, dimension+height]					// storing 1 in the dimension height of newbox
	mul	w12, w10, w11							// storing the product of w10 and w11 in w12
	str	w12, [x9, area]							// moving the product of w10 and w11 into area of newbox

	ldr	w10, [x9, point+x]						// loading point x of newbox
	ldr	w11, [x9, point+y]						// loading point y of newbox
	ldr	w12, [x9, dimension+width]					// loading dimension width of newbox
	ldr	w13, [x9, dimension+height]					// loading dimension height of newbox
	ldr	w14, [x9, area]							// loading box area of newbox

	str	w10, [x8, point+x]						// storing point x of newbox in box of main
	str	w11, [x8, point+y]						// storing point y of newbox in box of main
	str	w12, [x8, dimension+width]					// storing dimension width of newbox in box of main
	str	w13, [x8, dimension+height]					// storing dimension height of newbox in box of main
	str	w14, [x8, area]							// storing area of newbox in box of main

	ldp	fp, lr, [sp], b_dealloc						// restoring the FP, LR and SP
	ret									// return


prntbx:	stp	fp, lr, [sp, -16]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP

	mov	x28, x2								// moving the offset of box from main into x28

	adrp	x0, fmt4							// pointing address of fmt4 to x0
	add	x0, x0, :lo12:fmt4						// adds low 12 bits of fmt4 to x0
	ldr	w2, [x28, point+x]						// loading w2 with point x of box from main
	ldr	w3, [x28, point+y]						// loading w3 with point y of box from main
	ldr	w4, [x28, dimension+width]					// loading w4 with dimension width of box from main
	ldr	w5, [x28, dimension+height]					// loading w5 with dimension height of box from main
	ldr	w6, [x28, area]							// loading w6 with area of box from main
	bl	printf								// branch and link to printf

	ldp	fp, lr, [sp], 16						// restoring the FP, LR and SP
	ret									// return


equal:	stp	fp, lr, [sp, -16]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP							

	ldr	w10, [x0, point+x]						// loading w10 with point x of box 1 from main
	ldr	w11, [x1, point+x]						// loading w11 with point x of box 2 from main

	cmp	w10, w11							// comparing point x of box 1 and box 2
	b.ne	end								// if x is not equal, branch to end

	ldr	w10, [x0, point+y]						// loading w10 with point y of box 1 from main
	ldr	w11, [x1, point+y]						// loading w11 with point y of box 2 from main

	cmp	w10, w11							// comparing point y of box 1 and box 2
	b.ne	end								// if y is not equal, branch to end

	ldr	w10, [x0, dimension+width]					// loading w10 with dimension width of box 1 from main
	ldr	w11, [x1, dimension+width]					// loading w11 with dimension width of box 2 from main

	cmp	w10, w11							// comparing dimension width of box 1 and box 2
	b.ne	end								// if dimension width is not equal, branch to end

	ldr	w10, [x0, dimension+height]					// loading w10 with dimension height of box 1 from main
	ldr	w11, [x1, dimension+height]					// loading w11 with dimension height of box 2 from main

	cmp	w10, w11							// comparing dimension height of box 1 and box 2
	b.ne	end								// if dimension height isn ot equal, branch to end

	mov	w2, true							// move the value of true into w2


end:	ldp	fp, lr, [sp], 16						// restoring the FP, LR and SP
	ret									// return


move:	stp	fp, lr, [sp, -16]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP

	ldr	w10, [x0, point+x]						// loading w10 with point x of box from main	
	add	w10, w1, w10							// adding w1 to w10
	str	w10, [x0, point+x]						// storing the sum of w1 and w10 to point x of box in main

	ldr	w10, [x0, point+y]						// loading w10 with point y of box from main
	add	w10, w2, w10							// adding w2 to w10
	str	w10, [x0, point+y]						// storing the sum of w2 and w20 to point y of box in main

	ldp	fp, lr, [sp], 16						// restoring the FP, LR and SP
	ret									// return


expand:	stp	fp, lr, [sp, -16]!						// storing the FP and LR, pushing SP by 16 bytes
	mov	fp, sp								// setting the FP to the SP

	ldr	w10, [x0, dimension+width]					// loading w10 with dimension width of box from main
	mul	w10, w1, w10							// multiplying w1 and w10
	str	w10, [x0, dimension+width]					// storing the product of w1 and w10 in dimension width of box in main

	ldr	w11, [x0, dimension+height]					// loading w11 with dimension height of box from main
	mul	w11, w1, w11							// multiplying w1 and w11
	str	w11, [x0, dimension+height]					// storing the product of w1 and w11 in dimension height of box in main

	mul	w12, w10, w11							// storing the product of w10 and w11 in w12
	str	w12, [x0, area]							// storing the product of w10 and w11 in area of box in main

	ldp	fp, lr, [sp], 16						// restoring the FP, LR and SP
	ret									// return

//============================================================ /PROGRAM =======================================================
