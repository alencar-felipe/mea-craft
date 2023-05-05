# Define compiler
CC = clang
LD = ld.lld
OBJCOPY = llvm-objcopy
OBJDUMP = llvm-objdump

LDSCRIPT = linker.ld

# Define compiler flags
CFLAGS = --target=riscv32 -march=rv32i -Wall -Werror
LDFLAGS = -T $(LDSCRIPT)

# Define directories
SRC_DIR = src
INC_DIR = inc
BUILD_DIR = build

# Define sources
ASM_SRCS = $(wildcard $(SRC_DIR)/*.s)
C_SRCS = $(wildcard $(SRC_DIR)/*.c)

# Define objects
ASM_OBJS = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(ASM_SRCS))
C_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS))
OBJS = $(ASM_OBJS) $(C_OBJS)

# Targets
ELF_TARGET = $(BUILD_DIR)/build.elf
BIN_TARGET = $(BUILD_DIR)/build.bin
TXT_TARGET = $(BUILD_DIR)/build.txt

# Create build directory if it doesn't exist
$(shell mkdir -p $(BUILD_DIR))

# Default target
all: $(ELF_TARGET) $(BIN_TARGET) $(TXT_TARGET)

# Compile C source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# Compile ASM source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	$(CC) $(CFLAGS) -c $< -o $@

# Link the object files into an ELF file
$(ELF_TARGET): $(OBJS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

# Convert the ELF file to a binary file
$(BIN_TARGET): $(ELF_TARGET)
	$(OBJCOPY) -O binary $^ $@

# Convert the ELF file into a ASM file
$(TXT_TARGET): $(ELF_TARGET)
	$(OBJDUMP) -D $(ELF_TARGET) > $(TXT_TARGET)

# Clean up object files and executable
clean:
	rm -rf $(BUILD_DIR)

# Define phony targets
.PHONY: all run clean
