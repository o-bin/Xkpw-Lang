// src/elf/elf_template.s - Standard ELF64 Executable Header Template for ARM64 Linux
// Direct specification of ELF64 header and Program Header structures.

.global elf_template

.section .rodata
.align 8
elf_template:
    // ELF Header (64 bytes)
    // 0..15: e_ident
    .byte 0x7f, 'E', 'L', 'F', 2, 1, 1, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    // 16..19: e_type (2 = ET_EXEC), e_machine (0xb7 = EM_AARCH64)
    .hword 2, 0xb7
    // 20..23: e_version (1)
    .word 1
    // 24..31: e_entry (0x400078)
    .quad 0x400078
    // 32..39: e_phoff (64)
    .quad 64
    // 40..47: e_shoff (0)
    .quad 0
    // 48..51: e_flags (0)
    .word 0
    // 52..55: e_ehsize (64), e_phentsize (56)
    .hword 64, 56
    // 56..59: e_phnum (1), e_shentsize (0)
    .hword 1, 0
    // 60..63: e_shnum (0), e_shstrndx (0)
    .hword 0, 0

    // Program Header (56 bytes, offset 64)
    // 0..3: p_type (1 = PT_LOAD)
    .word 1
    // 4..7: p_flags (7 = PF_R | PF_W | PF_X)
    .word 7
    // 8..15: p_offset (0)
    .quad 0
    // 16..23: p_vaddr (0x400000)
    .quad 0x400000
    // 24..31: p_paddr (0x400000)
    .quad 0x400000
    // 32..39: p_filesz (patched at runtime)
    .quad 0
    // 40..47: p_memsz (patched at runtime)
    .quad 0
    // 48..55: p_align (0x10000 = 64KB)
    .quad 0x10000
