// src/parser/parse_assign.s - Assignment Statement Parser
// Handles '<ident> = <expr>;' syntax and stores evaluated result to variable slot.

.global parse_assignment
.include "src/common/tokens.inc"

.text

// parse_assignment()
parse_assignment:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    // Save target variable name ptr and len
    ldr x0, =cur_tok_ptr
    ldr x19, [x0]
    ldr x0, =cur_tok_len
    ldr x20, [x0]

    // Lookup in symbol table
    mov x0, x19
    mov x1, x20
    bl symtab_lookup
    cbz x0, error_undeclared
    mov x21, x0                 // x21 = stack offset

    bl lexer_next               // consume identifier

    // Expect '='
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_EQUAL
    bne error_equal
    bl lexer_next               // consume '='

    // Parse expression -> evaluates into x0
    bl parser_parse_expr

    // Store x0 to variable stack offset
    mov x0, x21
    bl emit_store_var

    // Expect ';'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_SEMICOLON
    bne error_semi
    bl lexer_next               // consume ';'

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
