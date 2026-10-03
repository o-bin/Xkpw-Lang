// src/io/print.s - Modular String and Error Printing
// Outputs strings and characters to stdout / stderr.

.global io_strlen
.global io_print_str
.global io_print_err
.global io_print_char

.text

// io_strlen(const char *str) -> x0 (len)
io_strlen:
    mov x1, x0              // ptr
    mov x0, #0              // len
1:
    ldrb w2, [x1, x0]
    cbz w2, 2f
    add x0, x0, #1
    b 1b
2:
    ret

// io_print_str(const char *str) -> writes string to stdout (fd 1)
io_print_str:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

    bl io_strlen
    mov x2, x0              // count
    mov x1, x19             // buf
    mov x0, #1              // fd 1 (stdout)
    bl io_write

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

// io_print_err(const char *str) -> writes string to stderr (fd 2)
io_print_err:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

    bl io_strlen
    mov x2, x0              // count
    mov x1, x19             // buf
    mov x0, #2              // fd 2 (stderr)
    bl io_write

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

// io_print_char(char c) -> writes a single char to stdout
io_print_char:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    strb w0, [sp]
    mov x0, #1
    mov x1, sp
    mov x2, #1
    bl io_write
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
