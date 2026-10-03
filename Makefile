# Makefile for xkpw-lang compiler
# 100% Modular Architecture - Built ONLY with 'as' and 'ld' (Zero C, pure ARM64 Assembly)

AS = as
LD = ld

ASFLAGS = -I.
LDFLAGS = -s

# Modular Source Files
SRCS_IO = \
	src/io/file.s \
	src/io/print.s

SRCS_LEXER = \
	src/lexer/state.s \
	src/lexer/punct.s \
	src/lexer/num.s \
	src/lexer/ident.s \
	src/lexer/lexer.s

SRCS_SYMTAB = \
	src/symtab/symtab.s

SRCS_CODEGEN = \
	src/codegen/code_buf.s \
	src/codegen/emit_frame.s \
	src/codegen/emit_imm.s \
	src/codegen/emit_mem.s \
	src/codegen/emit_stack.s \
	src/codegen/emit_arith.s \
	src/codegen/emit_exit.s

SRCS_PARSER = \
	src/parser/parse_error.s \
	src/parser/parse_factor.s \
	src/parser/parse_term.s \
	src/parser/parse_expr.s \
	src/parser/parse_decl.s \
	src/parser/parse_assign.s \
	src/parser/parse_return.s \
	src/parser/parser.s

SRCS_ELF = \
	src/elf/elf_template.s \
	src/elf/elf_build.s

SRCS_MAIN = \
	src/main.s

SRCS = $(SRCS_IO) $(SRCS_LEXER) $(SRCS_SYMTAB) $(SRCS_CODEGEN) $(SRCS_PARSER) $(SRCS_ELF) $(SRCS_MAIN)
OBJS = $(SRCS:.s=.o)

TARGET = compiler

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
