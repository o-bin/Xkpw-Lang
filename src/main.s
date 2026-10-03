// src/main.s - Main Driver and CLI for xkpw-lang compiler
// Written 100% in ARM64 Assembly for Linux.

.global _start

.equ SRC_BUF_SIZE, 65536
.equ ELF_BUF_SIZE, 131072

.data
usage_msg:     .asciz "Usage: ./compiler <source.xkpw> -bin <output_binary>\n"
opt_bin_str:   .asciz "-bin"
err_open_in:   .asciz "Error: cannot open input source file\n"
err_read_in:   .asciz "Error: failed reading input file\n"
err_open_out:  .asciz "Error: cannot create output binary file\n"
err_write_out: .asciz "Error: failed writing output binary file\n"

.bss
.align 8
src_buf:
    .space SRC_BUF_SIZE
elf_buf:
    .space ELF_BUF_SIZE

.text

_start:
    // Linux aarch64 entry point
    // [sp] = argc
    // [sp + 8] = argv[0]
    // [sp + 16] = argv[1]
    // [sp + 24] = argv[2]
    // [sp + 32] = argv[3]

    ldr x19, [sp]               // x19 = argc
    cmp x19, #4
    blt print_usage_and_exit

    ldr x20, [sp, #16]          // x20 = argv[1] (input path)
    ldr x21, [sp, #24]          // x21 = argv[2] (must be "-bin")
    ldr x22, [sp, #32]          // x22 = argv[3] (output path)

    // Check if argv[2] == "-bin"
    ldr x0, =opt_bin_str
    mov x1, x21
    bl streq
    cbz x0, print_usage_and_exit

    // 1. Open input source file
    mov x0, x20
    bl io_open_read
    cmp x0, #0
    blt error_open_input
    mov x23, x0                 // x23 = in_fd

    // 2. Read entire file into RAM (src_buf)
    mov x0, x23
    ldr x1, =src_buf
    ldr x2, =SRC_BUF_SIZE
    bl io_read
    cmp x0, #0
    blt error_read_input
    mov x24, x0                 // x24 = bytes read

    // 3. Close input file immediately - 100% in RAM from here on
    mov x0, x23
    bl io_close

    // 4. Initialize compiler modules
    bl symtab_init
    bl codegen_init

    ldr x0, =src_buf
    mov x1, x24
    bl lexer_init

    // 5. Parse program and generate ARM64 machine code
    bl parser_parse_program

    // 6. Build ELF binary 100% in RAM
    bl codegen_get_buf
    mov x19, x0                 // x19 = code_buf ptr
    bl codegen_get_size
    mov x1, x0                  // x1 = code_size
    mov x0, x19                 // x0 = code_buf
    ldr x2, =elf_buf            // x2 = out_buf
    bl elf_build
    mov x25, x0                 // x25 = total_elf_size

    // 7. Write binary executable directly to physical disk
    mov x0, x22
    bl io_open_write
    cmp x0, #0
    blt error_open_output
    mov x26, x0                 // x26 = out_fd

    mov x0, x26
    ldr x1, =elf_buf
    mov x2, x25
    bl io_write
    cmp x0, x25
    bne error_write_output

    mov x0, x26
    bl io_close

    // Exit success
    mov x0, #0
    bl io_exit

print_usage_and_exit:
    ldr x0, =usage_msg
    bl io_print_err
    mov x0, #1
    bl io_exit

error_open_input:
    ldr x0, =err_open_in
    bl io_print_err
    mov x0, #1
    bl io_exit

error_read_input:
    ldr x0, =err_read_in
    bl io_print_err
    mov x0, #1
    bl io_exit

error_open_output:
    ldr x0, =err_open_out
    bl io_print_err
    mov x0, #1
    bl io_exit

error_write_output:
    ldr x0, =err_write_out
    bl io_print_err
    mov x0, #1
    bl io_exit

// streq(const char *s1, const char *s2) -> 1 if equal, 0 if not
streq:
    mov x2, #0
1:
    ldrb w3, [x0, x2]
    ldrb w4, [x1, x2]
    cmp w3, w4
    bne 3f
    cbz w3, 2f
    add x2, x2, #1
    b 1b
2:
    mov x0, #1
    ret
3:
    mov x0, #0
    ret
