/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*                Nicolas Ojeda Bar <n.oje.bar@gmail.com>                 */
/*                                                                        */
/*   Copyright 2016 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

/* Asm part of the runtime system, RISC-V processor, 64-bit mode */
/* Must be preprocessed by cpp */

#define ARG_DOMAIN_STATE_PTR t0
#define DOMAIN_STATE_PTR s0
#define TRAP_PTR s1
#define ALLOC_PTR s10
#define ALLOC_LIMIT s11
#define TMP t1
#define ARG t2

#define STORE sw
#define LOAD lw

        .set    domain_curr_field, 0
#define DOMAIN_STATE(c_type, name) \
        .equ    domain_field_caml_##name, domain_curr_field ; \
        .set    domain_curr_field, domain_curr_field + 1
#include "../runtime/caml/domain_state.tbl"
#undef DOMAIN_STATE

#define Caml_state(var) (8*domain_field_caml_##var)(s0)

#define FUNCTION(name) \
        .align 2; \
        .globl name; \
        .type name, @function; \
name:

#if defined(__PIC__)
        .option pic
#define PLT(r) r@plt
#else
        .option nopic
#define PLT(r) r
#endif

        .section        .text
/* Invoke the garbage collector. */

        .globl  caml_system__code_begin
caml_system__code_begin:

FUNCTION(caml_call_gc)
.Lcaml_call_gc:
        /* Record return address */
        STORE   ra, Caml_state(last_return_address)
        /* Record lowest stack address */
        STORE   sp, Caml_state(bottom_of_stack)
        /* Set up stack space, saving return address */
        /* (1 reg for RA, 1 reg for FP, 21 allocatable int regs,
            20 caller-save float regs) * 8 */
        /* + 1 for alignment */
        addi    sp, sp, -0xb4
        STORE   ra, 0x4(sp)
        STORE   s0, 0x0(sp)
        /* Save allocatable integer registers on the stack,
           in the order given in proc.ml */
        STORE   a0, 0x8(sp)
        STORE   a1, 0xc(sp)
        STORE   a2, 0x10(sp)
        STORE   a3, 0x14(sp)
        STORE   a4, 0x1c(sp)
        STORE   a5, 0x20(sp)
        STORE   a6, 0x24(sp)
        STORE   a7, 0x28(sp)
        STORE   s2, 0x2c(sp)
        STORE   s3, 0x30(sp)
        STORE   s4, 0x34(sp)
        STORE   s5, 0x38(sp)
        STORE   s6, 0x3c(sp)
        STORE   s7, 0x40(sp)
        STORE   s8, 0x44(sp)
        STORE   s9, 0x48(sp)
        STORE   t2, 0x4c(sp)
        STORE   t3, 0x50(sp)
        STORE   t4, 0x54(sp)
        STORE   t5, 0x58(sp)
        STORE   t6, 0x5c(sp)
        /* Save caller-save floating-point registers on the stack
           (callee-saves are preserved by caml_garbage_collection) */
        fsw     ft0, 0x60(sp)
        fsw     ft1, 0x64(sp)
        fsw     ft2, 0x68(sp)
        fsw     ft3, 0x6c(sp)
        fsw     ft4, 0x70(sp)
        fsw     ft5, 0x74(sp)
        fsw     ft6, 0x78(sp)
        fsw     ft7, 0x7c(sp)
        fsw     fa0, 0x80(sp)
        fsw     fa1, 0x84(sp)
        fsw     fa2, 0x88(sp)
        fsw     fa3, 0x8c(sp)
        fsw     fa4, 0x90(sp)
        fsw     fa5, 0x94(sp)
        fsw     fa6, 0x98(sp)
        fsw     fa7, 0x9c(sp)
        fsw     ft8, 0xa0(sp)
        fsw     ft9, 0xa4(sp)
        fsw     ft9, 0xa8(sp)
        fsw     ft10, 0xac(sp)
        fsw     ft11, 0xb0(sp)
        /* Store pointer to saved integer registers in caml_gc_regs */
        addi    TMP, sp, 0x8
        STORE   TMP, Caml_state(gc_regs)
        /* Save current allocation pointer for debugging purposes */
        STORE   ALLOC_PTR, Caml_state(young_ptr)
        /* Save trap pointer in case an exception is raised during GC */
        STORE   TRAP_PTR, Caml_state(exception_pointer)
        /* Call the garbage collector */
        call    PLT(caml_garbage_collection)
        /* Restore registers */
        LOAD   a0, 0x8(sp)
        LOAD   a1, 0xc(sp)
        LOAD   a2, 0x10(sp)
        LOAD   a3, 0x14(sp)
        LOAD   a4, 0x1c(sp)
        LOAD   a5, 0x20(sp)
        LOAD   a6, 0x24(sp)
        LOAD   a7, 0x28(sp)
        LOAD   s2, 0x2c(sp)
        LOAD   s3, 0x30(sp)
        LOAD   s4, 0x34(sp)
        LOAD   s5, 0x38(sp)
        LOAD   s6, 0x3c(sp)
        LOAD   s7, 0x40(sp)
        LOAD   s8, 0x44(sp)
        LOAD   s9, 0x48(sp)
        LOAD   t2, 0x4c(sp)
        LOAD   t3, 0x50(sp)
        LOAD   t4, 0x54(sp)
        LOAD   t5, 0x58(sp)
        flw     ft0, 0x60(sp)
        flw     ft1, 0x64(sp)
        flw     ft2, 0x68(sp)
        flw     ft3, 0x6c(sp)
        flw     ft4, 0x70(sp)
        flw     ft5, 0x74(sp)
        flw     ft6, 0x78(sp)
        flw     ft7, 0x7c(sp)
        flw     fa0, 0x80(sp)
        flw     fa1, 0x84(sp)
        flw     fa2, 0x88(sp)
        flw     fa3, 0x8c(sp)
        flw     fa4, 0x90(sp)
        flw     fa5, 0x94(sp)
        flw     fa6, 0x98(sp)
        flw     fa7, 0x9c(sp)
        flw     ft8, 0xa0(sp)
        flw     ft9, 0xa4(sp)
        flw     ft9, 0xa8(sp)
        flw     ft10, 0xac(sp)
        flw     ft11, 0xb0(sp)
        /* Reload new allocation pointer and allocation limit */
        LOAD    ALLOC_PTR, Caml_state(young_ptr)
        LOAD    ALLOC_LIMIT, Caml_state(young_limit)
        /* Free stack space and return to caller */
        LOAD    ra, 0x4(sp)
        LOAD    s0, 0x0(sp)
        addi    sp, sp, 0xb4
        ret
        .size   caml_call_gc, .-caml_call_gc

/* Call a C function from OCaml */
/* Function to call is in ARG */

FUNCTION(caml_c_call)
        /* Preserve return address in callee-save register s2 */
        mv      s2, ra
        /* Record lowest stack address and return address */
        STORE   ra, Caml_state(last_return_address)
        STORE   sp, Caml_state(bottom_of_stack)
        /* Make the exception handler alloc ptr available to the C code */
        STORE   ALLOC_PTR, Caml_state(young_ptr)
        STORE   TRAP_PTR, Caml_state(exception_pointer)
        /* Call the function */
        jalr    ARG
        /* Reload alloc ptr and alloc limit */
        LOAD    ALLOC_PTR, Caml_state(young_ptr)
        LOAD    ALLOC_LIMIT, Caml_state(young_limit)
        /* Return */
        jr      s2
        .size   caml_c_call, .-caml_c_call

/* Raise an exception from OCaml */
FUNCTION(caml_raise_exn)
        /* Test if backtrace is active */
        LOAD    TMP, Caml_state(backtrace_active)
        bnez    TMP, 2f
1:      /* Cut stack at current trap handler */
        mv      sp, TRAP_PTR
        /* Pop previous handler and jump to it */
        LOAD    TMP, 4(sp)
        LOAD    TRAP_PTR, 0(sp)
        addi    sp, sp, 8
        jr      TMP
2:      /* Preserve exception bucket in callee-save register s2 */
        mv      s2, a0
        /* Stash the backtrace */
        mv      a1, ra
        mv      a2, sp
        mv      a3, TRAP_PTR
        call    PLT(caml_stash_backtrace)
        /* Restore exception bucket and raise */
        mv      a0, s2
        j       1b
        .size   caml_raise_exn, .-caml_raise_exn

        .globl  caml_reraise_exn
        .type   caml_reraise_exn, @function

/* Raise an exception from C */

FUNCTION(caml_raise_exception)
        mv      DOMAIN_STATE_PTR, a0
        mv      a0, a1
        LOAD    TRAP_PTR, Caml_state(exception_pointer)
        LOAD    ALLOC_PTR, Caml_state(young_ptr)
        LOAD    ALLOC_LIMIT, Caml_state(young_limit)
        LOAD    TMP, Caml_state(backtrace_active)
        bnez    TMP, 2f
1:      /* Cut stack at current trap handler */
        mv      sp, TRAP_PTR
        LOAD    TMP, 4(sp)
        LOAD    TRAP_PTR, 0(sp)
        addi    sp, sp, 8
        jr      TMP
2:      /* Preserve exception bucket in callee-save register s2 */
        mv      s2, a0
        LOAD    a1, Caml_state(last_return_address)
        LOAD    a2, Caml_state(bottom_of_stack)
        mv      a3, TRAP_PTR
        call    PLT(caml_stash_backtrace)
        mv      a0, s2
        j       1b
        .size   caml_raise_exception, .-caml_raise_exception

/* Start the OCaml program */

FUNCTION(caml_start_program)
        mv      ARG_DOMAIN_STATE_PTR, a0
        la      ARG, caml_program
        /* Code shared with caml_callback* */
        /* Address of OCaml code to call is in ARG */
        /* Arguments to the OCaml code are in a0 ... a7 */
.Ljump_to_caml:
        /* Set up stack frame and save callee-save registers */
        addi    sp, sp, -0x68
        STORE   ra, 0x60(sp)
        STORE   s0, 0x0(sp)
        STORE   s1, 0x4(sp)
        STORE   s2, 0x8(sp)
        STORE   s3, 0xc(sp)
        STORE   s4, 0x10(sp)
        STORE   s5, 0x14(sp)
        STORE   s6, 0x18(sp)
        STORE   s7, 0x1c(sp)
        STORE   s8, 0x20(sp)
        STORE   s9, 0x24(sp)
        STORE   s10, 0x28(sp)
        STORE   s11, 0x2c(sp)
        fsw     fs0, 0x30(sp)
        fsw     fs1, 0x34(sp)
        fsw     fs2, 0x38(sp)
        fsw     fs3, 0x3c(sp)
        fsw     fs4, 0x40(sp)
        fsw     fs5, 0x44(sp)
        fsw     fs6, 0x48(sp)
        fsw     fs7, 0x4c(sp)
        fsw     fs8, 0x50(sp)
        fsw     fs9, 0x54(sp)
        fsw     fs10, 0x58(sp)
        fsw     fs11, 0x5c(sp)
        addi    sp, sp, -16
        /* Load domain state pointer from argument */
        mv      DOMAIN_STATE_PTR, ARG_DOMAIN_STATE_PTR
        /* Setup a callback link on the stack */
        LOAD    TMP, Caml_state(bottom_of_stack)
        STORE   TMP, 0(sp)
        LOAD    TMP, Caml_state(last_return_address)
        STORE   TMP, 4(sp)
        LOAD    TMP, Caml_state(gc_regs)
        STORE   TMP, 8(sp)
        /* set up a trap frame */
        addi    sp, sp, -8
        LOAD    TMP, Caml_state(exception_pointer)
        STORE   TMP, 0(sp)
        lla     TMP, .Ltrap_handler
        STORE   TMP, 4(sp)
        mv      TRAP_PTR, sp
        LOAD    ALLOC_PTR, Caml_state(young_ptr)
        LOAD    ALLOC_LIMIT, Caml_state(young_limit)
        STORE   x0, Caml_state(last_return_address)
        jalr    ARG
.Lcaml_retaddr:         /* pop trap frame, restoring caml_exception_pointer */
        LOAD    TMP, 0(sp)
        STORE   TMP, Caml_state(exception_pointer)
        addi    sp, sp, 8
.Lreturn_result:        /* pop callback link, restoring global variables */
        LOAD    TMP, 0(sp)
        STORE   TMP, Caml_state(bottom_of_stack)
        LOAD    TMP, 4(sp)
        STORE   TMP, Caml_state(last_return_address)
        LOAD    TMP, 8(sp)
        STORE   TMP, Caml_state(gc_regs)
        addi    sp, sp, 16
        /* Update allocation pointer */
        STORE   ALLOC_PTR, Caml_state(young_ptr)
        /* reload callee-save registers and return */
        LOAD    ra, 0x60(sp)
        LOAD    s0, 0x0(sp)
        LOAD    s1, 0x4(sp)
        LOAD    s2, 0x8(sp)
        LOAD    s3, 0xc(sp)
        LOAD    s4, 0x10(sp)
        LOAD    s5, 0x14(sp)
        LOAD    s6, 0x18(sp)
        LOAD    s7, 0x1c(sp)
        LOAD    s8, 0x20(sp)
        LOAD    s9, 0x24(sp)
        LOAD    s10, 0x28(sp)
        LOAD    s11, 0x2c(sp)
        flw     fs0, 0x30(sp)
        flw     fs1, 0x34(sp)
        flw     fs2, 0x38(sp)
        flw     fs3, 0x3c(sp)
        flw     fs4, 0x40(sp)
        flw     fs5, 0x44(sp)
        flw     fs6, 0x48(sp)
        flw     fs7, 0x4c(sp)
        flw     fs8, 0x50(sp)
        flw     fs9, 0x54(sp)
        flw     fs10, 0x58(sp)
        flw     fs11, 0x5c(sp)
        addi    sp, sp, 0x68
        ret
        .type   .Lcaml_retaddr, @function
        .size   .Lcaml_retaddr, .-.Lcaml_retaddr
        .size   caml_start_program, .-caml_start_program

        .align  2
.Ltrap_handler:
        STORE   TRAP_PTR, Caml_state(exception_pointer)
        ori     a0, a0, 2
        j       .Lreturn_result
        .type   .Ltrap_handler, @function
        .size   .Ltrap_handler, .-.Ltrap_handler

/* Callback from C to OCaml */

FUNCTION(caml_callback_asm)
        /* Initial shuffling of arguments */
        /* a0 = Caml_state, a1 = closure, (a2) = args */
        mv      ARG_DOMAIN_STATE_PTR, a0
        LOAD    a0, 0(a2)   /* a0 = first arg */
                            /* a1 = closure environment */
        LOAD    ARG, 0(a1)  /* code pointer */
        j       .Ljump_to_caml
        .size   caml_callback_asm, .-caml_callback_asm

FUNCTION(caml_callback2_asm)
        /* Initial shuffling of arguments */
        /* a0 = Caml_state, a1 = closure, (a2) = args */
        mv      ARG_DOMAIN_STATE_PTR, a0
        mv      TMP, a1
        LOAD    a0, 0(a2)
        LOAD    a1, 4(a2)
        mv      a2, TMP
        la      ARG, caml_apply2
        j       .Ljump_to_caml
        .size   caml_callback2_asm, .-caml_callback2_asm

FUNCTION(caml_callback3_asm)
        /* Initial shuffling of arguments */
        /* a0 = Caml_state, a1 = closure, (a2) = args */
        mv      ARG_DOMAIN_STATE_PTR, a0
        mv      a3, a1
        LOAD    a0, 0(a2)
        LOAD    a1, 4(a2)
        LOAD    a2, 8(a2)
        la      ARG, caml_apply3
        j       .Ljump_to_caml
        .size   caml_callback3_asm, .-caml_callback3_asm

FUNCTION(caml_ml_array_bound_error)
        /* Load address of [caml_array_bound_error] in ARG */
        la      ARG, caml_array_bound_error
        /* Call that function */
        tail    caml_c_call
        .size   caml_ml_array_bound_error, .-caml_ml_array_bound_error

        .globl  caml_system__code_end
caml_system__code_end:

/* GC roots for callback */

        .section .data
        .align  2
        .globl  caml_system__frametable
        .type   caml_system__frametable, @object
caml_system__frametable:
        .long   1               /* one descriptor */
        .long   .Lcaml_retaddr  /* return address into callback */
        .short  -1              /* negative frame size => use callback link */
        .short  0               /* no roots */
        .align  2
        .size   caml_system__frametable, .-caml_system__frametable
