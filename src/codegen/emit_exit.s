// src/codegen/emit_exit.s - Exit and Return Instruction Emission
// Generates exit syscalls for return statement and process completion.

.global emit_return
.global emit_default_exit

.text

// emit_return() -> mov x8, #93 (SYS_exit); svc #0
emit_return:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // mov x8, #93 -> 0xd2800ba8
    ldr w0, =0xd2800ba8
    bl emit_word

    // svc #0 -> 0xd4000001
    ldr w0, =0xd4000001
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// emit_default_exit() -> mov x0, #0; mov x8, #93; svc #0
emit_default_exit:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // mov x0, #0 -> 0xd2800000
    ldr w0, =0xd2800000
    bl emit_word

    // mov x8, #93 -> 0xd2800ba8
    ldr w0, =0xd2800ba8
    bl emit_word

    // svc #0 -> 0xd4000001
    ldr w0, =0xd4000001
    bl emit_word

    ldp x29, x30, [sp], #16
    ret
