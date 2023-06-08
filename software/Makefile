# Define compiler
CC = clang
LD = ld.lld
OBJCOPY = llvm-objcopy
OBJDUMP = llvm-objdump

# Define scripts
AXIL_ROM_GEN = ../scripts/axil_rom_gen.py
IMGCOPY = ../scripts/imgcopy.py  
FLASHER = ../scripts/flasher.py
WORLD_GEN = ../scripts/world_gen.py

# Define linker script path
LDSCRIPT = linker.ld

# Define compiler flags
CFLAGS = --target=riscv32 -march=rv32i -Wall -Werror -O3
LDFLAGS = -T $(LDSCRIPT)

# Define directories
INC_DIR = inc
RES_DIR = res
SRC_DIR = src

BUILD_DIR = build

# Define sources
ASM_SRCS = $(wildcard $(SRC_DIR)/*.s)
C_INCS = $(wildcard $(INC_DIR)/*.h)
C_SRCS = $(wildcard $(SRC_DIR)/*.c)
TEXTURES_SRCS = $(wildcard $(RES_DIR)/*.png)

# Define objects
ASM_OBJS = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(ASM_SRCS))
C_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS))
TEXURES_OBJ = $(BUILD_DIR)/textures.o
WORLD_DATA_OBJ = $(BUILD_DIR)/world_data.o
OBJS = $(ASM_OBJS) $(C_OBJS) $(TEXURES_OBJ) $(WORLD_DATA_OBJ)

# Others
TEXURES_BIN = $(BUILD_DIR)/textures.bin
WORLD_DATA_BIN = $(BUILD_DIR)/world_data.bin

# Targets
ELF_TARGET = $(BUILD_DIR)/build.elf
TXT_TARGET = $(BUILD_DIR)/build.txt
SOFTWARE_BIN_TARGET = $(BUILD_DIR)/software.bin
BOOTLDR_BIN_TARGET = $(BUILD_DIR)/bootldr.bin
ROM_TARGET = $(BUILD_DIR)/axil_rom_bootldr.sv

# Create build directory if it doesn't exist
$(shell mkdir -p $(BUILD_DIR))

# Default target
all:	$(ELF_TARGET) \
	 	$(TXT_TARGET) \
		$(SOFTWARE_BIN_TARGET) \
		$(BOOTLDR_BIN_TARGET) \
		$(ROM_TARGET)

# Compile C source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(C_INCS)
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# Compile ASM source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	$(CC) $(CFLAGS) -c $< -o $@

# Compile textures into binary file
$(TEXURES_BIN): $(TEXTURES_SRCS)
	$(IMGCOPY) $(TEXTURES_SRCS) -o $@

# Converts texture binary files to an object file
$(TEXURES_OBJ): $(TEXURES_BIN)
	$(OBJCOPY) -I binary -O elf32-littleriscv \
	--rename-section .data=.rodata,alloc,load,readonly \
	--redefine-sym=_binary_build_textures_bin_start=_stextures \
	$< $@

# Generates world binary file
$(WORLD_DATA_BIN): $(WORLD_GEN)
	$(WORLD_GEN) -o $@

# Converts world binary file to an object file 
$(WORLD_DATA_OBJ): $(WORLD_DATA_BIN)
	$(OBJCOPY) -I binary -O elf32-littleriscv \
	--rename-section .data=.rodata,alloc,load,readonly \
	--redefine-sym=_binary_build_world_data_bin_start=_sworld_data \
	$< $@

# Link the object files into an ELF file
$(ELF_TARGET): $(OBJS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

# Convert the ELF file into a ASM file
$(TXT_TARGET): $(ELF_TARGET)
	$(OBJDUMP) -D $(ELF_TARGET) > $(TXT_TARGET)
	
# Convert the ELF file to a binary file
$(SOFTWARE_BIN_TARGET): $(ELF_TARGET)
	$(OBJCOPY) --remove-section=.init -O binary $^ $@

# Convert the ELF file to a binary file
$(BOOTLDR_BIN_TARGET): $(ELF_TARGET)
	$(OBJCOPY) --only-section=.init -O binary $^ $@

# Convert the binary file into a Verilog ROM
$(ROM_TARGET): $(BOOTLDR_BIN_TARGET)
	$(AXIL_ROM_GEN) $^ -m axil_rom_bootldr -a 12 -o $@

flash: $(SOFTWARE_BIN_TARGET)
	$(FLASHER) $^ $(SERIAL_PORT)

# Clean up object files and executable
clean:
	rm -rf $(BUILD_DIR)

# Define phony targets
.PHONY: all flash clean
