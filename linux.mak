## for gnu make
## DOT DIRECTIVE
.PHONY : release clean show remake install run edit clean_obj vwrite debug-all ddoc debug l10n-init l10n-init-po l10n-update l10n
## MACRO
TARGET = vwrite
PROJECT = vwrite
VERSION = 0.35

MAKEFILE = linux.mak
DC = dmd
MAKE = make
TO_COMPILE = src/sworks/vwrite/main.d src/sworks/base/getopt.d src/sworks/base/mo.d src/sworks/base/output.d submodule/mofile/source/mofile.d src/sworks/base/strutil.d
TO_LINK = src/sworks/vwrite/main.o src/sworks/base/getopt.o src/sworks/base/mo.o src/sworks/base/output.o submodule/mofile/source/mofile.o src/sworks/base/strutil.o
COMPILE_FLAG = -Isrc:submodule/mofile/source
LINK_FLAG =
EXT_LIB =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g -of$@ $(LINK_FLAG) $(TO_LINK) $(FLAG)

## COMPILE RULE
%.o : %.d
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src/sworks/vwrite/main.o : src/sworks/base/getopt.d submodule/mofile/source/mofile.d src/sworks/base/output.d src/sworks/base/strutil.d src/sworks/base/mo.d src/sworks/vwrite/main.d
src/sworks/base/getopt.o : submodule/mofile/source/mofile.d src/sworks/base/strutil.d src/sworks/base/mo.d src/sworks/base/getopt.d
src/sworks/base/mo.o : src/sworks/base/mo.d submodule/mofile/source/mofile.d
src/sworks/base/output.o : src/sworks/base/output.d
submodule/mofile/source/mofile.o : submodule/mofile/source/mofile.d
src/sworks/base/strutil.o : src/sworks/base/strutil.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
clean :
	rm $(TARGET) $(TO_LINK)
clean_obj :
	rm $(TO_LINK)
vw :
	vwrite --setversion "$(VERSION)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
	@type $(DOC_HEADER) $(DOC_FILES) $(DOC_FOOTER) > $(DOC_TARGET) 2>nul
	@del $(DOC_FILES)
show :
	@echo ROOT = src/sworks/vwrite/main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.35
run :
	$(TARGET) $(FLAG)
remake :
	amm -Isubmodule/mofile/source -ofvwrite linux.mak v=0.35 src/sworks/vwrite/main.d $(FLAG)

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
install:
	cp ./vwrite /usr/local/bin
	if [ ! -d "/usr/local/etc/vwrite" ]; then mkdir /usr/local/etc/vwrite; fi
	if [ ! -d "/usr/local/etc/vwrite/l10n" ]; then mkdir /usr/local/etc/vwrite/l10n; fi
	cp ./l10n/vwrite/ja.mo /usr/local/etc/vwrite/l10n
