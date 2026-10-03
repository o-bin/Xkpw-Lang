// src/parser/parse_term.s - Multiplicative Term Expression Parser
// Handles '*' and '/' operations with higher precedence than addition/subtraction.

.global parser_parse_mul
.include "src/common/tokens.inc"

.text

// parser_parse_mul() -> parses primary ( ('*' | '/') primary )*
parser_parse_mul:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    bl parser_parse_primary

mul_loop:
    ldr x0, =cur_tok_type
    ldr x19, [x0]               // x19 = operator token

    cmp x19, #TOK_STAR
    beq do_mul_op
    cmp x19, #TOK_SLASH
    beq do_div_op
    b mul_done

do_mul_op:
    bl lexer_next
    bl emit_push_x0
    bl parser_parse_primary
    bl emit_pop_x1
    bl emit_mul
    b mul_loop

do_div_op:
    bl lexer_next
    bl emit_push_x0
    bl parser_parse_primary
    bl emit_pop_x1
    bl emit_div
    b mul_loop

mul_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
