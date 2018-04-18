/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int c_d = 0;
int len = 0;

%}

/*
 * Define names for regular expressions here.
 */

INTEGER        [0-9]+

DARROW          =>
LE              <=
CLASS           (?i:class)
ELSE            (?i:else)
FI              (?i:fi)
IF              (?i:if)
IN              (?i:in)
INHERITS        (?:inherits)
LET             (?:let)
LOOP            (?:loop)
POOL            (?:pool)
THEN            (?:then)
WHILE           (?:while)
CASE            (?:case)
ESAC            (?:esac)
OF              (?:of)
NEW             (?:new)
ISVOID          (?:isvoid)
TYPEID          [A-Z][a-zA-Z0-9_]*
OBJECTID        [a-z][a-zA-Z0-9_]*
ASSIGN          <-
NOT             (?:not)

WHITESPACE      [ \f\r\t\v]
NEWLINE         [\n]

%x S_COMMENT
%x M_COMMENT
%x STRING
%x STRING_ERR


%%

WHITESPACE {}
NEWLINE {
	curr_lineno++;
}

 /*
  *  Single Line comments
  */

-- {
	BEGIN(S_COMMENT)
}

<S_COMMENT>\. {}

<S_COMMENT>\n {
	curr_lineno++;
	BEGIN(INITIAL);
}

<S_COMMENT><<EOF>> {
	cool_yylval.error_msg = "EOF in comment";
	return ERROR;
} 	

 /*
  *  Nested comments
  */

(* {
	c_d++;
	BEGIN(M_COMMENT);
}

<M_COMMENT><<EOF>> {
	cool_yylval.error_msg = "EOF in comment";
	return ERROR;
}

<M_COMMENT>*) {
	c_d--;
	if (c_d == 0) {
		BEGIN(INITIAL);
	}
	if (c_d < 0) {
		cool_yylval.error_msg = "Unmatched *)"
		return ERROR;
	}
}

<M_COMMENT>\n {
	curr_lineno++;
}


 /*
  *  The multiple-character operators.
  */


{INTEGER}		{
	cool_yylval.symbol = inttable.add_string(yytext);
	return INT_CONST;
}

{DARROW}		{ return (DARROW); }
{LE}        		{ return (LE); }
{ASSIGN}                { return (ASSIGN}; }

{TYPEID}		{
	cool_yylval.symbol = stringtable.add_string(yytext);
}

{OBJECTID}		{
	cool_yylval.symbol = stringtable.add_string(yytext);
}

CLASS          		{ return (CLASS); }
ELSE          		{ return (ELSE); } 
FI              	{ return (FI); }
IF              	{ return (IF); }
IN              	{ return (IN); }
INHERITS        	{ return (INHERITS); }
LET             	{ return (LET); }
LOOP            	{ return (LOOP); }
POOL            	{ return (POOL); }
THEN            	{ return (THEN); }
WHILE           	{ return (WHILE); }
CASE            	{ return (CASE); }
ESAC            	{ return (ESAC); }
OF              	{ return (OF); }
NEW             	{ return (NEW); }
ISVOID         		{ return (ISVOID); } 
NOT             	{ return (NOT);}

"+"                     { return('+'); ;
"/"                     { return('/'); ;
"-"                     { return('-'); ;
"*"                     { return('*'); ;
"="                     { return('='); ;
"<"                     { return('<'); ;
"."                     { return('.'); ;
"~"                     { return('~'); ;
","                     { return(','); ;
";"                     { return(';'); ;
":"                     { return(':'); ;
"("                     { return('('); ;
")"                     { return(')'); ;
"@"                     { return('@'); ;
"{"                     { return('{'); ;
"}"                     { return('}'); ;

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

t(?i:rue) {
	cool_yylval.boolean = 1;
	return BOOL_CONST;
}

f(?i:alse) {
	cool_yylval.boolean = 0;
	return BOOL_CONST;
}


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
	BEGIN(STRING);
}

<STRING>\" {
	cool_yylval.symbol = stringtable.add_string(string_buf);
	BEGIN(INITIAL);
	len = 0;
	string_buf[0] = '\0';
	return STR_CONST;
}

<STRING>\\. {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	strcat(string_buf, yytext + 1);
}

<STRING>\\b {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	strcat(string_buf, "\b");
}

<STRING>\\t {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	strcat(string_buf, "\t");
}
		
<STRING>\\f {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	strcat(string_buf, "\f");
}
		
<STRING>\\n {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	curr_lineno++;
	strcat(string_buf, "\n");
}

<STRING><<EOF>> {
	cool_yylval.error_msg = "EOF in string constant";
	BEGIN(STRING_ERR);
	return ERROR;
}



	



	


%%
