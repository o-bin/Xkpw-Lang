// src/codegen/emit_arith.s - Arithmetic Instruction Emission
// Generates add, sub, mul, sdiv instructions for registers x0 and x1.

.global emit_add
.global emit_sub
.global emit_mul
.global emit_div

.text

// emit_add() -> add x0, x1, x0 (0x8b000020)
emit_add:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0x8b000020
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_sub() -> sub x0, x1, x0 (0xcb000020)
emit_sub:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0xcb000020
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_mul() -> mul x0, x1, x0 (0x9b007c20)
emit_mul:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0x9b007c20
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_div() -> sdiv x0, x1, x0 (0x9ac00c20)
emit_div:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0x9ac00c20
    bl emit_word

    ldp x29, x30, [sp], #16
    ret
