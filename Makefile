LUA_PATH_MAKE = $(shell $(LUAROCKS) path --lr-path | $(SED) -e "s/?.*//")
LUA_BIN_MAKE = $(shell $(LUAROCKS) path --lr-bin | $(SED) -e "s/:.*//")

MOOR = moor

SPEC_DIR = spec
PATCH = patch.sh

BUSTED = busted
CAT = cat
CD = cd
CP = cp
LUAROCKS = luarocks
MKDIR = mkdir
MOONC = moonc
RM = rm
SED = sed
WC = wc

.PHONY: install compile test test-list watch clean length

install: test compile
	#) '--install--'
	$(MKDIR) -pv $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -rv $(MOOR)/*.lua $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -rv bin/$(MOOR)  $(LUA_BIN_MAKE)/

compile:
	#) '--compile--'
	$(MOONC) $(MOOR)/

spec-patch:
	$(CD) $(SPEC); ./$(PATCH)

test: spec-patch
	#) '---test--'
	$(BUSTED) --verbose --keep-going

test-list:
	#) '---test-list--'
	@$(BUSTED) --list

watch:
	#) '--watch--'
	$(MOONC) $(MOOR)/
	$(MOONC) -w $(MOOR)/

clean:
	#) '--clean--'
	-$(RM) $(MOOR)/*.lua bin/*.lua

length:
	#) '--length--'
	$(CAT) */*.moon bin/$(MOOR) | $(WC) -l

