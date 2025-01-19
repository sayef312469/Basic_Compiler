%{
#include<stdio.h>
#include<stdlib.h>
#include "symbol_table.h"
#define YYSTYPE SymbolInfo
SymbolTable table;
SymbolInfo container;

int yylex();
extern FILE *yyin,*yyout; 
int temp_counter=1;
void yyerror(const char* str){
		printf("Error: %s\n", str);
	}
	
char* newTemp(){
	char* temp;
	temp = (char*) malloc(15*sizeof(char));
	sprintf(temp, "t%d", temp_counter);
	temp_counter++;
	return temp;
}

%}

%token NUM INT FLOAT DOUBLE LPAREN RPAREN LCURL RCURL SEMICOLON COMMA ID MAIN
%left LTHIRD RTHIRD
%left ADDOP
%left MULOP
%left LOGICOP
%right ASSOP

%%
prog: MAIN LPAREN RPAREN LCURL stmt RCURL 	{}

stmt: stmt unit								{}
| unit				        				{}
;

unit: var_decl              				{}
| expr_decl                 				{}
;

var_decl: type_spec decl_list SEMICOLON		{}

type_spec: INT								{}
| FLOAT										{}
| DOUBLE									{}
;

decl_list: term                				{}
| decl_list COMMA term	        			{}
| term LTHIRD NUM RTHIRD	        		{}
| decl_list COMMA term LTHIRD NUM RTHIRD	{}
| ass_list									{}
| decl_list COMMA ass_list					{}
;

ass_list: term ASSOP expr					{
												temp_counter=1;                            
												cout<<$1.getSymbol();
												cout<<"=";
												cout<<$3.getSymbol()<<endl;
												fprintf(yyout, "%s = %s\n", $1.getSymbol().c_str(), $3.getSymbol().c_str());
												table.Insert($1.getSymbol(), $1.getType());
												if($3.getType()=="ID"||$3.getType()=="TempID")
													table.Insert($3.getSymbol(), $3.getType());
												container.codeAppend($1.getSymbol(), $3.getSymbol(), "", $2.getSymbol());
												
											}
;

expr_decl: term ASSOP expr SEMICOLON		{
												temp_counter=1;                            
												cout<<$1.getSymbol();
												cout<<"=";
												cout<<$3.getSymbol()<<endl;
												fprintf(yyout, "%s = %s\n", $1.getSymbol().c_str(), $3.getSymbol().c_str());
												table.Insert($1.getSymbol(), $1.getType());
												if($3.getType()=="ID"||$3.getType()=="TempID")
													table.Insert($3.getSymbol(), $3.getType());
												container.codeAppend($1.getSymbol(), $3.getSymbol(), "", $2.getSymbol());
												
											}
;

expr: expr ADDOP expr						{
 
												char* str = newTemp();
												SymbolInfo obj(str, "TempID");
												$$ = obj;
												cout<<"id "<<$1.getSymbol()<<" "<<$3.getSymbol()<<" "<<$$.getSymbol()<<endl;
												cout<<$$.getSymbol()<<" = " << $1.getSymbol() << $2.getSymbol() << $3.getSymbol()<<endl;
												fprintf(yyout, "%s = %s %s %s\n", $$.getSymbol().c_str(), $1.getSymbol().c_str(), $2.getSymbol().c_str(), $3.getSymbol().c_str());
												if($1.getType()=="ID"||$1.getType()=="TempID")
													table.Insert($1.getSymbol(), $1.getType());
												if($3.getType()=="ID"||$3.getType()=="TempID")
													table.Insert($3.getSymbol(), $3.getType());
												table.Insert($$.getSymbol(), $$.getType());
												container.codeAppend($1.getSymbol(), $3.getSymbol(), $$.getSymbol(), $2.getSymbol());
											}
| expr MULOP expr							{
												char* str = newTemp();
												SymbolInfo obj(str, "TempID");
												$$ = obj;
												cout<<"id "<<$1.getSymbol()<<" "<<$3.getSymbol()<<" "<<$$.getSymbol()<<endl;
												cout<<$$.getSymbol()<<" = " << $1.getSymbol() << '*' << $3.getSymbol()<<endl;
												fprintf(yyout, "%s = %s %s %s\n", $$.getSymbol().c_str(), $1.getSymbol().c_str(), $2.getSymbol().c_str(), $3.getSymbol().c_str());
												if($1.getType()=="ID"||$1.getType()=="TempID")
													table.Insert($1.getSymbol(), $1.getType());
												if($3.getType()=="ID"||$3.getType()=="TempID")
													table.Insert($3.getSymbol(), $3.getType());
												table.Insert($$.getSymbol(), $$.getType());
												container.codeAppend($1.getSymbol(), $3.getSymbol(), $$.getSymbol(), $2.getSymbol());
											}
| expr LOGICOP expr							{
												char* str = newTemp();
												SymbolInfo obj(str, "TempID");
												$$ = obj;
												cout<<"id "<<$1.getSymbol()<<" "<<$3.getSymbol()<<" "<<$$.getSymbol()<<endl;
												cout<<$$.getSymbol()<<" = " << $1.getSymbol() <<$2.getSymbol()<< $3.getSymbol()<<endl;
												fprintf(yyout, "%s = %s %s %s\n", $$.getSymbol().c_str(), $1.getSymbol().c_str(), $2.getSymbol().c_str(), $3.getSymbol().c_str());
												if($1.getType()=="ID"||$1.getType()=="TempID")
													table.Insert($1.getSymbol(), $1.getType());
												if($3.getType()=="ID"||$3.getType()=="TempID")
													table.Insert($3.getSymbol(), $3.getType());
												table.Insert($$.getSymbol(), $$.getType());
												container.codeAppend($1.getSymbol(), $3.getSymbol(), $$.getSymbol(), $2.getSymbol());
											}
| LPAREN expr RPAREN						{ $$ = $2; }
| term										{}
| NUM										{}
;

term: ID                					{}
;

%%

int main(int argc, char **argv){
	if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
	yyout = fopen("code.ir", "w");
    yyparse();
	fclose(yyout);
	container.getCode(table);
	table.Print();
	return 0;
}
