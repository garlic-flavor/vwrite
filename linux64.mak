## for gnu make
## DOT DIRECTIVE
.PHONY : release clean show remake install run edit clean_obj vwrite debug-all ddoc
## MACRO
TARGET = vwrite.out
AUTHORS = KUMA
LICENSE = CC0
VERSION = 0.29(dmd2.069.2)

MAKEFILE = linux64.mak
DC = dmd
MAKE = gmake
TO_COMPILE = src/sworks/base/output.d src/sworks/vwrite/main.d
TO_LINK = src/sworks/base/output.o src/sworks/vwrite/main.o
COMPILE_FLAG = -m64 -Isrc
LINK_FLAG = -m64
EXT_LIB =
DDOC_FILE =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g -of$@ $(LINK_FLAG) $(TO_LINK) $(EXT_LIB)

## COMPILE RULE
%.o : %.d
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src/sworks/base/output.o : src/sworks/base/output.d
src/sworks/vwrite/main.o : src/sworks/base/output.d src/sworks/vwrite/main.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB)  $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB)  $(FLAG)
clean :
	rm $(TARGET) $(TO_LINK)
clean_obj :
	rm $(TO_LINK)
vwrite :
	vwrite --setversion "$(VERSION)" --project "$(TARGET)" --authors "$(AUTHORS)" --license "$(LICENSE)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D -Dd $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
show :
	@echo ROOT = src/sworks/vwrite/main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.29(dmd2.069.2)
run :
	$(TARGET) $(FLAG)
edit :
	emacs $(TO_COMPILE)
remake :
	amm -m64 linux64.mak -ofvwrite.out src/sworks/vwrite/main.d "v=0.29(dmd2.069.2)" authors=KUMA license=CC0 $(FLAG)

debug :
	ddbg $(TARGET)

## generated by amm.