// src/parser/parse_expr.s - Additive Expression Parser
// Handles '+' and '-' operations and serves as expression parsing coordinator.

.global parser_parse_expr
.global parser_parse_add
.include "src/common/tokens.inc"

.text

// parser_parse_expr() -> evaluates expression into x0
parser_parse_expr:
    b parser_parse_add

// parser_parse_add() -> parses mul ( ('+' | '-') mul )*
parser_parse_add:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    bl parser_parse_mul

add_loop:
    ldr x0, =cur_tok_type
    ldr x19, [x0]               // x19 = operator token

    cmp x19, #TOK_PLUS
    beq do_add_op
    cmp x19, #TOK_MINUS
    beq do_sub_op
    b add_done

do_add_op:
    bl lexer_next
    bl emit_push_x0
    bl parser_parse_mul
    bl emit_pop_x1
    bl emit_add
    b add_loop

do_sub_op:
    bl lexer_next
    bl emit_push_x0
    bl parser_parse_mul
    bl emit_pop_x1
    bl emit_sub
    b add_loop

add_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
