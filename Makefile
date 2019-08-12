
LUA := $(shell find gba-gfx -name '*.lua')

gba-gfx.love: $(LUA)
	cd gba-gfx; \
	zip ../$@ $(LUA:gba-gfx/%=%)
