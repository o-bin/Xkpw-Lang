// src/parser/parse_decl.s - Variable Declaration Parser
// Handles 'var <ident>;' syntax and registers symbols in symtab.

.global parse_var_decl
.include "src/common/tokens.inc"

.text

// parse_var_decl()
parse_var_decl:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl lexer_next               // consume 'var'

    // Expect identifier
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_IDENT
    bne error_ident

    ldr x0, =cur_tok_ptr
    ldr x0, [x0]
    ldr x1, =cur_tok_len
    ldr x1, [x1]
    bl symtab_add
    cbz x0, error_duplicate

    bl lexer_next               // consume identifier

    // Expect ';'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_SEMICOLON
    bne error_semi
    bl lexer_next               // consume ';'

    ldp x29, x30, [sp], #16
    ret
