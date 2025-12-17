# Assembly Language Projects

This directory contains Assembly language projects and assignments for embedded systems coursework.

## Projects

Projects will be organized in subdirectories. Each project folder will contain:
- Assembly source files (`.asm` or `.s` files)
- Linker scripts (if applicable)
- Makefile (if applicable)
- Project-specific documentation

## Assemblers Used

Depending on the target architecture:

**NASM (x86/x86-64):**
```bash
nasm -f elf64 source_file.asm -o output_file.o
ld output_file.o -o program_name
```

**GAS (GNU Assembler - ARM/x86):**
```bash
as source_file.s -o output_file.o
ld output_file.o -o program_name
```

**ARM Assembler:**
```bash
arm-none-eabi-as source_file.s -o output_file.o
arm-none-eabi-ld output_file.o -o program_name
```

## Topics Covered

- Low-level hardware programming
- Processor architecture and instruction sets
- Register manipulation
- Memory addressing modes
- Interrupt handling
- Performance optimization
- Direct hardware control

---

*Projects will be added as coursework progresses.*
