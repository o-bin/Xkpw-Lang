// src/codegen/emit_frame.s - Function Frame Generation and Patching
// Emits prologue and updates stack frame size dynamically.

.global emit_prologue
.global codegen_patch_frame_size

.bss
.align 8
prologue_patch_offset:
    .quad 0

.text

// emit_prologue()
emit_prologue:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // stp x29, x30, [sp, #-16]! -> 0xa9bf7bfd
    ldr w0, =0xa9bf7bfd
    bl emit_word

    // mov x29, sp -> 0x910003fd
    ldr w0, =0x910003fd
    bl emit_word

    // Record offset of sub sp, sp, #frame_size
    bl codegen_get_size
    ldr x1, =prologue_patch_offset
    str x0, [x1]

    // sub sp, sp, #0 (placeholder) -> 0xd10003ff
    ldr w0, =0xd10003ff
    bl emit_word

    ldp x29, x30, [sp], #16
    ret

// codegen_patch_frame_size(uint64_t frame_size)
codegen_patch_frame_size:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // sub sp, sp, #imm12: 0xd1000000 | ((frame_size & 0xfff) << 10) | (31 << 5) | 31
    and x0, x0, #0xfff
    lsl x0, x0, #10
    ldr w1, =0xd10003ff
    orr w0, w1, w0

    mov w2, w0                  // patched instruction

    bl codegen_get_buf
    ldr x1, =prologue_patch_offset
    ldr x1, [x1]
    str w2, [x0, x1]

    ldp x29, x30, [sp], #16
    ret
