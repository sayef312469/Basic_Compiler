%option noyywrap
%{

#include <stdio.h>
#include "symbol_table.h"
#define YYSTYPE SymbolInfo
#include "parser.tab.h"
void yyerror(const char* str);

%}

WS [ \t\n]+
ID [_a-zA-Z][_a-zA-Z0-9]*
CONST_INT [0-9]+
CONST_FLOAT [0-9]*([.][0-9]+)?(E[+-]?[0-9]+)?
MAIN main
INT int
FLOAT float
DOUBLE double
ADDOP [+-]
MULOP [*/%]
ASSOP "="
LOGICOP "&&"|"||"
LPAREN "("
RPAREN ")"
LCURL "{"
RCURL "}"
LTHIRD "["
RTHIRD "]"
COMMA ","
SEMICOLON ";"

%%
{WS} 			{}
{MAIN}			{return MAIN;}
{INT}			{return INT;}
{FLOAT}			{return FLOAT;}
{DOUBLE}		{return DOUBLE;}
{ADDOP}			{
					SymbolInfo obj(yytext, "ADDOP");
					yylval = obj;
					return ADDOP;
				}
{MULOP}			{
					SymbolInfo obj(yytext, "MULOP");
					yylval = obj;
					return MULOP;
				}
{ASSOP}			{
					SymbolInfo obj(yytext, "ASSOP");
					yylval = obj;
					return ASSOP;
				}
{LOGICOP}		{
					SymbolInfo obj(yytext, "LOGICOP");
					yylval = obj;
					return LOGICOP;
				}
{SEMICOLON}		{return SEMICOLON;}
{LPAREN}		{return LPAREN;}
{RPAREN}		{return RPAREN;}
{LCURL}			{return LCURL;}
{RCURL}			{return RCURL;}
{LTHIRD}		{return LTHIRD;}
{RTHIRD}		{return RTHIRD;}
{COMMA}			{return COMMA;}
{CONST_INT}   	{
					SymbolInfo obj(yytext, "NUM");
					yylval = obj;
					return NUM;
				}
{CONST_FLOAT}   {
					SymbolInfo obj(yytext, "NUM");
					yylval = obj;
					return NUM;
				}
{ID} 			{
					SymbolInfo obj(yytext, "ID");
					yylval = obj;
					return ID;
				}
. 				{
					yyerror("Error: Invalid character\n");
				}


%%