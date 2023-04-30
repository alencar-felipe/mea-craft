# Define compiler and compiler flags
CC = gcc
CFLAGS = -Wall -Werror

# Define directories
SRC_DIR = src
INC_DIR = inc
BUILD_DIR = build

# Define source and object files
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))

# Define target executable
TARGET = emulator

# Create build directory if it doesn't exist
$(shell mkdir -p $(BUILD_DIR))

# Default target
all: $(BUILD_DIR)/$(TARGET)

# Compile source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# Link object files into executable
$(BUILD_DIR)/$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

# Run the executable
run: $(BUILD_DIR)/$(TARGET)
	./$<

# Clean up object files and executable
clean:
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/$(TARGET)

# Define phony targets
.PHONY: all run clean
