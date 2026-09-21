# Toolchain
CC      := clang
CFLAGS  := -std=c11 -Wall -Wextra -Wpedantic -MMD -MP
LDFLAGS :=

# Output executable name
TARGET_NAME := app

# Directories
SRC_DIR   := src
INC_DIR   := include
BUILD_DIR := build
BIN_DIR   := $(BUILD_DIR)/bin
OBJ_DIR   := $(BUILD_DIR)/obj

# Target paths
TARGET       := $(BIN_DIR)/$(TARGET_NAME)
DEBUG_TARGET := $(BIN_DIR)/$(TARGET_NAME)_debug

# Sources, Objects, Dependencies
SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)

# Include flags
CFLAGS += -I$(INC_DIR)

.PHONY: all debug run clean print-target

# Release build (default)
all: CFLAGS += -O3
all: $(TARGET)

# Debug build (symbols enabled, optimization disabled)
debug: CFLAGS += -g -O0 -DDEBUG
debug: $(DEBUG_TARGET)

# Link release binary
$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Link debug binary
$(DEBUG_TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Compile C sources into object directory
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Create directories on demand
$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

# Run the release binary
run: all
	@./$(TARGET)

# Used by s:DebugStart() in .vimrc
print-target:
	@echo $(DEBUG_TARGET)

# Clean all build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Include compiler-generated header dependency rules
-include $(DEPS)
