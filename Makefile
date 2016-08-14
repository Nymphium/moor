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
	@pwd
	@$(BUSTED) --verbose --keep-going

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

