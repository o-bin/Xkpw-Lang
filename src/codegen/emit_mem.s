// src/codegen/emit_mem.s - Memory Load/Store Instruction Emission
// Generates ldur/stur instructions for local variables relative to FP (x29).

.global emit_load_var
.global emit_store_var

.text

// emit_load_var(int64_t offset)
// ldur x0, [x29, #offset] -> 0xf8400000 | ((simm9 & 0x1ff) << 12) | (29 << 5) | 0
emit_load_var:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    and x0, x0, #0x1ff
    lsl x0, x0, #12
    ldr w1, =0xf84003a0
    orr w0, w1, w0
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_store_var(int64_t offset)
// stur x0, [x29, #offset] -> 0xf8000000 | ((simm9 & 0x1ff) << 12) | (29 << 5) | 0
emit_store_var:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    and x0, x0, #0x1ff
    lsl x0, x0, #12
    ldr w1, =0xf80003a0
    orr w0, w1, w0
    bl emit_word

    ldp x29, x30, [sp], #16
    ret
