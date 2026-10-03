// src/parser/parser.s - Main Parser Coordinator and Function Structure
// Coordinates grammar parsing: 'main() { statement* }'.

.global parser_parse_program
.include "src/common/tokens.inc"

.text

// parser_parse_program()
parser_parse_program:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Expect 'main'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_KW_MAIN
    bne error_main
    bl lexer_next

    // Expect '('
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_LPAREN
    bne error_lparen
    bl lexer_next

    // Expect ')'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_RPAREN
    bne error_rparen
    bl lexer_next

    // Expect '{'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_LBRACE
    bne error_lbrace
    bl lexer_next

    // Function Prologue
    bl emit_prologue

parse_statements_loop:
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_RBRACE
    beq finish_function
    cmp x0, #TOK_EOF
    beq finish_function

    bl parse_statement
    b parse_statements_loop

finish_function:
    // Expect '}'
    ldr x0, =cur_tok_type
    ldr x0, [x0]
    cmp x0, #TOK_RBRACE
    bne error_rbrace
    bl lexer_next

    // Default exit if return not encountered
    bl emit_default_exit

    // Patch stack frame size
    bl symtab_get_frame_size
    bl codegen_patch_frame_size

    ldp x29, x30, [sp], #16
    ret

// parse_statement() -> dispatches to specialized statement parser
parse_statement:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x0, =cur_tok_type
    ldr x0, [x0]

    // 1. 'var'
    cmp x0, #TOK_KW_VAR
    beq do_decl

    // 2. identifier (assignment)
    cmp x0, #TOK_IDENT
    beq do_assign

    // 3. 'return'
    cmp x0, #TOK_KW_RETURN
    beq do_return

    // 4. empty statement ';'
    cmp x0, #TOK_SEMICOLON
    beq do_empty

    // Unrecognized statement error
    b error_invalid_stmt

do_decl:
    bl parse_var_decl
    b stmt_finished

do_assign:
    bl parse_assignment
    b stmt_finished

do_return:
    bl parse_return_stmt
    b stmt_finished

do_empty:
    bl lexer_next
    b stmt_finished

stmt_finished:
    ldp x29, x30, [sp], #16
    ret
