# Define compiler
CC = clang

# Define compiler flags
CFLAGS = -Wall -Wextra -O3 -g
LDFLAGS = 

# Define directories
SRC_DIR = src
INC_DIR = inc
BUILD_DIR = build

# Define sources
C_SRCS = $(wildcard $(SRC_DIR)/*.c)

# Define objects
C_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS))

# Targets
TARGET = $(BUILD_DIR)/build

# Create build directory if it doesn't exist
$(shell mkdir -p $(BUILD_DIR))

# Default target
all: $(TARGET)

# Compile C source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# Link the object files into an ELF file
$(TARGET): $(C_OBJS)
	$(CC) $(LDFLAGS) $(C_OBJS) -o $@

run: $(TARGET)
	$(BUILD_DIR)/build

# Clean up object files and executable
clean:
	rm -rf $(BUILD_DIR)

# Define phony targets
.PHONY: all run clean
