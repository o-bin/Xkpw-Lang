// src/codegen/emit_stack.s - Stack Push/Pop Instruction Emission
// Generates instructions to push x0 and pop x1 during expression evaluation.

.global emit_push_x0
.global emit_pop_x1

.text

// emit_push_x0() -> str x0, [sp, #-16]! (0xf81f0fe0)
emit_push_x0:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0xf81f0fe0
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_pop_x1() -> ldr x1, [sp], #16 (0xf84107e1)
emit_pop_x1:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w0, =0xf84107e1
    bl emit_word

    ldp x29, x30, [sp], #16
    ret
