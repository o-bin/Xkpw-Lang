// src/lexer/lexer.s - Main Lexer Coordinator
// Dispatches whitespace, comments, numbers, identifiers, and punctuation.

.global lexer_next
.include "src/common/tokens.inc"

.data
err_lex_char: .asciz "Lexer error: unrecognized character in source.\n"

.text

// lexer_next() -> updates cur_tok_*
lexer_next:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

skip_whitespace_and_comments:
    ldr x19, =lexer_src_ptr
    ldr x0, [x19]               // x0 = current ptr
    ldr x1, =lexer_src_end
    ldr x1, [x1]                // x1 = end ptr

    cmp x0, x1
    bge token_eof

    ldrb w2, [x0]               // w2 = char

    // Space, tab, CR
    cmp w2, #' '
    beq advance_ws
    cmp w2, #'\t'
    beq advance_ws
    cmp w2, #'\r'
    beq advance_ws

    // Newline
    cmp w2, #'\n'
    beq advance_nl

    // Check for comment '//'
    cmp w2, #'/'
    beq check_comment

    // Dispatch to token scanners
    b dispatch_token

advance_nl:
    ldr x3, =cur_tok_line
    ldr x4, [x3]
    add x4, x4, #1
    str x4, [x3]
advance_ws:
    add x0, x0, #1
    str x0, [x19]
    b skip_whitespace_and_comments

check_comment:
    add x3, x0, #1
    cmp x3, x1
    bge dispatch_token          // at EOF, '/' is a token
    ldrb w4, [x3]
    cmp w4, #'/'
    bne dispatch_token          // not '//', so '/' is a token

    // Single-line comment: skip until newline or EOF
    add x0, x0, #2
comment_loop:
    cmp x0, x1
    bge comment_done
    ldrb w2, [x0]
    cmp w2, #'\n'
    beq comment_newline
    add x0, x0, #1
    b comment_loop

comment_newline:
    add x0, x0, #1
    str x0, [x19]
    ldr x3, =cur_tok_line
    ldr x4, [x3]
    add x4, x4, #1
    str x4, [x3]
    b skip_whitespace_and_comments

comment_done:
    str x0, [x19]
    b skip_whitespace_and_comments

dispatch_token:
    // 1. Try punctuation and operators
    mov w0, w2
    bl lexer_scan_punct
    cbnz x0, token_done

    // 2. Try numeric literal: '0' <= c <= '9'
    cmp w2, #'0'
    blt check_ident
    cmp w2, #'9'
    bgt check_ident
    bl lexer_scan_number
    b token_done

check_ident:
    // 3. Try identifier start: [a-zA-Z_]
    cmp w2, #'a'
    blt check_upper
    cmp w2, #'z'
    ble do_ident
check_upper:
    cmp w2, #'A'
    blt check_underscore
    cmp w2, #'Z'
    ble do_ident
check_underscore:
    cmp w2, #'_'
    beq do_ident

    // Unrecognized character error
    ldr x0, =err_lex_char
    bl io_print_err
    mov x0, #1
    bl io_exit

do_ident:
    bl lexer_scan_ident
    b token_done

token_eof:
    ldr x3, =cur_tok_type
    mov x4, #TOK_EOF
    str x4, [x3]

token_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
