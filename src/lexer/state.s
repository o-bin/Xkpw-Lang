// src/lexer/state.s - Lexer State Storage and Initialization

.global lexer_src_ptr
.global lexer_src_end
.global cur_tok_type
.global cur_tok_val
.global cur_tok_ptr
.global cur_tok_len
.global cur_tok_line
.global lexer_init

.bss
.align 8
lexer_src_ptr: .quad 0
lexer_src_end: .quad 0
cur_tok_type:  .quad 0
cur_tok_val:   .quad 0
cur_tok_ptr:   .quad 0
cur_tok_len:   .quad 0
cur_tok_line:  .quad 0

.text

// lexer_init(const char *src, uint64_t len)
lexer_init:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x2, =lexer_src_ptr
    str x0, [x2]
    add x1, x0, x1
    ldr x2, =lexer_src_end
    str x1, [x2]

    ldr x2, =cur_tok_line
    mov x3, #1
    str x3, [x2]

    bl lexer_next

    ldp x29, x30, [sp], #16
    ret
