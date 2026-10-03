// src/parser/parse_error.s - Parser Error Reporting
// Outputs informative syntax/semantic error messages and exits with code 1.

.global error_main
.global error_lparen
.global error_rparen
.global error_lbrace
.global error_rbrace
.global error_semi
.global error_ident
.global error_equal
.global error_undeclared
.global error_duplicate
.global error_invalid_stmt
.global error_invalid_expr

.data
err_expected_main:   .asciz "Parse error: expected 'main'\n"
err_expected_lparen: .asciz "Parse error: expected '('\n"
err_expected_rparen: .asciz "Parse error: expected ')'\n"
err_expected_lbrace: .asciz "Parse error: expected '{'\n"
err_expected_rbrace: .asciz "Parse error: expected '}'\n"
err_expected_semi:   .asciz "Parse error: expected ';'\n"
err_expected_ident:  .asciz "Parse error: expected identifier\n"
err_expected_equal:  .asciz "Parse error: expected '='\n"
err_undeclared_var:  .asciz "Semantic error: undeclared variable\n"
err_duplicate_var:   .asciz "Semantic error: variable already declared\n"
err_invalid_stmt_str: .asciz "Parse error: unexpected statement\n"
err_invalid_expr_str: .asciz "Parse error: invalid expression\n"

.text

error_main:
    ldr x0, =err_expected_main
    b parser_fail

error_lparen:
    ldr x0, =err_expected_lparen
    b parser_fail

error_rparen:
    ldr x0, =err_expected_rparen
    b parser_fail

error_lbrace:
    ldr x0, =err_expected_lbrace
    b parser_fail

error_rbrace:
    ldr x0, =err_expected_rbrace
    b parser_fail

error_semi:
    ldr x0, =err_expected_semi
    b parser_fail

error_ident:
    ldr x0, =err_expected_ident
    b parser_fail

error_equal:
    ldr x0, =err_expected_equal
    b parser_fail

error_undeclared:
    ldr x0, =err_undeclared_var
    b parser_fail

error_duplicate:
    ldr x0, =err_duplicate_var
    b parser_fail

error_invalid_stmt:
    ldr x0, =err_invalid_stmt_str
    b parser_fail

error_invalid_expr:
    ldr x0, =err_invalid_expr_str
    b parser_fail

parser_fail:
    bl io_print_err
    mov x0, #1
    bl io_exit
