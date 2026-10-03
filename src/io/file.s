// src/io/file.s - Modular File System Operations via ARM64 Syscalls
// Pure Linux ABI, no libc.

.global io_open_read
.global io_open_write
.global io_read
.global io_write
.global io_close
.global io_exit

.text

// io_open_read(const char *path) -> x0 (fd or error < 0)
io_open_read:
    mov x1, x0              // path
    mov x0, #-100           // AT_FDCWD
    mov x2, #0              // O_RDONLY
    mov x3, #0              // mode
    mov x8, #56             // SYS_openat
    svc #0
    ret

// io_open_write(const char *path) -> x0 (fd or error < 0)
// Flags: O_WRONLY(1) | O_CREAT(64) | O_TRUNC(512) = 0x241
// Mode: 0755 = 0x1ed (rwxr-xr-x)
io_open_write:
    mov x1, x0              // path
    mov x0, #-100           // AT_FDCWD
    mov x2, #0x241          // O_WRONLY | O_CREAT | O_TRUNC
    mov x3, #0x1ed          // 0755
    mov x8, #56             // SYS_openat
    svc #0
    ret

// io_read(int fd, void *buf, uint64_t count) -> x0 (bytes read)
io_read:
    mov x8, #63             // SYS_read
    svc #0
    ret

// io_write(int fd, const void *buf, uint64_t count) -> x0 (bytes written)
io_write:
    mov x8, #64             // SYS_write
    svc #0
    ret

// io_close(int fd) -> x0
io_close:
    mov x8, #57             // SYS_close
    svc #0
    ret

// io_exit(int code)
io_exit:
    mov x8, #93             // SYS_exit
    svc #0
