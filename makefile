SRC_DIR := src
BUILD := build
OBJCOPY := objcopy

SHELL_ELF := $(BUILD)/shell.elf
SHELL_BIN := $(BUILD)/shell.bin

SHELL_SRC := $(SRC_DIR)/main.rs $(SRC_DIR)/sys.rs Cargo.toml

.PHONY: all clean

all: $(SHELL_BIN)

$(SHELL_ELF): $(SHELL_SRC) linker.ld
	@mkdir -p $(dir $@) $(BUILD)/cargo
	@command -v cargo >/dev/null || (echo "error: cargo not found (need rustup toolchain + x86_64-unknown-none target)"; exit 1)
	@command -v rustc >/dev/null || (echo "error: rustc not found"; exit 1)
	CARGO_TARGET_DIR="$(CURDIR)/$(BUILD)/cargo" \
	RUSTFLAGS="-C link-arg=-T$(CURDIR)/linker.ld -C link-arg=-nostdlib -C link-arg=-static -C link-arg=-no-pie -C link-arg=--gc-sections -C no-redzone=yes" \
	cargo build --release --target x86_64-unknown-none
	cp $(BUILD)/cargo/x86_64-unknown-none/release/shell $@

$(SHELL_BIN): $(SHELL_ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD)
