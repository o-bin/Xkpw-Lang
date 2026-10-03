// src/elf/elf_build.s - Modular ELF64 Binary Builder in RAM
// Copies template, patches program size fields, and embeds machine code.

.global elf_build

.text

// elf_build(const void *code_ptr, uint64_t code_len, void *out_buf) -> x0 (total_size)
elf_build:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0                 // code_ptr
    mov x20, x1                 // code_len
    mov x21, x2                 // out_buf

    // total_size = 120 + code_len
    add x22, x20, #120          // x22 = total_size

    // Copy template headers (120 bytes) to out_buf
    ldr x0, =elf_template
    mov x1, x21
    mov x2, #120
    bl elf_memcpy

    // Patch Program Header p_filesz and p_memsz
    // Offset 64 + 32 = 96: p_filesz
    // Offset 64 + 40 = 104: p_memsz
    str x22, [x21, #96]
    str x22, [x21, #104]

    // Copy code to out_buf + 120
    mov x0, x19                 // src = code_ptr
    add x1, x21, #120           // dst = out_buf + 120
    mov x2, x20                 // len = code_len
    bl elf_memcpy

    // Return total_size
    mov x0, x22

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

// Helper: elf_memcpy(const void *src, void *dst, uint64_t count)
elf_memcpy:
    mov x3, #0
1:
    cmp x3, x2
    bge 2f
    ldrb w4, [x0, x3]
    strb w4, [x1, x3]
    add x3, x3, #1
    b 1b
2:
    ret
