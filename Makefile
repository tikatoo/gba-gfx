
APP := gba-gfx
LOVEVER := 11.2

LUA := $(shell find gba-gfx -type f)
LOVEWIN := love-$(LOVEVER)-win32
APPLOVE := $(APP).love
APPEXE := $(LOVEWIN)/$(APP).exe
APPZIPWIN := $(APP)-win32.zip

none:
	@echo 'No default target - please specify one explicitly:'
	@echo '- love : makes $(APPLOVE)'
	@echo '- dist : makes files for distribution:'
	@echo '         $(APPLOVE); $(APPZIPWIN).'
	@echo '- clean : clean built files'
	@echo '- clean-save : handy shortcut to remove save file'
.PHONY: none love dist clean clean-save
love: $(APPLOVE)
dist: $(APPZIPWIN)
clean:
	rm -f $(APPLOVE) $(APPZIPWIN) $(APPEXE)
clean-save:
	rm -f ~/.local/share/love/$(APP)/savedata.gfx

$(APPLOVE): $(LUA)
	cd $(APP); \
	zip ../$@ $(LUA:$(APP)/%=%)

$(APPZIPWIN): $(APPEXE)
	cd $(LOVEWIN); \
	zip ../$@ $$(find . -not -name love.exe)

$(APPEXE): $(LOVEWIN)/love.exe $(APPLOVE)
	cat $^ > $@
