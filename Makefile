TARGET = moor/init.moon
LUA = lua
VERSION = $(shell $(LUA) -e "VER = _VERSION:gsub('Lua (.*)', '%1') print(VER)")
PREFIX = $(HOME)/.luarocks
LUA_BINDIR = $(PREFIX)/bin
LUA_SHAREDIR = $(PREFIX)/share/lua/$(VERSION)
MOOR_DIR = $(LUA_SHAREDIR)/moor

.PHONY: build install

build:
	moonc $(TARGET)

install:
	mkdir -p $(MOOR_DIR)
	cp moor/init.lua $(MOOR_DIR)
	mkdir -p $(LUA_BINDIR)
	cp bin/moor $(LUA_BINDIR)
