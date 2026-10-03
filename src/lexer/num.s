// src/lexer/num.s - Specialized Numeric Literal Scanner

.global lexer_scan_number
.include "src/common/tokens.inc"

.text

// lexer_scan_number() -> scans digit sequence, updates cur_tok_type and cur_tok_val
lexer_scan_number:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    ldr x19, =lexer_src_ptr
    ldr x0, [x19]               // x0 = current ptr
    ldr x1, =lexer_src_end
    ldr x1, [x1]                // x1 = end ptr

    mov x20, #0                 // accumulator val = 0
num_loop:
    ldrb w2, [x0]
    sub w2, w2, #'0'
    mov x3, #10
    mul x20, x20, x3
    uxtw x2, w2
    add x20, x20, x2

    add x0, x0, #1
    cmp x0, x1
    bge num_done
    ldrb w2, [x0]
    cmp w2, #'0'
    blt num_done
    cmp w2, #'9'
    ble num_loop

num_done:
    str x0, [x19]               // update lexer_src_ptr
    ldr x3, =cur_tok_type
    mov x4, #TOK_NUMBER
    str x4, [x3]
    ldr x3, =cur_tok_val
    str x20, [x3]

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
