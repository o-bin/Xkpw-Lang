// src/parser/parse_return.s - Return Statement Parser
// Handles 'return <expr>;' syntax and emits exit syscall.

.global parse_return_stmt
.include "src/common/tokens.inc"

.text

// parse_return_stmt()
parse_return_stmt:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl lexer_next               // consume 'return'

    // Parse expression -> evaluates into x0
    bl parser_parse_expr

    // Emit process exit with x0
    bl emit_return

    // Expect ';'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_SEMICOLON
    bne error_semi
    bl lexer_next               // consume ';'

    ldp x29, x30, [sp], #16
    ret
