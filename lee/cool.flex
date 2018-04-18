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
DARROW          "=>"
LE              "<="
TYPEID          [A-Z][A-Za-z0-9_]*
OBJECTID        [a-z][A-Za-z0-9_]*
ASSIGN          "<-"
START		\"


%x START_COMMENT
%x COMMENT
%x STRING
%x STRING_ERR


%%

(?i:class)      {   return CLASS; }       
(?i:else)       {   return ELSE;  }
(?i:fi)         {   return FI;    }
(?i:if)         {   return IF;    }
(?i:in)         {   return IN;    }
(?i:inherits)   {   return INHERITS;}
(?i:let)        {   return LET;     }
(?i:loop)       {   return LOOP;    }
(?i:pool)       {   return POOL;    }
(?i:then)       {   return THEN;    }
(?i:while)      {   return WHILE;   }
(?i:case)       {   return CASE;    }
(?i:esac)       {   return ESAC;    }
(?i:of)         {   return OF;      }
(?i:new)        {   return NEW;     }
(?i:isvoid)     {   return ISVOID;  }
(?i:not)        {   return NOT;     }
(?i:le)         {   return LE;      }


t(?i:rue)       {   
                cool_yylval.boolean = true;
                return BOOL_CONST;
                }
f(?i:ALSE)      {   
                cool_yylval.boolean = false;
                return BOOL_CONST;
                }




 /*
  *  Single Line comments
  */

"--" {
	BEGIN(START_COMMENT);
}

<START_COMMENT>. {}

<START_COMMENT>\n {
	curr_lineno++;
	BEGIN(INITIAL);
}


 /*
  *  Nested comments
  */

"(*" {
	c_d++;
	BEGIN(COMMENT);
}

<COMMENT>{
<<EOF>> {
	cool_yylval.error_msg = "EOF in comment";
	BEGIN(INITIAL);
	return ERROR;
}

"*)" {
	c_d--;
	if (c_d == 0) {
		BEGIN(INITIAL);
	}
}

"(*" {	
		c_d++;
}

\n {
	curr_lineno++;
}

. 	{	}

}


"*)"	{
	cool_yylval.error_msg = "Unmatched *)";
	return ERROR;
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
{ASSIGN}                { return (ASSIGN); }

{TYPEID}		{
	cool_yylval.symbol = stringtable.add_string(yytext);
	return (TYPEID);
}

{OBJECTID}		{
	cool_yylval.symbol = stringtable.add_string(yytext);
	return (OBJECTID);
}


"+"                     { return('+'); } 
"/"                     { return('/'); } 
"-"                     { return('-'); } 
"*"                     { return('*'); } 
"="                     { return('='); } 
"<"                     { return('<'); } 
"."                     { return('.'); } 
"~"                     { return('~'); } 
","                     { return(','); } 
";"                     { return(';'); } 
":"                     { return(':'); } 
"("                     { return('('); } 
")"                     { return(')'); } 
"@"                     { return('@'); } 
"{"                     { return('{'); } 
"}"                     { return('}'); } 
"%"			{ return('%'); }
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
	BEGIN(STRING);
	len=0;
}

<STRING>\" {
	cool_yylval.symbol = stringtable.add_string(string_buf);
	BEGIN(INITIAL);
	memset(string_buf, '\0', sizeof(string_buf));
	return STR_CONST;
}

<STRING>\\n {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	len++;
	strcat(string_buf, "\n");
}

<STRING>\n {
	cool_yylval.error_msg = "Unterminated string constant";
	BEGIN(0);
	curr_lineno++;
	memset(string_buf, '\0', sizeof(string_buf));
	return ERROR;
}

<STRING>\0 {
	cool_yylval.error_msg = "String contains null character";
	string_buf[0] = '\0';
	BEGIN(STRING_ERR);
	return ERROR;
}

<STRING>\\\0 {
	cool_yylval.error_msg = "String cannot contain escaped null byte";
	memset(string_buf, '\0', sizeof(string_buf));
	BEGIN(STRING_ERR);
	return ERROR;
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
<STRING>\\. {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(0);
		return ERROR;
	}
	len++;
	strcat(string_buf, (yytext+1) );
}
<STRING>. {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(0);
		return ERROR;
	}
	len++;
	strcat(string_buf, yytext);
}


<STRING><<EOF>> {
	cool_yylval.error_msg = "EOF in string constant";
	curr_lineno++;
	BEGIN(INITIAL);
	return ERROR;
}





<STRING>\\\n {
	if(len + 1 >= MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		BEGIN(STRING_ERR);
		return ERROR;
	}
	curr_lineno++;
	strcat(string_buf, "\n");
}


<STRING_ERR>\" {
	BEGIN(0);
}

<STRING_ERR>\\\n {
		curr_lineno++;
		BEGIN(0);
}
<STRING_ERR>\n
{
		curr_lineno++;
		BEGIN(0);
}

<STRING_ERR>. {	}

\n {
	curr_lineno++;
}

[ \f\r\t\v]+ {}

. {
	cool_yylval.error_msg = yytext;
	return ERROR;
}
%%
