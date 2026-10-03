// src/symtab/symtab.s - Modular Symbol Table for Local Variables
// Tracks variables and assigns 8-byte stack offsets relative to FP (x29).

.global symtab_init
.global symtab_add
.global symtab_lookup
.global symtab_get_frame_size

.equ SYMTAB_MAX_ENTRIES, 256
.equ SYMTAB_ENTRY_SIZE, 32

.bss
.align 8
symtab_count:
    .quad 0
symtab_table:
    .space SYMTAB_MAX_ENTRIES * SYMTAB_ENTRY_SIZE

.text

// symtab_init() -> resets symbol table
symtab_init:
    ldr x0, =symtab_count
    str xzr, [x0]
    ret

// symtab_lookup(const char *name, uint64_t len) -> x0 (stack_offset, or 0 if not found)
symtab_lookup:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    mov x19, x0                 // target name ptr
    mov x20, x1                 // target name len

    ldr x2, =symtab_count
    ldr x2, [x2]
    cbz x2, lookup_not_found

    ldr x3, =symtab_table
    mov x4, #0                  // index

lookup_loop:
    cmp x4, x2
    bge lookup_not_found

    // Check len
    ldr x5, [x3, #8]
    cmp x5, x20
    bne lookup_next

    // Compare characters
    ldr x6, [x3]
    mov x7, #0

str_cmp_loop:
    cmp x7, x20
    bge lookup_match
    ldrb w8, [x19, x7]
    ldrb w9, [x6, x7]
    cmp w8, w9
    bne lookup_next
    add x7, x7, #1
    b str_cmp_loop

lookup_next:
    add x3, x3, #SYMTAB_ENTRY_SIZE
    add x4, x4, #1
    b lookup_loop

lookup_match:
    ldr x0, [x3, #16]           // stack_offset
    b lookup_done

lookup_not_found:
    mov x0, #0

lookup_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

// symtab_add(const char *name, uint64_t len) -> x0 (stack_offset, or 0 if error)
symtab_add:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0                 // name ptr
    mov x20, x1                 // name len

    bl symtab_lookup
    cbnz x0, add_already_exists

    ldr x1, =symtab_count
    ldr x2, [x1]
    cmp x2, #SYMTAB_MAX_ENTRIES
    bge add_overflow

    // offset = - ((count + 1) * 8)
    add x3, x2, #1
    lsl x3, x3, #3
    neg x21, x3

    // Store in table
    ldr x4, =symtab_table
    mov x5, #SYMTAB_ENTRY_SIZE
    madd x4, x2, x5, x4

    str x19, [x4]               // name_ptr
    str x20, [x4, #8]           // name_len
    str x21, [x4, #16]          // stack_offset

    // Increment count
    add x2, x2, #1
    str x2, [x1]

    mov x0, x21
    b add_done

add_already_exists:
    mov x0, #0
    b add_done

add_overflow:
    mov x0, #0

add_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

// symtab_get_frame_size() -> x0 (aligned to 16 bytes)
symtab_get_frame_size:
    ldr x0, =symtab_count
    ldr x0, [x0]
    lsl x0, x0, #3              // count * 8
    add x0, x0, #15
    and x0, x0, #-16            // (count * 8 + 15) & ~15
    cmp x0, #0
    bne 1f
    mov x0, #16
1:
    ret
