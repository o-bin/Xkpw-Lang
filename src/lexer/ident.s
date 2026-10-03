// src/lexer/ident.s - Specialized Identifier and Keyword Scanner

.global lexer_scan_ident
.include "src/common/tokens.inc"

.data
kw_main:   .asciz "main"
kw_var:    .asciz "var"
kw_return: .asciz "return"

.text

// lexer_scan_ident() -> scans identifier/keyword, updates cur_tok_type, cur_tok_ptr, cur_tok_len
lexer_scan_ident:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    ldr x19, =lexer_src_ptr
    ldr x0, [x19]               // x0 = current ptr
    ldr x1, =lexer_src_end
    ldr x1, [x1]                // x1 = end ptr

    mov x20, x0                 // start pointer of ident
ident_loop:
    add x0, x0, #1
    cmp x0, x1
    bge ident_done
    ldrb w2, [x0]
    // Check [a-zA-Z0-9_]
    cmp w2, #'a'
    blt id_check_upper
    cmp w2, #'z'
    ble ident_loop
id_check_upper:
    cmp w2, #'A'
    blt id_check_digit
    cmp w2, #'Z'
    ble ident_loop
id_check_digit:
    cmp w2, #'0'
    blt id_check_us
    cmp w2, #'9'
    ble ident_loop
id_check_us:
    cmp w2, #'_'
    beq ident_loop

ident_done:
    str x0, [x19]               // update lexer_src_ptr
    sub x21, x0, x20            // length = end - start

    ldr x3, =cur_tok_ptr
    str x20, [x3]
    ldr x3, =cur_tok_len
    str x21, [x3]

    // Check keyword "main" (len 4)
    cmp x21, #4
    bne check_var
    ldr x0, =kw_main
    mov x1, x20
    mov x2, #4
    bl str_equal_len
    cbnz x0, is_main

check_var:
    // Check keyword "var" (len 3)
    cmp x21, #3
    bne check_return
    ldr x0, =kw_var
    mov x1, x20
    mov x2, #3
    bl str_equal_len
    cbnz x0, is_var

check_return:
    // Check keyword "return" (len 6)
    cmp x21, #6
    bne is_ident
    ldr x0, =kw_return
    mov x1, x20
    mov x2, #6
    bl str_equal_len
    cbnz x0, is_return

is_ident:
    mov x4, #TOK_IDENT
    b set_kw_type
is_main:
    mov x4, #TOK_KW_MAIN
    b set_kw_type
is_var:
    mov x4, #TOK_KW_VAR
    b set_kw_type
is_return:
    mov x4, #TOK_KW_RETURN
    b set_kw_type

set_kw_type:
    ldr x3, =cur_tok_type
    str x4, [x3]

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

// str_equal_len(const char *s1, const char *s2, uint64_t len) -> 1 if equal, 0 if not
str_equal_len:
    mov x3, #0
1:
    cmp x3, x2
    bge 2f
    ldrb w4, [x0, x3]
    ldrb w5, [x1, x3]
    cmp w4, w5
    bne 3f
    add x3, x3, #1
    b 1b
2:
    mov x0, #1
    ret
3:
    mov x0, #0
    ret
