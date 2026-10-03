// src/codegen/code_buf.s - Code Buffer Management
// Manages emitted instruction buffer in RAM.

.global codegen_init
.global codegen_get_buf
.global codegen_get_size
.global emit_word

.equ CODE_BUF_SIZE, 65536

.bss
.align 8
code_buf:
    .space CODE_BUF_SIZE
code_size:
    .quad 0

.text

// codegen_init()
codegen_init:
    ldr x0, =code_size
    str xzr, [x0]
    ret

// codegen_get_buf() -> x0 (ptr)
codegen_get_buf:
    ldr x0, =code_buf
    ret

// codegen_get_size() -> x0 (size in bytes)
codegen_get_size:
    ldr x0, =code_size
    ldr x0, [x0]
    ret

// emit_word(uint32_t inst)
emit_word:
    ldr x1, =code_size
    ldr x2, [x1]
    ldr x3, =code_buf
    str w0, [x3, x2]
    add x2, x2, #4
    str x2, [x1]
    ret
