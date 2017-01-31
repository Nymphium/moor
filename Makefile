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
LUAROCKS_TMP =/tmp/luarocks-test

.PHONY: continue test install local lint compile spec-patch test-list clean lines

compile:
	#) '---$@---'
	$(MOONC) $(MOOR)/*.moon $(BIN_DIR)/$(MOOR).moon

continue:
	#) '---$@---'
	$(MOONC) -w $(MOOR)/*.moon $(BIN_DIR)/$(MOOR).moon

install:
	#) '---$@---'
	#) WARN: This is not install phase but just alias to 'lint'
	$(MAKE) rocklint

rockmake:
	#) '---$@---'
	$(LUAROCKS) $(LOCAL) make $(ROCKSPEC)

test: compile spec-patch
	#) '---$@---'
	for f in $(SPEC_DIR)/*.moon; do $(BUSTED) --verbose --keep-going $$f; done
	$(LUAROCKS) make $(ROCKSPEC) --tree=$(LUAROCKS_TMP)

local:
	#) '---$@---'
	$(MAKE) rockmake LOCAL=--local

rocklint:
	#) '---$@---'
	$(LUAROCKS) lint $(ROCKSPEC)

spec-patch:
	#) '---$@---'
	./$(SPEC_DIR)/$(PATCH)

test-list:
	#) '---$@---'
	@$(BUSTED) --list

clean:
	#) '---$@---'
	-$(RM) $(MOOR)/*.lua $(BIN_DIR)/$(MOOR).lua

lines:
	#) '---$@---'
	$(WC) -l */*.moon

