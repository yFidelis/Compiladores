
CFLAGS=-std=gnu99 -Wall -Wextra -g
CPARAMS=-lm -I bin/ -I src/#-ll 

BIN_DIR := bin

run: 
	./bin/compiler sample/exemplo_$(N).c

teste: 
	./bin/compiler sample/correto_0.c

compile: clean parser scanner
	mkdir -p $(BIN_DIR)
	gcc $(CFLAGS) $(BIN_DIR)/parser.tab.c $(BIN_DIR)/lex.yy.c $(CPARAMS) -o $(BIN_DIR)/compiler

parser:
	mkdir -p $(BIN_DIR)
	bison -d src/parser.y -o $(BIN_DIR)/parser.tab.c

scanner:
	mkdir -p $(BIN_DIR)
	flex -o $(BIN_DIR)/lex.yy.c src/scanner.l 

clean:
	rm -rf $(BIN_DIR)/*

zip:
	mkdir -p bkp
	tar -czvf bkp/`(date +%y-%m-%d-%H-%M-%S)`.tar.gz Makefile src/* sample/*

