MOOR = moor

LOCAL ?= 

SPEC_DIR = spec
BIN_DIR = bin
PATCH = patch.sh

BUSTED = busted
CD = cd
CP = cp
ECHO = echo
LS = ls
LUAROCKS = luarocks
MAKE = make
MKDIR = mkdir
MOONC = moonc
RM = rm
SED = sed
WC = wc

ROCKSPEC = $(shell $(LS) moor-*.rockspec)

.PHONY: test install local lint compile spec-patch test-list clean lines

test: spec-patch
	#) '---$@--'
	@$(BUSTED) --verbose --keep-going

install: lint compile
	#) '---$@--'
	$(LUAROCKS) make $(LOCAL) $(ROCKSPEC)

local:
	#) '---$@--'
	$(MAKE) install LOCAL=--local

lint:
	#) '---$@--'
	$(LUAROCKS) lint $(ROCKSPEC)

compile:
	#) '---$@--'
	$(MOONC) $(MOOR)/*.moon
	$(MOONC) $(BIN_DIR)/$(MOOR).moon

spec-patch:
	#) '---$@--'
	$(CD) $(SPEC_DIR); ./$(PATCH)

test-list:
	#) '---$@--'
	@$(BUSTED) --list

clean:
	#) '---$@--'
	-$(RM) $(MOOR)/*.lua $(BIN_DIR)/$(MOOR).lua

lines:
	#) '---$@--'
	$(WC) -l */*.moon

