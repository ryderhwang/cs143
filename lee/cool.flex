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

%}

/* Declare condition */
%s OPEN_PAR
%s CLOSE_PAR
%s COMMENT

%s STRING

/*
 * Define names for regular expressions here.
 */

DARROW          "=>"
LE              "<="     
ASSIGN          "<-"      
COMMENT_D         "--"        
OPEN_PAR_D        "(\*"       
CLOSE_PAR_D       "\*)"       

START		\"		
WHITESPACE	[ \f\r\t\v]+
/* Flex webpage */





%%

 /*
  *  Nested comments
  */


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

[0-9]+         {
                cool_yylval.symbol = inttable.add_string(yytext);
                return  INT_CONST;
                }






{WHITESPACE}	{ }
\n          { curr_lineno++;    }
{COMMENT_D}     { BEGIN COMMENT; }
{OPEN_PAR_D}    { BEGIN OPEN_PAR; ]

<OPEN_PAR>\n

<CLOSE_PAR>\n




 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
{LE}            { return (LE); }        //ADDED
{ASSIGN}        { return (ASSIGN); }    //ADDED


 /* Single Character */
"{"	{ return '{';	}
"}"	{ return '}';	}
"("	{ return '(';	}
")"	{ return ')';	}
";"	{ return ';';	}
":"	{ return ':';	}
","	{ return ',';	}
"."	{ return '.';	}
"="	{ return '=';	}
"@"	{ return '@';	}
"+"	{ return '+';	}
"-"	{ return '-';	}
"<"	{ return '<';	}
"*"	{ return '*';	}
"/"	{ return '/';	}
"~"	{ return '~';	}
"%"	{ return '%';	}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

[A-Z][A-Za-z0-9]* {
	cool_yylval.symbol = idtable.add_string(yytext);
	return (TYPEID);
}
[a-z][A-Za-z0-9]* {
	cool_yylval.symbol = idtable.add_string(yytext);
	return (OBJECTID);
}
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"	{
	BEGIN(STRING)
	}

<STRING>\"	{
		/* String constant too long */
		}

<STRING>\n	{
		/* Unterminated string constant */
		}

<STRING>\0	{
		/* Contains NULL character */
		}
<STRING><EOF> {

		/* EOF */
		}



%%
