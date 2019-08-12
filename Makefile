
LUA := $(shell find gba-gfx -name '*.lua')

gba-gfx.love: $(LUA)
	cd gba-gfx; \
	zip ../$@ $(LUA:gba-gfx/%=%)


.PHONY: clean clean-save

clean:
	rm -f gba-gfx.love

clean-save:
	rm -f ~/.local/share/love/gba-gfx/savedata.gfx
