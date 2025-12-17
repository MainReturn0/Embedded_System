# C++ Programming Projects

This directory contains C++ programming projects and assignments for embedded systems coursework.

## Projects

Projects will be organized in subdirectories. Each project folder will contain:
- Source code (`.cpp` files)
- Header files (`.hpp` or `.h` files)
- Makefile or CMakeLists.txt (if applicable)
- Project-specific documentation

## Compilation

Most projects can be compiled using G++:

```bash
g++ -Wall -Wextra -std=c++11 -o program_name source_file.cpp
```

For more complex projects with multiple files, CMake may be used:

```bash
mkdir build && cd build
cmake ..
make
```

## Topics Covered

- Object-oriented embedded systems design
- C++ for real-time systems
- Template metaprogramming for embedded systems
- Resource management (RAII)
- Modern C++ features in embedded contexts
- Hardware abstraction layers

---

*Projects will be added as coursework progresses.*
