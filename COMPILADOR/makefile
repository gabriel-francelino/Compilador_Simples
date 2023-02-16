simples: lexico.l sintatico.y utils.c;
	flex -o lexico.c lexico.l;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples;

limpa: ;
	rm lexico.c sintatico.c sintatico.h sintatico.output simples

erro: ;
	echo "teste1";\
	./simples testes/t1.simples;\
	echo "teste2";\
	./simples testes/t2.simples;\
	echo "teste3";\
	./simples testes/t3.simples;\
	echo "teste4";\
	./simples testes/t4.simples;\
	echo "teste5";\
	./simples testes/t5.simples;\
	echo "teste6";\
	./simples testes/t6.simples;\
	echo "teste7";\
	./simples testes/t7.simples;\
	echo "teste8";\
	./simples testes/t8.simples;\
	echo "teste9";\
	./simples testes/t9.simples;\
	echo "teste10";\
	./simples testes/t10.simples;\
	echo "teste11";\
	./simples testes/t11.simples;\
	echo "teste12";\
	./simples testes/t12.simples;