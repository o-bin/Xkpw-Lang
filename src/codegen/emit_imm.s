// src/codegen/emit_imm.s - Immediate Loading Instruction Emission
// Generates movz / movk instructions to load immediate values into x0.

.global emit_mov_imm

.text

// emit_mov_imm(uint64_t val)
emit_mov_imm:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    mov x19, x0                 // val

    // If val <= 0xffff: movz x0, #val
    mov x1, #0xffff
    cmp x19, x1
    bhi mov_large

    // movz x0, #imm16: 0xd2800000 | ((imm16 & 0xffff) << 5) | 0
    lsl x0, x19, #5
    ldr w1, =0xd2800000
    orr w0, w1, w0
    bl emit_word
    b mov_done

mov_large:
    // movz x0, #(val & 0xffff)
    and x0, x19, #0xffff
    lsl x0, x0, #5
    ldr w1, =0xd2800000
    orr w0, w1, w0
    bl emit_word

    // movk x0, #((val >> 16) & 0xffff), lsl #16: 0xf2a00000 | (imm16 << 5) | 0
    lsr x0, x19, #16
    and x0, x0, #0xffff
    lsl x0, x0, #5
    ldr w1, =0xf2a00000
    orr w0, w1, w0
    bl emit_word

mov_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
