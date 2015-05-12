CFLAGS=-Wint-to-pointer-cast
SRC=./src/*.c
INC=./include
DST=./lib
LINK=-string
OUT=

TSTINC=./tests/include
TST=./tests
TSTS=./tests/*.c

all:
ifdef NAME
ifdef IS_LIBRARY
	gcc -I$(INC) -c $(SRC)
	ar rcs $(DST)/lib/lib$(NAME).a *.o
	rm *.o
else
	gcc $(CFLAGS) -I$(INC) $(SRC) -o $(NAME) $(LINK)
endif
else
	@echo "Project not setup! Please run 'make setup' first."
endif

testlib: $(SRC)
ifdef NAME
	gcc -I$(INC) -I$(TSTINC) -c $(SRC)
	mkdir -p $(TST)/lib
	ar rcs $(TST)/lib/$(LIB) *.o
	rm *.o
else
	@echo "Project not setup! Please run 'make setup' first."
endif

tests: testlib
ifndef NAME
	find ./$(TST) -name "*.c" -exec gcc {} -o $(TST)/bin/{} -l$(NAME)
else
	@echo "Project not setup! Please run 'make setup' first."
endif

package:
ifdef NAME
	make
	mkdir -p $(DST)/include
	cat /dev/null >| $(DST)/include/$(NAME).h
	find ./$(INC) -name "*.h" -exec cat {} > $(DST)/include/$(NAME).h \;
else
	@echo "Project not setup! Please run 'make setup' first."
endif	

inc:
ifdef NAME
	@read -p "Enter header path (with .h): " file;\
	mkdir -p $(INC)/"$$file" ;\
	rmdir $(INC)/"$$file" ;\
	touch $(INC)/"$$file" ;\
	tmp=$${file////_};\
	def=$${tmp/.h/ };\
	cat /dev/null >| $(INC)/"$$file" ;\
	echo "#ifndef __$(NAME)_$$def" >> $(INC)/"$$file";\
	echo "#define __$(NAME)_$$def" >> $(INC)/"$$file";\
	echo "\n\n" >> $(INC)/"$$file";\
	echo "#endif" >> $(INC)/"$$file";\
	if [ ! -z  "$(EDITOR)" ]; then \
		$(EDITOR) $(INC)/"$$file";\
	fi
else
	@echo "Project not setup! Please run 'make setup' first."
endif	

install:
	echo -n "Installing the library"
	cp $(DST)/include/*.h /usr/include
	cp $(DST)/*.a /usr/lib
clean:
	find ./ -iname "*.a" -exec rm {} \;
	find ./ -iname "*.o" -exec rm {} \;
	find ./ -iname "*.out" -exec rm {} \;
	find ./ -iname "*.bin" -exec rm {} \;

unsetup:
	@rm -rf $(TST) $(DST) $(INC) ./src
	@rm -rf $(TSTINC) $(TST)/bin

setup:
ifndef NAME
	@echo "Setting up project"
	@read -p "Enter project name: " name;\
	read -p "Is this a library (1) or executable (2)?: " type;\
	read -p "Text editor path: " editor;\
	if [ $$type=1 ]; then\
 		exec 3<> Makefile && awk -v TEXT="IS_LIBRARY=1" 'BEGIN {print TEXT}{print}' Makefile >&3;\
	fi;\
	exec 3<> Makefile && awk -v TEXT="NAME=$$name\nEDITOR=$$editor" 'BEGIN {print TEXT}{print}' Makefile >&3
	@mkdir -p $(TST) $(DST) $(INC) ./src
	@mkdir -p $(TSTINC) $(TST)/bin
endif
