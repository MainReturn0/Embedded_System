# Contributing Guidelines

## Adding New Projects

When adding new university projects to this repository, please follow these guidelines:

### Directory Structure

1. Place C projects in the `C/` directory
2. Place C++ projects in the `CPP/` directory
3. Place Assembly projects in the `Assembly/` directory

### Project Organization

Each project should be in its own subdirectory with a descriptive name:

```
C/
├── project_name/
│   ├── README.md           # Project description and instructions
│   ├── src/                # Source files
│   ├── include/            # Header files (if applicable)
│   ├── Makefile            # Build instructions (if applicable)
│   └── docs/               # Additional documentation (if needed)
```

### Naming Conventions

- Use lowercase with underscores for directory names: `uart_driver`, `led_control`
- Use descriptive names that indicate the project purpose
- Avoid spaces in directory and file names

### Documentation

Each project should include:
- **README.md**: Brief description, purpose, compilation instructions, and usage
- **Comments**: Well-commented code explaining logic and algorithms
- **Requirements**: Any hardware or software dependencies

### Code Quality

- Use consistent indentation (spaces or tabs, but be consistent)
- Follow standard C/C++ coding conventions
- Include proper error handling
- Test your code before committing

### Commit Messages

Use clear and descriptive commit messages:
- `Add: [project_name] - Brief description`
- `Update: [project_name] - What was changed`
- `Fix: [project_name] - What was fixed`

### Example Commit Messages

```
Add: UART communication driver in C
Update: LED control with PWM support
Fix: Timer overflow issue in interrupt handler
```

## File Types to Include

**Do include:**
- Source files (`.c`, `.cpp`, `.asm`, `.s`)
- Header files (`.h`, `.hpp`)
- Makefiles or build scripts
- Documentation files (`.md`, `.txt`)
- Linker scripts (`.ld`)

**Don't include:**
- Compiled binaries (`.exe`, `.out`, `.o`)
- IDE-specific files (already in `.gitignore`)
- Build artifacts (already in `.gitignore`)

---

*These guidelines help maintain a clean and organized repository.*
