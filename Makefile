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

.PHONY: install luarocks-make test test-list clean lines

test: spec-patch
	#) '---test--'
	@$(BUSTED) --verbose --keep-going

install:
	#) '--install--'
	$(LUAROCKS) make $(LOCAL) $(ROCKSPEC)

local:
	$(MAKE) install LOCAL=--local

luarocks-make:
	#) '--luarocks-make--'
	$(LUAROCKS) --local make

spec-patch:
	#) '--spec-patch--'
	$(CD) $(SPEC_DIR); ./$(PATCH)

test-list:
	#) '---test-list--'
	@$(BUSTED) --list

clean:
	#) '--clean--'
	-$(RM) $(MOOR)/*.lua $(BIN_DIR)/*.lua

lines:
	#) '--lines--'
	$(WC) -l */*.moon $(BIN_DIR)/$(MOOR)

travis-ci:
	#) '--travis-ci--'
	$(LUAROCKS) make $(ROCKSPEC)
	/home/travis/build/Nymphium/moor/install/luarocks/bin/$(MOOR) -Linspect -e 'print (require"inspect") {"hello", "world"}'
