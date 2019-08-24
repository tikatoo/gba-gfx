none:
	@echo 'No default target - please specify one explicitly.'
.PHONY: none clean clean-save
clean:
	rm -f gba-gfx.love
clean-save:
	rm -f ~/.local/share/love/gba-gfx/savedata.gfx

LUA := $(shell find gba-gfx -type f)

gba-gfx.love: $(LUA)
	cd gba-gfx; \
	zip ../$@ $(LUA:gba-gfx/%=%)
