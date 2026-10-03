// src/lexer/punct.s - Single-character Punctuation and Operator Scanner

.global lexer_scan_punct
.include "src/common/tokens.inc"

.text

// lexer_scan_punct(char c) -> updates cur_tok_type, advances lexer_src_ptr, returns 1 if matched, 0 if not
lexer_scan_punct:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    cmp w0, #'('
    beq is_lparen
    cmp w0, #')'
    beq is_rparen
    cmp w0, #'{'
    beq is_lbrace
    cmp w0, #'}'
    beq is_rbrace
    cmp w0, #';'
    beq is_semi
    cmp w0, #'='
    beq is_equal
    cmp w0, #'+'
    beq is_plus
    cmp w0, #'-'
    beq is_minus
    cmp w0, #'*'
    beq is_star
    cmp w0, #'/'
    beq is_slash

    // Not a recognized punctuation
    mov x0, #0
    b punct_done

is_lparen:
    mov x1, #TOK_LPAREN
    b punct_match
is_rparen:
    mov x1, #TOK_RPAREN
    b punct_match
is_lbrace:
    mov x1, #TOK_LBRACE
    b punct_match
is_rbrace:
    mov x1, #TOK_RBRACE
    b punct_match
is_semi:
    mov x1, #TOK_SEMICOLON
    b punct_match
is_equal:
    mov x1, #TOK_EQUAL
    b punct_match
is_plus:
    mov x1, #TOK_PLUS
    b punct_match
is_minus:
    mov x1, #TOK_MINUS
    b punct_match
is_star:
    mov x1, #TOK_STAR
    b punct_match
is_slash:
    mov x1, #TOK_SLASH
    b punct_match

punct_match:
    ldr x2, =cur_tok_type
    str x1, [x2]

    // Advance src ptr by 1
    ldr x2, =lexer_src_ptr
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]

    mov x0, #1

punct_done:
    ldp x29, x30, [sp], #16
    ret
