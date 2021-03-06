## MACRO
TARGET = vwrite.exe
PROJECT = vwrite
AUTHORS =
LICENSE =
VERSION = 0.35

MAKEFILE = win.mak
DC = dmd
MAKE = make
TO_COMPILE = src\sworks\vwrite\main.d src\sworks\base\getopt.d src\sworks\base\mo.d src\sworks\base\output.d submodule\mofile\source\mofile.d src\sworks\base\strutil.d src\sworks\win32\sjis.d
TO_LINK = src\sworks\vwrite\main.obj src\sworks\base\getopt.obj src\sworks\base\mo.obj src\sworks\base\output.obj submodule\mofile\source\mofile.obj src\sworks\base\strutil.obj src\sworks\win32\sjis.obj
COMPILE_FLAG = -Isrc;submodule\mofile\source
LINK_FLAG =
EXT_LIB =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g $(LINK_FLAG) $(FLAG) -of$@ $**

## COMPILE RULE
.d.obj :
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src\sworks\vwrite\main.obj : src\sworks\base\output.d src\sworks\base\strutil.d src\sworks\win32\sjis.d src\sworks\base\mo.d src\sworks\vwrite\main.d submodule\mofile\source\mofile.d src\sworks\base\getopt.d
src\sworks\base\getopt.obj : submodule\mofile\source\mofile.d src\sworks\base\strutil.d src\sworks\base\getopt.d src\sworks\base\mo.d
src\sworks\base\mo.obj : submodule\mofile\source\mofile.d src\sworks\base\mo.d
src\sworks\base\output.obj : src\sworks\base\output.d src\sworks\base\strutil.d src\sworks\win32\sjis.d
submodule\mofile\source\mofile.obj : submodule\mofile\source\mofile.d
src\sworks\base\strutil.obj : src\sworks\base\strutil.d
src\sworks\win32\sjis.obj : src\sworks\base\strutil.d src\sworks\win32\sjis.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
clean :
	del $(TARGET) $(TO_LINK)
clean_obj :
	del $(TO_LINK)
vwrite :
	vwrite --setversion "$(VERSION)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
	@type $(DOC_HEADER) $(DOC_FILES) $(DOC_FOOTER) > $(DOC_TARGET) 2>nul
	@del $(DOC_FILES)
show :
	@echo ROOT = src\sworks\vwrite\main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.35
run :
	$(TARGET) $(FLAG)
remake :
	amm.exe -Isubmodule\mofile\source vwrite.exe win.mak .\src\sworks\vwrite\main.d v=0.35 $(FLAG)

debug :
	ddbg $(TARGET)


l10n-init:
	xgettext -k_ --from-code=UTF-8 --language=C $(TO_COMPILE) -o l10n\$(PROJECT)\message.pot

l10n-init-po:
	msginit --locale=ja_JP.UTF-8 -i l10n\$(PROJECT)\message.pot -o l10n\$(PROJECT)\ja.po --no-translator

l10n-update:
	xgettext -k_ --from-code=UTF-8 --language=C $(TO_COMPILE) -o l10n\$(PROJECT)\message.pot
	msgmerge --update l10n\$(PROJECT)\ja.po l10n\$(PROJECT)\message.pot

l10n:
	msgcat --no-location --output l10n\$(PROJECT)\ja.nolocation.po l10n\$(PROJECT)\ja.po
	msgfmt l10n\$(PROJECT)\ja.nolocation.po -o l10n\$(PROJECT)\ja.mo

## generated by amm.
