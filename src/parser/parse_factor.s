// src/parser/parse_factor.s - Primary / Factor Expression Parser
// Handles numeric literals, variable identifiers, and parenthesized expressions.

.global parser_parse_primary
.include "src/common/tokens.inc"

.text

// parser_parse_primary() -> emits instructions evaluating primary factor into x0
parser_parse_primary:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x0, =cur_tok_type
    ldr x0, [x0]

    // 1. Number literal
    cmp x0, #TOK_NUMBER
    beq primary_number

    // 2. Variable identifier
    cmp x0, #TOK_IDENT
    beq primary_ident

    // 3. Parentheses '(' expr ')'
    cmp x0, #TOK_LPAREN
    beq primary_paren

    // Invalid expression syntax
    b error_invalid_expr

primary_number:
    ldr x0, =cur_tok_val
    ldr x0, [x0]
    bl emit_mov_imm
    bl lexer_next
    b primary_done

primary_ident:
    ldr x0, =cur_tok_ptr
    ldr x0, [x0]
    ldr x1, =cur_tok_len
    ldr x1, [x1]
    bl symtab_lookup
    cbz x0, error_undeclared
    bl emit_load_var
    bl lexer_next
    b primary_done

primary_paren:
    bl lexer_next               // consume '('
    bl parser_parse_expr
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_RPAREN
    bne error_rparen
    bl lexer_next               // consume ')'
    b primary_done

primary_done:
    ldp x29, x30, [sp], #16
    ret
