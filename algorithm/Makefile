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
SRCS = $(wildcard $(SRC_DIR)/*.c)
INCS = $(wildcard $(SRC_DIR)/*.h)

# Define objects
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

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
$(TARGET): $(OBJS) $(INCS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@

run: $(TARGET)
	$(BUILD_DIR)/build

# Clean up object files and executable
clean:
	rm -rf $(BUILD_DIR)

# Define phony targets
.PHONY: all run clean
