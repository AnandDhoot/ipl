all:    lex.cc parse.cc main.cc Scanner.h Scannerbase.h Scanner.ih Parser.h Parserbase.h Parser.ih
	g++   --std=c++0x lex.cc parse.cc main.cc -o parser;
	echo "digraph G {ordering=out;\n\n""`./parser < test-assembly`""}" > graph.dot
	dot -Tpdf graph.dot -o graph.pdf
	# g++   --std=c++0x lex.cc parse.cc main.cc
	# ./a.out < test-assembly > junk;
	# egrep 'nextToken|reduce' junk        

Parser.ih: parse.y 
	if [ ! -e Parser.ih ]; then \
		bisonc++ --construction -V parse.y && sed -i '/#include/a int nodeCount = 0;' Parser.ih; \
	fi

Parser.h Parserbase.h parse.cc:  parse.y
	bisonc++ --construction -V parse.y;

Scanner.ih: lex.l Parserbase.h
	./cond_remove_scannerh
	flexc++ lex.l
	sed -i '/int lex()/r enums' Scanner.h
	sed -i '/include/a #include "Parserbase.h"' Scanner.ih; 

Scanner.h Scannerbase.h lex.cc: Scanner.ih

.PHONY: clean     
clean:
	$(RM) Parser.ih Parser.h Parserbase.h parse.cc Scanner.ih Scanner.h Scannerbase.h lex.cc a.out graph.ps junk *~

